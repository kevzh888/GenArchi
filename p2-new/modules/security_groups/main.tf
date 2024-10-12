resource "aws_security_group" "web_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = var.web_ingress_from_port
    to_port     = var.web_ingress_to_port
    protocol    = var.web_ingress_protocol
    cidr_blocks = var.web_ingress_cidr_blocks
  }

  tags = {
    Name = var.web_sg_name
  }
}

resource "aws_security_group" "app_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port       = var.app_ingress_from_port
    to_port         = var.app_ingress_to_port
    protocol        = var.app_ingress_protocol
    security_groups = [aws_security_group.web_sg.id]
  }

  tags = {
    Name = var.app_sg_name
  }
}

resource "aws_security_group" "db_sg" {
  vpc_id = var.vpc_id

  tags = {
    Name = var.db_sg_name
  }
}