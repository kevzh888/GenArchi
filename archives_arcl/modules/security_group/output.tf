# Définition de la sortie pour l'ID du groupe de sécurité
output "sg_id" {
  # Description de la sortie
  description = "ID du groupe de sécurité par défaut pour le serveur web"
  # Valeur de la sortie, référençant l'ID du groupe de sécurité créé
  value       = aws_security_group.security_group_module.id
}
