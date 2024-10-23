# Configuration du bloc CIDR pour le VPC
variable "vpc_cidr_block" {
  description = "Bloc CIDR pour le VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# Configuration du support DNS pour le VPC
variable "enable_dns_support" {
  description = "Activer le support DNS pour le VPC"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Activer les noms d'hôte DNS pour le VPC"
  type        = bool
  default     = true
}

# Nommage du VPC
variable "vpc_name" {
  description = "Nom du VPC"
  type        = string
  default     = "my_vpc"
}