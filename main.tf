# Security Group des instances : HTTP depuis l'ALB uniquement, aucun SSH
resource "aws_security_group" "this" {
  name_prefix = "${var.name}-"
  description = "Instances : HTTP depuis ALB uniquement, aucun SSH"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP depuis ALB uniquement"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    description = "Sortie vers Internet (paquets, Parameter Store)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = var.name })

  # Le nouveau SG est cree avant la suppression de l'ancien : pas de coupure
  lifecycle {
    create_before_destroy = true
  }
}

# Modele d'instance
resource "aws_launch_template" "this" {
  name_prefix            = "${var.name}-"
  image_id               = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.this.id]
  user_data              = base64encode(var.user_data)

  metadata_options {
    http_tokens = "required" # IMDSv2 exige
  }

  dynamic "iam_instance_profile" {
    for_each = var.iam_instance_profile_name == null ? [] : [var.iam_instance_profile_name]
    content {
      name = iam_instance_profile.value
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { Name = var.name })
  }
}

# Groupe d'auto-scaling : remplace les instances que l'ALB declare malades
resource "aws_autoscaling_group" "this" {
  name                = var.name
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = var.target_group_arns
  health_check_type   = "ELB"

  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version
  }

  tag {
    key                 = "Name"
    value               = var.name
    propagate_at_launch = true
  }
}
