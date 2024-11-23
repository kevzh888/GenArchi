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

    # Créer le fichier pour stress tester l'app
    cat > /usr/local/bin/stressTester.py << 'SCRIPT'
    import concurrent.futures
    import time
    import math

    def cpu_intensive_task(duration):
      end_time = time.time() + duration
      result = 0
      while time.time() < end_time:
        result += math.factorial(100)
      return result

    def stress_test(cpu_cores, duration):
      print(f"Starting CPU stress test with {cpu_cores} cores for {duration} seconds...")
      start_time = time.time()
        
      with concurrent.futures.ThreadPoolExecutor(max_workers=cpu_cores) as executor:
        futures = [executor.submit(cpu_intensive_task, duration) for _ in range(cpu_cores)]
        concurrent.futures.wait(futures)

      elapsed_time = time.time() - start_time
      print(f"Stress test completed in {elapsed_time:.2f} seconds.")

    if __name__ == "__main__":
      cpu_cores = int(input("Enter the number of CPU cores to stress: "))
      duration = int(input("Enter the duration of the stress test in seconds: "))
        
      stress_test(cpu_cores, duration)
    SCRIPT

    # Make the stressTester.py file executable
    chmod +x /usr/local/bin/stressTester.py

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

resource "aws_autoscaling_policy" "cpu_target_scaling" {
  name                   = "cpu-scaling-policy"
  autoscaling_group_name = aws_autoscaling_group.web_asg.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 75.0
  }
}

