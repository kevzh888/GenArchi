resource "aws_lb" "app_lb" {
  name               = var.lb_name
  internal           = var.lb_internal
  load_balancer_type = var.lb_type
  security_groups    = [var.app_sg_id]
  subnets            = [var.public_subnet_id_1, var.public_subnet_id_2]

  tags = {
    Name = var.lb_tag_name
  }
}

resource "aws_lb_target_group" "app_target_group" {
  name     = var.target_group_name
  port     = var.target_group_port
  protocol = var.target_group_protocol
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  default_action {
    type             = var.listener_action_type
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }
}