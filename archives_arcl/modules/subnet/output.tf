# Sortie pour l'ID du sous-réseau 1
output "subnet1_id" {
  description = "Id of the Subnet1"
  value       = aws_subnet.subnet1.id
}

# Sortie pour l'ID du sous-réseau 2
output "subnet2_id" {
  description = "Id of the Subnet2"
  value       = aws_subnet.subnet2.id
}

# Sortie pour l'ID du sous-réseau 3
output "subnet3_id" {
  description = "Id of the Subnet3"
  value       = aws_subnet.subnet2.id
}
