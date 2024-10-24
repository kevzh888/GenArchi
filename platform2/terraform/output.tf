# IP db instance 1
output "db_instance_private_ip" {
  value = module.database_ec2.db_instance_private_ip
}

output "db_instance_public_ip" {
  value = module.database_ec2.db_instance_public_ip
}

# IP db instance 2 
output "db_instance_private_ip_2" {
  value = module.database_ec2_2.db_instance_private_ip
}

output "db_instance_public_ip_2" {
  value = module.database_ec2_2.db_instance_public_ip
}