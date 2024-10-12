variable "public_subnet_id" {
  description = "ID du sous-réseau public"
  type = string
}

variable "web_sg_id" {
  description = "ID du groupe de sécurité Web"
  type = string
}

resource "aws_launch_template" "web_launch_template" {
  name_prefix   = "web-"
  image_id      = "ami-0c55b159cbfafe1f0"  # Choisir une AMI appropriée
  instance_type = "t2.micro"
  
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "web-instance"
    }
  }
}

resource "aws_autoscaling_group" "web_asg" {
  desired_capacity = 2
  max_size = 3
  min_size = 1
  vpc_zone_identifier = [var.public_subnet_id]

  launch_template {
    id = aws_launch_template.web_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "web-asg"
    propagate_at_launch = true
  }
}
