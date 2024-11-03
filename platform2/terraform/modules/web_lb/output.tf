output "web_target_group_arn" {
  value       = aws_lb_target_group.web_target_group.arn
  description = "ARN du Target Group pour le Load Balancer Web"
}