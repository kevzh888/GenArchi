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
    delete_on_termination = true
  }

  user_data = base64encode(<<-EOF
#!/bin/bash
# Update system and install required packages
apt-get update
apt-get install -y nginx mysql-client python3 python3-pip

# Install Python packages
pip3 install flask flask-cors mysql-connector-python

# Create application directory
mkdir -p /var/www/app
mkdir -p /var/www/app/api

# Create the main HTML file
cat > /var/www/html/index.html << 'END'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Quotes App</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 20px;
        }
        h1 {
            color: #333;
        }
        .quote-form {
            margin-bottom: 20px;
        }
        .quote-form input {
            padding: 10px;
            font-size: 1rem;
            width: 300px;
        }
        .quote-form button {
            padding: 10px;
            background-color: #28a745;
            color: white;
            border: none;
            font-size: 1rem;
            cursor: pointer;
        }
        .quote-form button:hover {
            background-color: #218838;
        }
        ul {
            list-style-type: none;
            padding: 0;
        }
        li {
            background-color: #fff;
            padding: 10px;
            margin-bottom: 10px;
            border: 1px solid #ccc;
        }
    </style>
</head>
<body>
    <h1>Quotes App</h1>
    <div class="quote-form">
        <input type="text" id="new-quote" placeholder="Enter a new quote..." />
        <button onclick="addQuote()">Add Quote</button>
    </div>
    <h2>Quotes List</h2>
    <ul id="quotes-list"></ul>
    <script>
        // API endpoint
        const apiUrl = '/api/quotes';

        async function fetchQuotes() {
            try {
                const response = await fetch(apiUrl);
                const quotes = await response.json();
                const quotesList = document.getElementById("quotes-list");
                quotesList.innerHTML = quotes
                    .map((quote) => '<li>' + quote.quote + '</li>')
                    .join("");
            } catch (error) {
                console.error("Error fetching quotes:", error);
            }
        }

        async function addQuote() {
            const quoteInput = document.getElementById("new-quote");
            const newQuote = quoteInput.value;
            if (!newQuote) {
                alert("Please enter a quote.");
                return;
            }
            try {
                await fetch(apiUrl, {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json",
                    },
                    body: JSON.stringify({ quote: newQuote }),
                });
                quoteInput.value = "";
                fetchQuotes();
            } catch (error) {
                console.error("Error adding quote:", error);
            }
        }

        window.onload = fetchQuotes;
    </script>
</body>
</html>
END

# Create Flask API application
cat > /var/www/app/api/app.py << 'END'
from flask import Flask, request, jsonify
from flask_cors import CORS
import mysql.connector
import os

app = Flask(__name__)
CORS(app)

def get_db_connection():
    # Read database IPs from environment
    with open('/etc/profile.d/db_env.sh', 'r') as f:
        env_vars = dict(line.strip().split('=') for line in f if line.strip())
    
    db_host = env_vars.get('DB_INSTANCE_1_IP', '').strip('"')  # Primary DB
    
    return mysql.connector.connect(
        host=db_host,
        user="your_db_user",      # Replace with your DB username
        password="your_db_pass",  # Replace with your DB password
        database="quotes_db"
    )

@app.route('/api/quotes', methods=['GET'])
def get_quotes():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM quotes")
    quotes = cursor.fetchall()
    cursor.close()
    conn.close()
    return jsonify(quotes)

@app.route('/api/quotes', methods=['POST'])
def add_quote():
    data = request.json
    quote = data.get('quote')
    
    if not quote:
        return jsonify({"error": "Quote is required"}), 400
    
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("INSERT INTO quotes (quote) VALUES (%s)", (quote,))
    conn.commit()
    cursor.close()
    conn.close()
    
    return jsonify({"message": "Quote added successfully"}), 201

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
END

# Create systemd service for Flask API
cat > /etc/systemd/system/quotes-api.service << 'END'
[Unit]
Description=Quotes API Service
After=network.target

[Service]
User=www-data
WorkingDirectory=/var/www/app/api
ExecStart=/usr/bin/python3 app.py
Restart=always

[Install]
WantedBy=multi-user.target
END

# Configure nginx to proxy requests to the Flask API
cat > /etc/nginx/sites-available/default << 'END'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    root /var/www/html;
    index index.html;
    server_name _;

    location / {
        try_files $uri $uri/ =404;
    }

    location /api/ {
        proxy_pass http://localhost:5000/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
END

# Start and enable services
systemctl enable quotes-api
systemctl start quotes-api
systemctl enable nginx
systemctl restart nginx

# Create database table if it doesn't exist
mysql -h $(grep DB_INSTANCE_1_IP /etc/profile.d/db_env.sh | cut -d'"' -f2) -u your_db_user -pyour_db_pass quotes_db << 'END'
CREATE TABLE IF NOT EXISTS quotes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    quote TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
END

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