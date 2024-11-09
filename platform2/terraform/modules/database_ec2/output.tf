#output "db_shard_ips" {
#    description = "IP addresses of database shard servers"
#    value       = aws_instance.db_shard.*.public_ip
#}

output "db_instance_private_ip" {
  value = aws_instance.db_instance.private_ip
}

output "db_instance_public_ip" {
  value = aws_instance.db_instance.public_ip
}