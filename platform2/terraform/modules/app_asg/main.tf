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
    # Enable detailed logging
    exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
    echo "Starting user data script execution..."

    # Update and install dependencies
    echo "Updating system packages..."
    sudo apt-get update
    sudo apt-get install -y curl
    
    # Install Node.js 20.x
    echo "Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs nginx

    # Verify installations
    echo "Node.js version: $(node --version)"
    echo "NPM version: $(npm --version)"

    # Create application directory
    echo "Creating application directory..."
    sudo mkdir -p /var/www/app
    cd /var/www/app
    
    # Initialize npm and install dependencies
    echo "Initializing npm project..."
    npm init -y
    echo "Installing npm dependencies..."
    npm install express cors body-parser mysql2

    # Create server.js
    echo "Creating server.js..."
    cat > /var/www/app/server.js << 'ENDSERVER'
    const express = require("express");
    const cors = require("cors");
    const bodyParser = require("body-parser");
    const mysql = require("mysql2/promise");
    const app = express();

    // Initialize server middleware
    app.use(cors());
    app.use(bodyParser.json());

    // Global connection flag
    let isDbInitialized = false;
    let globalPool = null;

    const dbConfig = {
      host: '${var.db_nlb_dns}',
      user: 'nodeapp',
      password: 'arcl',
      waitForConnections: true,
      connectionLimit: 10,
      queueLimit: 0,
      port: 3306
    };

    // Retry helper function
    async function retry(operation, retries = 5, delay = 2000) {
      let lastError;
      
      for (let attempt = 1; attempt <= retries; attempt++) {
        try {
          return await operation();
        } catch (error) {
          lastError = error;
          console.error(`Attempt failed:`, error.message);
          
          if (attempt < retries) {
            console.log(`Waiting ...ms before next attempt...`);
            await new Promise(resolve => setTimeout(resolve, delay));
            delay *= 1.5; // Increase delay for each retry
          }
        }
      }
      throw lastError;
    }

    // Database initialization
    async function initializeDatabase() {
      if (isDbInitialized && globalPool) {
        return globalPool;
      }

      console.log("Starting database initialization...");

      try {
        // Create initial connection to MySQL server
        const tempPool = mysql.createPool(dbConfig);
        const conn = await tempPool.getConnection();
        
        console.log("Connected to MySQL server");

        // Create and use the database
        await conn.query('CREATE DATABASE IF NOT EXISTS quotes_db');
        await conn.query('USE quotes_db');
        
        console.log("Created and selected quotes_db");

        // Create quotes table
        await conn.query(`
          CREATE TABLE IF NOT EXISTS quotes (
            id INT AUTO_INCREMENT PRIMARY KEY,
            text TEXT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
          )
        `);
        
        console.log("Quotes table created/verified");

        // Release initial connection
        conn.release();
        await tempPool.end();

        // Create the main connection pool with database selected
        const mainPool = mysql.createPool({
          ...dbConfig,
          database: 'quotes_db',
          multipleStatements: true
        });

        // Verify the main pool works
        const testConn = await mainPool.getConnection();
        await testConn.query('SELECT 1');
        testConn.release();

        globalPool = mainPool;
        isDbInitialized = true;
        console.log("Database initialization completed successfully");
        
        return mainPool;
      } catch (error) {
        console.error("Database initialization failed:", error);
        throw error;
      }
    }

    // Database middleware
    async function ensureDatabase(req, res, next) {
      if (!isDbInitialized || !globalPool) {
        try {
          await retry(initializeDatabase);
        } catch (error) {
          console.error("Database initialization failed in middleware:", error);
          return res.status(503).json({ 
            error: 'Database connection not available',
            details: error.message
          });
        }
      }
      next();
    }

    // Apply database middleware to all routes
    app.use(ensureDatabase);

    // Routes
    app.get("/api/health", (req, res) => {
      res.json({ 
        status: "healthy",
        dbInitialized: isDbInitialized
      });
    });

    app.get("/api/quotes", async (req, res) => {
      try {
        const [rows] = await globalPool.query('SELECT * FROM quotes ORDER BY created_at DESC');
        res.json(rows);
      } catch (error) {
        console.error('Error fetching quotes:', error);
        res.status(500).json({ error: 'Failed to fetch quotes' });
      }
    });

    app.post("/api/quotes", async (req, res) => {
      const { quote } = req.body;
      
      if (!quote) {
        return res.status(400).json({ error: 'Quote text is required' });
      }

      try {
        const [result] = await globalPool.query(
          'INSERT INTO quotes (text) VALUES (?)',
          [quote]
        );
        
        console.log('Quote added successfully:', { id: result.insertId, text: quote });
        res.status(201).json({ id: result.insertId, text: quote });
      } catch (error) {
        console.error('Error adding quote:', error);
        res.status(500).json({ error: 'Failed to add quote' });
      }
    });

    // Graceful shutdown
    process.on('SIGTERM', async () => {
      console.log('SIGTERM received. Closing connections...');
      if (globalPool) {
        await globalPool.end();
      }
      process.exit(0);
    });

    // Start server
    (async () => {
      try {
        // Initialize database with retries
        await retry(initializeDatabase);
        
        const PORT = process.env.PORT || 3000;
        app.listen(PORT, "0.0.0.0", () => {
          console.log(`Server running on port` + PORT);
        });
      } catch (error) {
        console.error('Failed to start server:', error);
        process.exit(1);
      }
    })();
    ENDSERVER

    # Set proper permissions
    echo "Setting permissions..."
    sudo chown -R ubuntu:ubuntu /var/www/app
    
    # Create systemd service
    echo "Creating systemd service..."
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
    RestartSec=10
    StandardOutput=append:/var/log/nodeapp.log
    StandardError=append:/var/log/nodeapp.error.log
    Environment=NODE_ENV=production

    [Install]
    WantedBy=multi-user.target
    ENDSERVICE

    # Create log files
    sudo touch /var/log/nodeapp.log /var/log/nodeapp.error.log
    sudo chown ubuntu:ubuntu /var/log/nodeapp.log /var/log/nodeapp.error.log
    
    # Configure Nginx
    echo "Configuring Nginx..."
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
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            
            # Add timeouts
            proxy_connect_timeout 60s;
            proxy_send_timeout 60s;
            proxy_read_timeout 60s;
        }
        
        # Add health check location
        location /health {
            proxy_pass http://localhost:3000/api/health;
        }
    }
    ENDNGINX

    # Enable and start services
    echo "Starting services..."
    sudo systemctl daemon-reload
    sudo systemctl enable nodeapp
    sudo systemctl start nodeapp
    sudo systemctl restart nginx

    # Verify services
    echo "Verifying services..."
    sudo systemctl status nodeapp
    sudo systemctl status nginx
    
    echo "Installation completed successfully"
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

