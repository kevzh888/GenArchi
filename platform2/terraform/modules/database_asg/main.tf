# modules/asg/main.tf

resource "aws_launch_configuration" "mysql_config" {
  name          = "mysql-launch-config"
  image_id      = var.ami_id
  instance_type = var.instance_type
  security_groups = [aws_security_group.mysql_sg.id]
  user_data     = var.user_data
  associate_public_ip_address = false
}

resource "aws_autoscaling_group" "mysql_asg" {
  desired_capacity     = var.desired_capacity
  max_size             = var.max_size
  min_size             = var.min_size
  vpc_zone_identifier  = var.subnet_ids
  launch_configuration = aws_launch_configuration.mysql_config.id

  tag {
    key = "Name"
    value = "database-asg"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "mysql_sg" {
  name        = "mysql_sg"
  description = "Security group for MySQL instances"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
