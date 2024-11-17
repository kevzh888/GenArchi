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
    # Update and install dependencies
    sudo apt update -y
    sudo apt install -y curl
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt install -y nginx nodejs

    # Set environment variables
    echo "export DB_INSTANCE_1_IP='${var.db_ip_1}'" >> /etc/profile.d/db_env.sh
    echo "export DB_INSTANCE_2_IP='${var.db_ip_2}'" >> /etc/profile.d/db_env.sh
    source /etc/profile.d/db_env.sh

    # Create application directory
    mkdir -p /var/www/app
    cd /var/www/app

    # Initialize Node.js application
    npm init -y
    npm install express cors body-parser mysql2

    # Create Express server file
    echo 'const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");
const mysql = require("mysql2/promise");

const app = express();
app.use(cors());
app.use(bodyParser.json());

// Database configuration
const dbConfig = {
  host: process.env.DB_INSTANCE_1_IP,
  user: "app_user",
  password: "app_password",
  database: "quotes_db"
};

// Test endpoint
app.get("/api/test", (req, res) => {
  res.json({ message: "API is working!" });
});

// Add quote endpoint
app.post("/api/quotes", async (req, res) => {
  try {
    const connection = await mysql.createConnection(dbConfig);
    const { quote } = req.body;
    
    if (!quote) {
      return res.status(400).json({ error: "Quote is required" });
    }

    await connection.execute(
      "INSERT INTO quotes (content, created_at) VALUES (?, NOW())",
      [quote]
    );

    await connection.end();
    res.status(201).json({ message: "Quote added successfully" });
  } catch (error) {
    console.error("Error:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});

const PORT = 3000;
app.listen(PORT, "0.0.0.0", () => {
  console.log("Server running on port " + PORT);
});' > /var/www/app/server.js

    # Create systemd service file
    echo '[Unit]
Description=Node.js Quote Application
After=network.target

[Service]
Environment=DB_INSTANCE_1_IP=${var.db_ip_1}
Environment=DB_INSTANCE_2_IP=${var.db_ip_2}
Type=simple
User=root
WorkingDirectory=/var/www/app
ExecStart=/usr/bin/node server.js
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target' > /etc/systemd/system/nodeapp.service

    # Configure Nginx
    echo 'server {
    listen 80;
    server_name _;

    location /api/ {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 90;
        proxy_cache_bypass $http_upgrade;
    }

    location = /api {
        return 302 /api/;
    }

    # Basic status page
    location = /status {
        return 200 "online";
        add_header Content-Type text/plain;
    }
}' > /etc/nginx/sites-available/default

    # Enable and start services
    systemctl daemon-reload
    systemctl enable nodeapp
    systemctl start nodeapp
    systemctl enable nginx
    systemctl restart nginx

    # Add some basic logging
    echo "Installation completed at $(date)" >> /var/log/app-install.log
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