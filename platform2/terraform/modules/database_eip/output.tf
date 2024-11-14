output "master_eip_id" {
  value = aws_eip.master_eip.id
}

output "slave_eip_id" {
  value = aws_eip.slave_eip.id
}