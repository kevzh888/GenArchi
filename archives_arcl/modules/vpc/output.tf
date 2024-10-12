output "vpc-id" {
  description = "Default VPC id."
  value       = aws_vpc.vpc.id
}

output "route-table-id" {
  description = "Route table id"
  value       = aws_route_table.default_route_table.id
}
