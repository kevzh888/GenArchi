output "master_eip_id" {
  value = aws_eip.master_eip.id
}

output "master_eip_public_ip" {
  value = aws_eip.master_eip.public_ip
}