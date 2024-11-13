resource "aws_launch_template" "app_launch_template" {
  name_prefix = "app-"
  image_id = var.app_ami_id
  instance_type = var.app_instance_type

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "app-instance"
    }
  }

  # Configurer l'interface réseau avec IP publique
  network_interfaces {
    associate_public_ip_address = true
    security_groups = [var.app_sg_id]
    delete_on_termination = true
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    # Mettre à jour le système et installer nginx
    apt-get update
    apt-get install -y nginx

    # Créer une page HTML simple
    cat > /var/www/html/index.html << 'END'
    <!DOCTYPE html>
    <html>
    <head>
        <title>Hello World App</title>
    </head>
    <body>
        <h1>Hello World from App Server!</h1>
        <p>Server is running successfully.</p>
    </body>
    </html>
    END

    # S'assurer que nginx est démarré et activé
    systemctl enable nginx
    systemctl start nginx

    # Configurer nginx pour écouter sur le port 80
    cat > /etc/nginx/sites-available/default << 'END'
    server {
        listen 80 default_server;
        listen [::]:80 default_server;
        
        root /var/www/html;
        index index.html;
        
        server_name _;
        
        location / {
            try_files $uri $uri/ =404;
            add_header 'Access-Control-Allow-Origin' '*';
            add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
            add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range';
        }
    }
    END

    # Redémarrer nginx pour appliquer la configuration
    systemctl restart nginx
  EOF
  )
}

resource "aws_autoscaling_group" "app_asg" {
  desired_capacity = var.app_desired_capacity
  max_size = var.app_max_size
  min_size = var.app_min_size
  target_group_arns = [var.target_group_arn]
  vpc_zone_identifier = [var.public_subnet_id_1, var.public_subnet_id_2]
  
  launch_template {
    id = aws_launch_template.app_launch_template.id
    version = "$Latest"
  }
  
  health_check_type = "ELB"
  health_check_grace_period = var.app_health_check_grace_period

  tag {
    key = "Name"
    value = "app-asg"
    propagate_at_launch = true
  }
}