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

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.web_sg_id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              # Mises à jour et installation de dépendances
              sudo apt update -y
              sudo apt install -y nginx

              # Copie du fichier index.html
              echo "<html><body><h1>Bienvenue sur mon site</h1></body></html>" > /var/www/html/index.html

              # Démarrer et activer Nginx
              sudo systemctl start nginx
              sudo systemctl enable nginx
              EOF
  )
}

resource "aws_autoscaling_group" "web_asg" {
  desired_capacity   = var.asg_desired_capacity
  max_size           = var.asg_max_size
  min_size           = var.asg_min_size
  vpc_zone_identifier = [var.public_subnet_id_1, var.public_subnet_id_2]

  launch_template {
    id      = aws_launch_template.web_launch_template.id
    version = aws_launch_template.web_launch_template.latest_version
  }

  target_group_arns = [var.target_group_arn]  # ARN du Target Group passé comme variable

  tag {
    key                 = "Name"
    value               = var.asg_tag_name
    propagate_at_launch = true
  }
}
