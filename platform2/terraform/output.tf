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

/* output "website_url" {
  description = "URL of the website on the S3"
  value       = module.static_site.website_endpoint
}*/

output "web_url" {
  value = "http://${module.web_lb.dns_name}"
  description = "L'URL du load balancer de notre site web"
}