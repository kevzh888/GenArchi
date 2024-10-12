resource "aws_instance" "db_instance" {
  ami           = "ami-0c55b159cbfafe1f0"  # AMI pour la base de données
  instance_type = "t2.micro"
  subnet_id     = var.private_subnet_id
  security_groups = [var.db_sg_id]

  tags = {
    Name = "db-instance"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y mysql-server
              sudo systemctl start mysql
              EOF
}
