# Variable pour le groupe de sécurité de l'ALB
variable "security-group" {
  description = "Groupe de sécurité utilisé pour l'ALB"
  type        = string
}

# Variable pour la liste des ID de sous-réseaux
variable "subnet-id-list" {
  description = "Liste des ID de sous-réseaux où l'ALB sera déployé"
  type        = list(string)
}

# Variable pour l'ARN du groupe cible
variable "target-group-arn" {
  description = "ARN du groupe cible associé à l'ALB"
  type        = string
}