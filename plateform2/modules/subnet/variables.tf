variable "vpc-id" {
  type        = string
  description = "Id of the VPC containing the subnets."
}

variable "route-table-id" {
  type        = string
  description = "Id of the route table of the subnets."
}