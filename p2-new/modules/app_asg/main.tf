
# Template de lancement pour les instances du tiers App
resource "aws_launch_template" "app_launch_template" {
  name_prefix   = "app-"
  image_id      = "ami-0c55b159cbfafe1f0"  # Remplacer par l'AMI appropriée
  instance_type = "t2.micro"

  # Les tags pour identifier les instances
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "app-instance"
    }
  }

  # Groupes de sécurité pour les instances
  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.app_sg_id]
  }

  # User data pour configurer l'application lors du lancement
  user_data = base64encode(<<-EOF
              #!/bin/bash
              # Mises à jour et installation de dépendances
              sudo apt update -y
              sudo apt install -y nginx
              sudo systemctl start nginx
              # Script de déploiement de l'application peut être ajouté ici
              EOF
  )
}

# Auto Scaling Group pour gérer la mise à l'échelle automatique
resource "aws_autoscaling_group" "app_asg" {
  desired_capacity     = 2   # Nombre d'instances souhaitées
  max_size             = 3   # Nombre maximal d'instances
  min_size             = 1   # Nombre minimal d'instances
  vpc_zone_identifier  = [var.private_subnet_id]  # Sous-réseau privé

  launch_template {
    id      = aws_launch_template.app_launch_template.id
    version = "$Latest"
  }

  # Health checks pour les instances
  health_check_type         = "EC2"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "app-asg"
    propagate_at_launch = true
  }
}

# Politique de mise à l'échelle : Basée sur l'utilisation du CPU
resource "aws_autoscaling_policy" "app_cpu_policy" {
  name                   = "app-cpu-policy"
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
  policy_type            = "TargetTrackingScaling"
  
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60.0  # Mise à l'échelle si l'utilisation CPU dépasse 60%
  }
}

# Output pour l'ID de l'Auto Scaling Group
output "app_asg_id" {
  value = aws_autoscaling_group.app_asg.id
}
