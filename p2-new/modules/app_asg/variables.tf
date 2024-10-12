# Variables à définir
variable "private_subnet_id" {
  description = "ID du sous-réseau privé pour le tiers App"
  type        = string
}

variable "app_sg_id" {
  description = "ID du groupe de sécurité pour le tiers App"
  type        = string
}