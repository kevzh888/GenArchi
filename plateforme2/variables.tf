variable "ubuntu-2204" {
  type        = string
  default     = "ami-00c71bd4d220aa22a"
  description = "Variable that stores Ubuntu 22.04 eu-west-3 AMI code"
}

variable "default-region" {
  type        = string
  default     = "eu-west-3"
  description = "Default region used for creating our AWS ressources."
}