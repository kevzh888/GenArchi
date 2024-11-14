# modules/nlb/main.tf

resource "aws_lb" "mysql_nlb" {
  name               = "mysql-nlb"
  internal           = false
  load_balancer_type = "network"
  enable_deletion_protection = false
  security_groups    = [aws_security_group.mysql_sg.id]
  subnets            = var.subnet_ids
}

resource "aws_lb_target_group" "mysql_target_group" {
  name     = "mysql-target-group"
  port     = 3306
  protocol = "TCP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "mysql_listener" {
  load_balancer_arn = aws_lb.mysql_nlb.arn
  port              = 3306
  protocol          = "TCP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.mysql_target_group.arn
  }
}
