# modules/nlb/variables.tf

variable "subnet_ids" {
  description = "Les subnets dans lesquels le NLB sera déployé"
  type        = list(string)
}

variable "vpc_id" {
  description = "L'ID du VPC dans lequel le NLB sera déployé"
  type        = string
}
