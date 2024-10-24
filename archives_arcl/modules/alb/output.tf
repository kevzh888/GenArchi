# Définition de la sortie pour l'ID de l'équilibreur de charge d'application frontend
output "alb-id" {
  # Description de la sortie
  description = "Frontend Application Loadbalancer id"
  # Valeur de la sortie, référençant l'ID de l'ALB créé
  value       = aws_lb.frontend_alb.id
}