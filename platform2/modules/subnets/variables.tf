# Variable pour le VPC
variable "vpc_id" {
  description = "ID du VPC"
  type = string
}

# Variable pour l'internet gateway
variable "igw_id" {
  description = "ID de l'IGW"
  type = string
}

variable "vpc_cidr_block"{
  description = "CIDR block du VPC"
  type = string
  default = "10.0.0.0/16"
}

# Variables pour le sous-réseau public 1
/*variable "public_subnet_cidr_1" {
  description = "Bloc CIDR pour le sous-réseau public 1"
  type = string
  default = "10.0.1.0/24"
}*/

variable "public_subnet_az_1" {
  description = "Zone de disponibilité pour le sous-réseau public 1"
  type = string
  default = "eu-west-3a"
}

# Variables pour le sous-réseau public 2
/*variable "public_subnet_cidr_2" {
  description = "Bloc CIDR pour le sous-réseau public 2"
  type = string
  default = "10.0.3.0/24"
}*/

variable "public_subnet_az_2" {
  description = "Zone de disponibilité pour le sous-réseau public 2"
  type = string
  default = "eu-west-3b"
}

# Variables pour le sous-réseau privé
variable "private_subnet_cidr" {
  description = "Bloc CIDR pour le sous-réseau privé"
  type = string
  default = "10.0.2.0/24"
}

variable "private_subnet_az_1" {
  description = "Zone de disponibilité pour le sous-réseau privé 1"
  type = string
  default = "eu-west-3a"
}

variable "private_subnet_az_2" {
  description = "Zone de disponibilité pour le sous-réseau privé 2"
  type = string
  default = "eu-west-3b"
}