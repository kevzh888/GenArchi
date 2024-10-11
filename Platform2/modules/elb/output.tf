output "frontend-elb-id" {
    description = "Frontend Application Loadbalancer id"
    value = aws_elb.frontend_elb.id
}