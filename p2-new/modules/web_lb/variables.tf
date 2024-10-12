variable "vpc_id" {
  description = "L'ID du VPC"
  type        = string
}

variable "web_sg_id" {
  description = "L'ID du groupe de sécurité pour le tiers Web"
  type        = string
}

variable "public_subnet_id" {
  description = "L'ID du sous-réseau public"
  type        = string
}