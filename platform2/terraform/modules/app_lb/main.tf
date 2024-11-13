resource "aws_lb" "app_lb" {
  name               = var.lb_name
  internal           = false  # Load balancer public
  load_balancer_type = "application"
  security_groups    = [var.app_sg_id]
  subnets           = [var.public_subnet_id_1, var.public_subnet_id_2]

  enable_deletion_protection = false

  tags = {
    Name = var.lb_tag_name
  }
}

resource "aws_lb_target_group" "app_target_group" {
  name     = var.target_group_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 15
    matcher            = "200"
    path               = "/"
    port               = "traffic-port"
    protocol           = "HTTP"
    timeout            = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.target_group_name}-tg"
  }
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port             = 80
  protocol         = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }
}