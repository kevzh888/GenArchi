
# SSH
variable "private-key-name" {
  description = "Name of the Private SSH key"
  type        = string
  default     = "pk"
}

# Security Group
variable "web-server-sg-id" {
  description = "Security group of webservers"
  type        = string
}

# Autoscaling Group
variable "autoscaling-group-name" {
  description = "Name of the Auto Scaling Group"
  type        = string
  default     = "wordpress-autoscaling-group"
}
variable "autoscaling-group-az" {
  description = "Availability zones of Auto Scaling Group"
  type        = list(string)
  default     = ["eu-west-3a", "eu-west-3b", "eu-west-3c"]
}
variable "vpc-id" {
  description = "Id of the VPC containing the autoscaling group"
  type        = string
}

variable "ubuntu-image-location" {
  description = "Ubuntu image 22.04 location"
  type        = string
  default     = "ubuntu/images/hvm-ssd/ubuntu-focal-22.04-amd64-server-*"
}

variable "subnet-id-list" {
  description = "List of subnets id where the ALB is going to be deployed."
  type        = list(string)
}