# Variable pour l'ID du VPC contenant les sous-réseaux
variable "vpc-id" {
  type        = string
  description = "Id of the VPC containing the subnets."
}

# Variable pour l'ID de la table de routage des sous-réseaux
variable "route-table-id" {
  type        = string
  description = "Id of the route table of the subnets."
}