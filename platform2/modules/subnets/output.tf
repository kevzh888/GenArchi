output "public_subnet_id_1" {
  value = aws_subnet.public_subnet[0].id
}

output "public_subnet_id_2" {
  value = aws_subnet.public_subnet[1].id
}

output "private_subnet_id" {
  value = aws_subnet.private_subnet.id
}