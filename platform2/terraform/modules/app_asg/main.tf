//app_asg/main.tf

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
    exec > /tmp/user-data.log 2>&1
    set -x
    
    # Update and install dependencies
    sudo apt-get update
    sudo apt-get install -y nginx nodejs npm

    echo "DB_INSTANCE_1_IP='${var.db_ip_1}'" >> /etc/profile.d/db_env.sh
    echo "DB_INSTANCE_2_IP='${var.db_ip_2}'" >> /etc/profile.d/db_env.sh
    source /etc/profile.d/db_env.sh
    
    # Create application directory
    sudo mkdir -p /var/www/app
    cd /var/www/app
    
    # Initialize npm and install dependencies
    npm init -y
    npm install express cors body-parser mysql2
    
    # Create server.js
    cat > /var/www/app/server.js << 'ENDSERVER'
    const express = require("express");
    const cors = require("cors");
    const bodyParser = require("body-parser");
    const mysql = require("mysql2/promise");
    const fs = require('fs');
    const app = express();

    app.use(cors());
    app.use(bodyParser.json());

    function getDatabaseIPs() {
      try {
        const envContent = fs.readFileSync('/etc/profile.d/db_env.sh', 'utf8');
        const matches = {
          primary: envContent.match(/DB_INSTANCE_1_IP='(.+?)'/)?.[1],
          secondary: envContent.match(/DB_INSTANCE_2_IP='(.+?)'/)?.[1]
        };
        return matches;
      } catch (error) {
        console.error('Error reading database IPs:', error);
        return { primary: 'localhost', secondary: 'localhost' };
      }
    }

    const dbIPs = getDatabaseIPs();

    const dbConfig = {
      host: dbIPs.primary,
      user: 'root',
      database: 'quotes_db',
      waitForConnections: true,
      connectionLimit: 10,
      queueLimit: 0
    };

    const pool = mysql.createPool(dbConfig);

    async function initializeDb() {
      try {
        const connection = await pool.getConnection();
        await connection.query('CREATE DATABASE IF NOT EXISTS quotes_db');
        await connection.query('USE quotes_db');
        await connection.query(`
          CREATE TABLE IF NOT EXISTS quotes (
            id INT AUTO_INCREMENT PRIMARY KEY,
            text TEXT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
          )
        `);
        connection.release();
        console.log('Database initialized successfully');
      } catch (error) {
        console.error('Error initializing database:', error);
        if (dbIPs.secondary) {
          console.log('Attempting to connect to secondary database...');
          dbConfig.host = dbIPs.secondary;
          await initializeDb();
        }
      }
    }

    initializeDb();

    app.get("/api/test", (req, res) => {
      res.json({ message: "API is working!" });
    });

    app.get("/api/quotes", async (req, res) => {
      try {
        const [rows] = await pool.query('SELECT * FROM quotes ORDER BY created_at DESC');
        res.json(rows);
      } catch (error) {
        console.error('Error fetching quotes:', error);
        if (dbIPs.secondary && dbConfig.host !== dbIPs.secondary) {
          dbConfig.host = dbIPs.secondary;
          try {
            const [rows] = await pool.query('SELECT * FROM quotes ORDER BY created_at DESC');
            res.json(rows);
          } catch (secondaryError) {
            res.status(500).json({ error: 'Failed to fetch quotes from both databases' });
          }
        } else {
          res.status(500).json({ error: 'Failed to fetch quotes' });
        }
      }
    });

    app.post("/api/quotes", async (req, res) => {
      const { quote } = req.body;
      
      if (!quote) {
        return res.status(400).json({ error: 'Quote text is required' });
      }

      try {
        const [result] = await pool.query(
          'INSERT INTO quotes (text) VALUES (?)',
          [quote]
        );
        res.status(201).json({ id: result.insertId, text: quote });
      } catch (error) {
        console.error('Error adding quote:', error);
        if (dbIPs.secondary && dbConfig.host !== dbIPs.secondary) {
          dbConfig.host = dbIPs.secondary;
          try {
            const [result] = await pool.query(
              'INSERT INTO quotes (text) VALUES (?)',
              [quote]
            );
            res.status(201).json({ id: result.insertId, text: quote });
          } catch (secondaryError) {
            res.status(500).json({ error: 'Failed to add quote to both databases' });
          }
        } else {
          res.status(500).json({ error: 'Failed to add quote' });
        }
      }
    });

    const PORT = process.env.PORT || 3000;
    app.listen(PORT, "0.0.0.0", () => {
      console.log(`Server running on port` + PORT);
    });
    ENDSERVER

    # Set proper permissions
    sudo chown -R ubuntu:ubuntu /var/www/app
    
    # Create systemd service
    cat > /etc/systemd/system/nodeapp.service << 'ENDSERVICE'
    [Unit]
    Description=Node.js Quote Application
    After=network.target

    [Service]
    Type=simple
    User=ubuntu
    WorkingDirectory=/var/www/app
    ExecStart=/usr/bin/node server.js
    Restart=always
    Environment=NODE_ENV=production

    [Install]
    WantedBy=multi-user.target
    ENDSERVICE

    # Configure Nginx
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

    # Start services
    sudo systemctl daemon-reload
    sudo systemctl enable nodeapp
    sudo systemctl start nodeapp
    sudo systemctl restart nginx
    
    # Log completion
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
