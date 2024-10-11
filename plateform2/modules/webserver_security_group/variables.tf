variable "security-group-name" {
  description = "Name of the Security Group"
  type        = string
  default     = "web-server-security-group"
}

variable "security-group-description" {
  description = "Description of the Security Group"
  type        = string
  default     = "Security group for web servers"
}

variable "vpc-id" {
  description = "Id of the default vpc"
  type        = string
}