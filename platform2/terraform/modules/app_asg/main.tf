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
  
  network_interfaces {
    associate_public_ip_address = true
    security_groups = [var.app_sg_id]
  }
  
  user_data = base64encode(<<-EOF
            #!/bin/bash

            # Log de débogage
            exec > /tmp/user-data.log 2>&1
            set -x

            # Mise à jour et installation des paquets
            sudo apt-get update
            sudo apt-get install -y nginx nodejs npm

            # Création du répertoire de l'application
            sudo mkdir -p /var/www/app
            cd /var/www/app

            # Installation des dépendances Node.js
            npm init -y
            npm install express cors body-parser mysql2

            # Création du fichier serveur
            cat > /var/www/app/server.js << 'ENDSERVER'
            const express = require("express");
            const cors = require("cors");
            const bodyParser = require("body-parser");
            const mysql = require("mysql2/promise");

            const app = express();
            app.use(cors());
            app.use(bodyParser.json());

            app.get("/api/test", (req, res) => {
            res.json({ message: "API is working!" });
            });

            const PORT = 3000;
            app.listen(PORT, "0.0.0.0", () => {
            console.log("Server running on port " + PORT);
            });
            ENDSERVER

            # Configuration du service Node.js
            cat > /etc/systemd/system/nodeapp.service << ENDSERVICE
            [Unit]
            Description=Node.js Quote Application
            After=network.target

            [Service]
            Type=simple
            User=ubuntu
            WorkingDirectory=/var/www/app
            ExecStart=/usr/bin/node server.js
            Restart=always

            [Install]
            WantedBy=multi-user.target
            ENDSERVICE

            # Configuration de Nginx
            cat > /etc/nginx/sites-available/default << 'ENDNGINX'
            server {
                listen 80;
                server_name _;

                location /api/ {
                    proxy_pass http://localhost:3000;
                    proxy_http_version 1.1;
                    proxy_set_header Upgrade \$http_upgrade;
                    proxy_set_header Connection "upgrade";
                    proxy_set_header Host \$host;
                }
            }
            ENDNGINX

            # Démarrage des services
            sudo systemctl daemon-reload
            sudo systemctl restart nginx
            sudo systemctl enable nodeapp
            sudo systemctl start nodeapp

            # Log final
            echo "Installation completed" > /tmp/installation-complete.log
            EOF
            )
}

resource "aws_autoscaling_group" "app_asg" {
  desired_capacity = var.app_desired_capacity
  max_size = var.app_max_size
  min_size = var.app_min_size
  vpc_zone_identifier = [var.public_subnet_id_1, var.public_subnet_id_2]
  
  launch_template {
    id = aws_launch_template.app_launch_template.id
    version = "$Latest"
  }
  
  target_group_arns = [var.target_group_arn]
  
  health_check_type = "EC2"
  health_check_grace_period = var.app_health_check_grace_period
  
  tag {
    key = "Name"
    value = "app-asg"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "app_cpu_policy" {
  name = "app-cpu-policy"
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
  policy_type = "TargetTrackingScaling"
  
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.app_cpu_target_value
  }
}