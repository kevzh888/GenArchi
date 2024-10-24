variable "var_aws_region" {
  description = "The AWS region to deploy resources."
  type        = string
  default     = "eu-west-3"
}

variable "var_aws_access_key" {
  description = "The AWS access key."
  type        = string

}

variable "var_aws_secret_key" {
  description = "The AWS secret key."
  type        = string
}
