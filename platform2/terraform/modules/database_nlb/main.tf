# modules/nlb/main.tf

resource "aws_lb" "mysql_nlb" {
  name               = var.lb_name
  internal           = var.lb_internal
  load_balancer_type = var.lb_type
  enable_deletion_protection = false
  security_groups    = [var.db_sg_id]
  subnets            = [var.public_subnet_id_1, var.public_subnet_id_2]
}

resource "aws_lb_target_group" "mysql_target_group" {
  name     = var.target_group_name
  port     = var.target_group_port
  protocol = var.target_group_protocol
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "mysql_listener" {
  load_balancer_arn = aws_lb.mysql_nlb.arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  default_action {
    type = var.listener_action_type
    target_group_arn = aws_lb_target_group.mysql_target_group.arn
  }
}
