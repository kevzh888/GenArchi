# Variable pour définir le nom du groupe de sécurité
# Cette variable permet de personnaliser le nom du groupe de sécurité lors de sa création
variable "security-group-name" {
  description = "Name of the Security Group"
  type        = string
  default     = "web-server-security-group"
}

# Variable pour définir la description du groupe de sécurité
# Cette variable permet d'ajouter une description détaillée au groupe de sécurité
variable "security-group-description" {
  description = "Description of the Security Group"
  type        = string
  default     = "Security group for web servers"
}

# Variable pour spécifier l'ID du VPC associé au groupe de sécurité
# Cette variable est cruciale pour associer le groupe de sécurité au bon VPC
variable "vpc-id" {
  description = "Id of the default vpc"
  type        = string
}

# Note : Ces variables sont utilisées dans le fichier main.tf du module security_group
# pour configurer les propriétés du groupe de sécurité AWS créé