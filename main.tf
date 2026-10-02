resource "aws_security_group" "this" {
  name        = "novasphere-${var.name}"
  description = "Regles du serveur ${var.name}"

  ingress {
    description = "SSH restreint"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  dynamic "ingress" {
    for_each = var.open_ports
    content {
      description = "Port ${ingress.value} public"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # NOUVEAU v1.1.0 : port 9100 ouvert a l'admin seulement, si l'option est activee
  dynamic "ingress" {
    for_each = var.enable_monitoring_port ? [9100] : []
    content {
      description = "node exporter, administration seulement"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [var.admin_cidr]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.this.id]

  tags = merge(var.tags, {
    Name = "novasphere-${var.name}"
    Role = var.name
  })
}
