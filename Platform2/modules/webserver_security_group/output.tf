output "sg_id" {
  description = "Default security id group for Webserver"
  value       = aws_security_group.web_server_sg.id
}
