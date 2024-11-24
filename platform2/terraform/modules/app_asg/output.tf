# Output pour l'ID de l'Auto Scaling Group
output "app_asg_id" {
  value = aws_autoscaling_group.app_asg.id
}