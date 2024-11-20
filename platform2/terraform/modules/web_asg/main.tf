//web_asg/main.tf
resource "aws_launch_template" "web_launch_template" {
  name_prefix = var.launch_template_name_prefix
  image_id = var.instance_ami
  instance_type = var.instance_type
  
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = var.instance_tag_name
    }
  }
  
  network_interfaces {
    associate_public_ip_address = true
    security_groups = [var.web_sg_id]
  }
  
  user_data = base64encode(<<-EOF
    #!/bin/bash
    # Update and install dependencies
    sudo apt update -y
    sudo apt install -y nginx mysql-client

    # Create the index.html file with interactive elements
    echo '<!DOCTYPE html>
      <html>
      <head>
          <title>Quote List</title>
          <style>
              body {
                  font-family: Arial, sans-serif;
                  max-width: 800px;
                  margin: 20px auto;
                  padding: 0 20px;
              }
              .input-container {
                  margin: 20px 0;
              }
              input[type="text"] {
                  padding: 8px;
                  font-size: 16px;
                  width: 60%;
                  margin-right: 10px;
              }
              button {
                  padding: 8px 16px;
                  font-size: 16px;
                  background-color: #4CAF50;
                  color: white;
                  border: none;
                  cursor: pointer;
              }
              button:hover {
                  background-color: #45a049;
              }
              ul {
                  list-style-type: none;
                  padding: 0;
              }
              li {
                  padding: 8px;
                  margin: 4px 0;
                  background-color: #f9f9f9;
                  border: 1px solid #ddd;
                  border-radius: 4px;
              }
          </style>
      </head>
      <body>
          <h1>Quote List</h1>
          <div class="input-container">
              <input type="text" id="quoteInput" placeholder="Enter your quote here">
              <button onclick="addQuote()">Add Quote</button>
          </div>
          <ul id="quoteList"></ul>

          <script>
              const APP_LB_DNS = '"'"'${var.app_lb_dns}'"'"';
              
              async function loadQuotes() {
                  try {
                      const response = await fetch("http://" + APP_LB_DNS + "/api/quotes");
                      if (response.ok) {
                          const quotes = await response.json();
                          const list = document.getElementById("quoteList");
                          list.innerHTML = "";
                          quotes.forEach(quote => {
                              const li = document.createElement("li");
                              li.textContent = quote.text;
                              list.appendChild(li);
                          });
                      }
                  } catch (error) {
                      console.error("Error loading quotes:", error);
                  }
              }

              async function addQuote() {
                  const input = document.getElementById("quoteInput");
                  const quote = input.value.trim();
                  
                  if (quote !== "") {
                      try {
                          const response = await fetch("http://" + APP_LB_DNS + "/api/quotes", {
                              method: "POST",
                              headers: {
                                  "Content-Type": "application/json",
                              },
                              body: JSON.stringify({ quote: quote })
                          });
                          
                          if (response.ok) {
                              input.value = "";
                              loadQuotes();  // Reload the quotes after adding
                          } else {
                              console.error("Failed to add quote");
                          }
                      } catch (error) {
                          console.error("Error:", error);
                      }
                  }
              }

              document.getElementById("quoteInput").addEventListener("keypress", function(e) {
                  if (e.key === "Enter") {
                      addQuote();
                  }
              });

              // Load quotes when page loads
              loadQuotes();
          </script>
      </body>
      </html>' > /var/www/html/index.html

    # Start and enable Nginx
    sudo systemctl start nginx
    sudo systemctl enable nginx
    EOF
  )
}

resource "aws_autoscaling_group" "web_asg" {
  desired_capacity = var.asg_desired_capacity
  max_size = var.asg_max_size
  min_size = var.asg_min_size
  vpc_zone_identifier = [var.public_subnet_id_1, var.public_subnet_id_2]
  
  launch_template {
    id = aws_launch_template.web_launch_template.id
    version = aws_launch_template.web_launch_template.latest_version
  }
  
  target_group_arns = [var.target_group_arn]
  
  tag {
    key = "Name"
    value = var.asg_tag_name
    propagate_at_launch = true
  }
}
