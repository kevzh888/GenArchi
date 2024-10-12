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
