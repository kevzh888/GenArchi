# Variables pour le VPC et les ressources réseau
variable "vpc_id" {
  description = "L'ID du VPC"
  type        = string
}

variable "app_sg_id" {
  description = "L'ID du groupe de sécurité pour le tiers app"
  type        = string
}

variable "public_subnet_id_1" {
  description = "L'ID du sous-réseau public 1"
  type        = string
}

variable "public_subnet_id_2" {
  description = "L'ID du sous-réseau public 2"
  type        = string
}

# Variables pour le Load Balancer
variable "lb_name" {
  description = "Nom du Load Balancer"
  type        = string
  default     = "app-lb"
}

variable "lb_internal" {
  description = "Si le Load Balancer est interne ou non"
  type        = bool
  default     = false
}

variable "lb_type" {
  description = "Type de Load Balancer"
  type        = string
  default     = "application"
}

variable "lb_tag_name" {
  description = "Nom du tag pour le Load Balancer"
  type        = string
  default     = "app_lb"
}

# Variables pour le groupe cible
variable "target_group_name" {
  description = "Nom du groupe cible"
  type        = string
  default     = "app-tg"
}

variable "target_group_port" {
  description = "Port du groupe cible"
  type        = number
  default     = 80
}

variable "target_group_protocol" {
  description = "Protocole du groupe cible"
  type        = string
  default     = "HTTP"
}

# Variables pour le listener
variable "listener_port" {
  description = "Port du listener"
  type        = number
  default     = 80
}

variable "listener_protocol" {
  description = "Protocole du listener"
  type        = string
  default     = "HTTP"
}

variable "listener_action_type" {
  description = "Type d'action du listener"
  type        = string
  default     = "forward"
}
