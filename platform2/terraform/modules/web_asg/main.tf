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

    # Create the index.html file with the new design
    echo '<!DOCTYPE html>
    <html>
    <head>
        <title>Quote List</title>
        <style>
            body {
                font-family: "Helvetica Neue", Arial, sans-serif;
                background-color: #e0f7fa;
                margin: 0;
                padding: 20px;
                display: flex;
                flex-direction: column;
                align-items: center;
            }
            
            h1 {
                color: #00796b;
                font-size: 2.5rem;
                margin-bottom: 20px;
            }
            
            .input-container {
                margin-bottom: 20px;
                display: flex;
                gap: 10px;
            }
            
            input[type="text"] {
                padding: 10px;
                font-size: 1rem;
                width: 300px;
                border: 1px solid #00796b;
                border-radius: 5px;
            }
            
            button {
                padding: 10px 20px;
                background-color: #00796b;
                color: white;
                border: none;
                font-size: 1rem;
                cursor: pointer;
                border-radius: 5px;
                transition: background-color 0.3s ease;
            }
            
            button:hover {
                background-color: #004d40;
            }
            
            h2 {
                color: #004d40;
                font-size: 2rem;
                margin-bottom: 10px;
            }
            
            ul {
                list-style-type: none;
                padding: 0;
                width: 100%;
                max-width: 600px;
            }
            
            li {
                background-color: #ffffff;
                padding: 15px;
                margin-bottom: 10px;
                border: 1px solid #00796b;
                border-radius: 5px;
                box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            }
        </style>
    </head>
    <body>
        <h1>Quotes App</h1>
        <div class="input-container">
            <input type="text" id="quoteInput" placeholder="Enter a new quote...">
            <button onclick="addQuote()">Add Quote</button>
        </div>
        <h2>Quotes List</h2>
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

resource "aws_autoscaling_policy" "cpu_target_scaling" {
  name                   = "cpu-scaling-policy"
  autoscaling_group_name = aws_autoscaling_group.web_asg.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 30
  }
}

