# Create a new load balancer
resource "aws_elb" "frontend_elb" {
  name               = "frontend-elb"
  availability_zones = ["eu-west-3a", "eu-west-3b", "eu-west-3c"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8000/"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "frontend-elb"
  }
}