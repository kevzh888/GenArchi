# modules/asg/variables.tf

variable "ami_id" {
  description = "L'AMI ID des instances EC2 pour la database"
  type        = string
  default     = "ami-045a8ab02aadf4f88"
}

variable "instance_type" {
  description = "Type d'instance EC2 pour Master et Slave"
  type        = string
  default     = "t2.micro"
}

variable "region" {
  description = "Région d'où sont lancés les vms"
  type = string
  default = "eu-west-3"
}

variable "user_data" {
  description = "Le script User Data pour initialiser les instances"
  type        = string
  default     = ""
}

variable "desired_capacity" {
  description = "Nombre désiré d'instances dans l'Auto Scaling Group"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Taille maximale du groupe Auto Scaling"
  type        = number
  default     = 3
}

variable "min_size" {
  description = "Taille minimale du groupe Auto Scaling"
  type        = number
  default     = 1
}

variable "public_subnet_id_1" {
  description = "Le premier subnet public dans lesquels les instances ASG mysql slave seront lancées"
  type        = string
}

variable "public_subnet_id_2" {
  description = "Le deuxième subnet public dans lesquels les instances ASG mysql slave seront lancées"
  type        = string
}

variable "target_group_arn" {
  description = "ARN du Target Group pour attacher l'ASG Database"
  type        = string
}

variable "master_eip_id" {
  description = "ID de l'Elastic IP pour le master"
  type        = string
}

variable "master_eip_public_ip" {
  description = "Adresse IP publique de l'Elastic IP pour le master"
  type        = string
}

variable "db_sg_id" {
  description = "Security groups du tier Database"
  type = string
}

# Clés d'accès AWS
variable "aws_access_key" {
  description = "AWS Access Key"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
  type        = string
  sensitive   = true
}