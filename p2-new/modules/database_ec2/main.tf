resource "aws_instance" "db_instance" {
  ami           = var.db_ami_id
  instance_type = var.db_instance_type
  subnet_id     = var.private_subnet_id
  security_groups = [var.db_sg_id]

  tags = {
    Name = var.db_instance_name
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y mysql-server
              sudo systemctl start mysql
              EOF
}
