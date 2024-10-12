# Variable pour le VPC
variable "vpc_id" {
  description = "ID du VPC"
  type = string
}

# Variables pour le sous-réseau public
variable "public_subnet_cidr" {
  description = "Bloc CIDR pour le sous-réseau public"
  type = string
  default = "10.0.1.0/24"
}

variable "public_subnet_az" {
  description = "Zone de disponibilité pour le sous-réseau public"
  type = string
  default = "eu-west-3"
}

# Variables pour le sous-réseau privé
variable "private_subnet_cidr" {
  description = "Bloc CIDR pour le sous-réseau privé"
  type = string
  default = "10.0.2.0/24"
}

variable "private_subnet_az" {
  description = "Zone de disponibilité pour le sous-réseau privé"
  type = string
  default = "eu-west-3"
}