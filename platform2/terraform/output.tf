output "db_nlb_dns"{
  value = module.database_nlb.dns_name
}

output "db_master_eip"{
  value = module.database_eip.master_eip_public_ip
}

output "web_url" {
  value = "http://${module.web_lb.dns_name}"
  description = "L'URL du load balancer de notre site web"
}