resource "aws_security_group" "web_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web_sg"
  }
}

resource "aws_security_group" "app_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  tags = {
    Name = "app_sg"
  }
}

resource "aws_security_group" "db_sg" {
  vpc_id = var.vpc_id

  tags = {
    Name = "db_sg"
  }
}

