# Variable pour définir l'AMI par défaut
# AMI (Amazon Machine Image) est une image préconfigurée utilisée pour lancer une instance EC2
variable "default-ami" {
  type        = string
  description = "Default ami used to create our EC2 instance."
}

# Variable pour spécifier le type d'instance EC2
variable "instance-type" {
  type        = string
  description = "Instance type of the created EC2 ressource."
}

# Variable pour définir le nom de l'instance EC2
variable "instance-name" {
  type        = string
  description = "Name of the created EC2 ressource."
}

# Note : Ces variables sont utilisées dans le module EC2 pour configurer les propriétés de base de l'instance EC2
