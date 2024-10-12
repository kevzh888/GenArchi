# Variable pour le VPC
variable "vpc_id" {
  description = "ID du VPC"
  type = string
}

# Variables pour le groupe de sécurité web
variable "web_ingress_from_port" {
  description = "Port de départ pour l'ingress du groupe de sécurité web"
  type        = number
  default     = 80
}

variable "web_ingress_to_port" {
  description = "Port de fin pour l'ingress du groupe de sécurité web"
  type        = number
  default     = 80
}

variable "web_ingress_protocol" {
  description = "Protocole pour l'ingress du groupe de sécurité web"
  type        = string
  default     = "tcp"
}

variable "web_ingress_cidr_blocks" {
  description = "Blocs CIDR autorisés pour l'ingress du groupe de sécurité web"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "web_sg_name" {
  description = "Nom du groupe de sécurité web"
  type        = string
  default     = "web_sg"
}

# Variables pour le groupe de sécurité app
variable "app_ingress_from_port" {
  description = "Port de départ pour l'ingress du groupe de sécurité app"
  type        = number
  default     = 80
}

variable "app_ingress_to_port" {
  description = "Port de fin pour l'ingress du groupe de sécurité app"
  type        = number
  default     = 80
}

variable "app_ingress_protocol" {
  description = "Protocole pour l'ingress du groupe de sécurité app"
  type        = string
  default     = "tcp"
}

variable "app_sg_name" {
  description = "Nom du groupe de sécurité app"
  type        = string
  default     = "app_sg"
}

# Variable pour le groupe de sécurité db
variable "db_sg_name" {
  description = "Nom du groupe de sécurité db"
  type        = string
  default     = "db_sg"
}
