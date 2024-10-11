data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = var.private-key-name # Create "myKey" to AWS!!
  public_key = tls_private_key.pk.public_key_openssh

  provisioner "local-exec" { # Create "myKey.pem" to your computer
    command = <<EOF
      rm -f ./misc/shared_ssh.pem 2> /dev/null
      echo '${tls_private_key.pk.private_key_pem}' > ./misc/shared_ssh.pem
      chmod 400 ./misc/shared_ssh.pem
    EOF
  }

}

resource "aws_launch_template" "template" {
  image_id               = "ami-09837f29678e3dbf0"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [var.web-server-sg-id]
  description            = "Default free tier template"
  key_name               = aws_key_pair.kp.key_name
  /*user_data = base64encode(file("./misc/user_data.sh"))*/
}

resource "aws_lb_target_group" "frontend_target_group" {
  name        = "frontend-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc-id
  target_type = "instance"
  health_check {
    port                = "traffic-port"
    path                = "/wordpress/wp-admin/install.php"
    interval            = 5
    timeout             = 2
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  load_balancing_algorithm_type = "round_robin"
}

resource "aws_autoscaling_group" "autoscaling_group" {
  name                 = var.autoscaling-group-name
  desired_capacity     = 2
  max_size             = 2
  min_size             = 2
  health_check_type    = "EC2"
  termination_policies = ["OldestInstance"]
  target_group_arns    = [aws_lb_target_group.frontend_target_group.arn]
  vpc_zone_identifier  = var.subnet-id-list

  launch_template {
    id      = aws_launch_template.template.id
    version = aws_launch_template.template.latest_version
  }
}