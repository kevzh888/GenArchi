# Variables pour le réseau
variable "public_subnet_id_1" {
  description = "ID du sous-réseau public 1"
  type = string
}

variable "public_subnet_id_2" {
  description = "ID du sous-réseau public 2"
  type = string
}

variable "web_sg_id" {
  description = "ID du groupe de sécurité Web"
  type = string
}

# Variables pour le modèle de lancement
variable "launch_template_name_prefix" {
  description = "Préfixe du nom du modèle de lancement"
  type = string
  default = "web-"
}

variable "instance_ami" {
  description = "ID de l'AMI pour l'instance"
  type = string
  default = "ami-0a3598a00eff32f66"
}

variable "instance_type" {
  description = "Type d'instance EC2"
  type = string
  default = "t2.micro"
}

variable "instance_tag_name" {
  description = "Nom de l'étiquette pour l'instance"
  type = string
  default = "web-instance"
}

# Variables pour l'Auto Scaling Group
variable "asg_desired_capacity" {
  description = "Capacité souhaitée pour l'ASG"
  type = number
  default = 2
}

variable "asg_max_size" {
  description = "Taille maximale pour l'ASG"
  type = number
  default = 3
}

variable "asg_min_size" {
  description = "Taille minimale pour l'ASG"
  type = number
  default = 1
}

variable "asg_tag_name" {
  description = "Nom de l'étiquette pour l'ASG"
  type = string
  default = "web-asg"
}