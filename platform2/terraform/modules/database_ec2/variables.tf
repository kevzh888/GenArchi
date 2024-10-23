# Variables pour le réseau
variable "public_subnet_id" { #FIXME
  description = "ID du sous-réseau public"
  type = string
}

variable "db_sg_id" {
  description = "ID du groupe de sécurité pour la base de données"
  type = string
}

# Variables pour l'instance de base de données
variable "db_ami_id" {
  description = "ID de l'AMI pour l'instance de base de données"
  type        = string
  default     = "ami-045a8ab02aadf4f88"
}

variable "db_instance_type" {
  description = "Type d'instance pour la base de données"
  type        = string
  default     = "t2.micro"
}

variable "db_instance_name" {
  description = "Nom de l'instance de base de données"
  type        = string
  default     = "db-instance"
}