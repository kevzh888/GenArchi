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

  ingress {
    from_port   = var.db_ingress_ssh_from_port
    to_port     = var.db_ingress_ssh_to_port
    protocol    = var.db_ingress_ssh_protocol
    cidr_blocks = var.db_ingress_ssh_cidr_blocks
  }

  # Règle de sortie pour autoriser tout le trafic sortant par défaut
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.db_sg_name
  }
}