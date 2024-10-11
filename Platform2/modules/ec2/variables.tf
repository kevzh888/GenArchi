variable "default-ami" {
  type        = string
  description = "Default ami used to create our EC2 instance."
}

variable "instance-type" {
  type        = string
  description = "Instance type of the created EC2 ressource."
}

variable "instance-name" {
  type        = string
  description = "Name of the created EC2 ressource."
}


