output "dns_name" {
  value       = aws_lb.app_lb.dns_name
  description = "DNS du load balancer du tier app"
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.app_target_group.arn
}

output "lb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.app_lb.dns_name
}