output "security_group_id" {
  description = "Security Group des instances"
  value       = aws_security_group.this.id
}

output "launch_template_id" {
  description = "Launch Template des instances"
  value       = aws_launch_template.this.id
}

output "autoscaling_group_name" {
  description = "Nom du groupe d'auto-scaling"
  value       = aws_autoscaling_group.this.name
}
