output "db_target_group_arn" {
  value       = aws_lb_target_group.mysql_target_group.arn
  description = "ARN du Target Group pour le Load Balancer Database"
}

output "dns_name" {
  value       = aws_lb.mysql_nlb.dns_name
  description = "DNS du load balancer du tier Database"
}