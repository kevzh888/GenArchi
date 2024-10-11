variable "security-group" {
  description = "Security group used in ALB"
  type        = string
}

variable "subnet-id-list" {
  description = "List of subnets id where the ALB is going to be deployed."
  type        = list(string)
}


variable "target-group-arn" {
  description = "Group targetted by the ALB?"
  type        = string
}