# Définition de la sortie pour l'ID de l'équilibreur de charge frontal
output "frontend-elb-id" {
    # Description de la sortie
    description = "Frontend Application Loadbalancer id"
    # Valeur de la sortie, référençant l'ID de l'équilibreur de charge créé
    value = aws_elb.frontend_elb.id
}