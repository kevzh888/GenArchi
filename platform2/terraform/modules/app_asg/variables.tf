# Variables à définir pour le réseau et la sécurité
# Ces variables sont nécessaires pour configurer l'emplacement et la sécurité de l'ASG
variable "private_subnet_id_1" {
  description = "ID du sous-réseau privé 1 pour le tiers App"
  type        = string
}

variable "private_subnet_id_2" {
  description = "ID du sous-réseau privé 2 pour le tiers App"
  type        = string
}

variable "app_sg_id" {
  description = "ID du groupe de sécurité pour le tiers App"
  type        = string
}

# Variables pour la configuration de l'instance
# Ces variables définissent les caractéristiques de base des instances dans l'ASG
variable "app_instance_type" {
  description = "Type d'instance pour le tiers App"
  default     = "t2.micro"
}

variable "app_ami_id" {
  description = "ID de l'AMI pour le tiers App"
  default     = "ami-045a8ab02aadf4f88"
}

# Variables pour la configuration de l'Auto Scaling Group
# Ces variables contrôlent le comportement de mise à l'échelle de l'ASG
variable "app_desired_capacity" {
  description = "Capacité souhaitée pour l'Auto Scaling Group"
  default     = 2
}

variable "app_max_size" {
  description = "Taille maximale pour l'Auto Scaling Group"
  default     = 3
}

variable "app_min_size" {
  description = "Taille minimale pour l'Auto Scaling Group"
  default     = 1
}

# Variables pour les contrôles de santé et la mise à l'échelle
# Ces variables définissent les paramètres de santé et de performance de l'ASG
variable "app_health_check_grace_period" {
  description = "Période de grâce pour les contrôles de santé"
  default     = 300
}

variable "app_cpu_target_value" {
  description = "Valeur cible d'utilisation CPU pour la mise à l'échelle"
  default     = 60.0
}