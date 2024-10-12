resource "aws_launch_template" "web_launch_template" {
  name_prefix   = var.launch_template_name_prefix
  image_id      = var.instance_ami
  instance_type = var.instance_type
  
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = var.instance_tag_name
    }
  }
}

resource "aws_autoscaling_group" "web_asg" {
  desired_capacity = var.asg_desired_capacity
  max_size = var.asg_max_size
  min_size = var.asg_min_size
  vpc_zone_identifier = [var.public_subnet_id]

  launch_template {
    id = aws_launch_template.web_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = var.asg_tag_name
    propagate_at_launch = true
  }
}
