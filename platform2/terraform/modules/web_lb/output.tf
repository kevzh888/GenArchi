output "web_target_group_arn" {
  value       = aws_lb_target_group.web_target_group.arn
  description = "ARN du Target Group pour le Load Balancer Web"
}

output "dns_name" {
  value       = aws_lb.web_lb.dns_name
  description = "DNS du load balancer du tier web"
}