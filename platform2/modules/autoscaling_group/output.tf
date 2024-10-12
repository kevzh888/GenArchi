# Définition de la sortie pour l'ARN du groupe cible associé au groupe d'autoscaling
output "asg-target-group-arn" {
  # Description de la sortie
  description = "ARN du groupe cible frontend pour le groupe d'autoscaling"
  # Valeur de la sortie, référençant l'ARN du groupe cible créé
  value = aws_lb_target_group.frontend_target_group.arn
}
