
# Variables pour le module de groupe d'autoscaling

# Configuration SSH
variable "private-key-name" {
  description = "Nom de la clé SSH privée"
  type        = string
  default     = "pk"
}

# Configuration du groupe de sécurité
variable "web-server-sg-id" {
  description = "ID du groupe de sécurité pour les serveurs web"
  type        = string
}

# Configuration du groupe d'autoscaling
variable "autoscaling-group-name" {
  description = "Nom du groupe d'autoscaling"
  type        = string
  default     = "wordpress-autoscaling-group"
}

# Zones de disponibilité pour le groupe d'autoscaling
variable "autoscaling-group-az" {
  description = "Zones de disponibilité pour le groupe d'autoscaling"
  type        = list(string)
  default     = ["eu-west-3a", "eu-west-3b", "eu-west-3c"]
}

# ID du VPC
variable "vpc-id" {
  description = "ID du VPC contenant le groupe d'autoscaling"
  type        = string
}

# Configuration de l'image Ubuntu
variable "ubuntu-image-location" {
  description = "Emplacement de l'image Ubuntu 22.04"
  type        = string
  default     = "ubuntu/images/hvm-ssd/ubuntu-focal-22.04-amd64-server-*"
}

# Liste des sous-réseaux
variable "subnet-id-list" {
  description = "Liste des ID de sous-réseaux où l'ALB sera déployé"
  type        = list(string)
}