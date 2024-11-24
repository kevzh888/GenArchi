output "dns_name" {
  value = aws_autoscaling_group.web_asg.arn
  description = "Le DNS de la première instance EC2 dans l'Auto Scaling Group Web."
}