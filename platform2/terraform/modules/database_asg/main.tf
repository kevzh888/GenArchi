# modules/asg/main.tf

resource "aws_launch_configuration" "mysql_config" {
  name          = "mysql-launch-config"
  image_id      = var.ami_id
  instance_type = var.instance_type
  security_groups = [aws_security_group.mysql_sg.id]
  user_data     = base64encode(<<-EOF
              #!/bin/bash
              set -e

              # Met à jour les paquets et installe MySQL
              sudo apt-get update -y
              sudo apt-get install -y mysql-server awscli

              # Démarre et active MySQL
              sudo systemctl start mysql
              sudo systemctl enable mysql

              # Configure MySQL pour la réplication en tant que slave
              sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf > /dev/null <<EOL
              [mysqld]
              server-id=2
              relay_log=/var/log/mysql/mysql-relay-bin.log
              read_only=1
              EOL

              sudo systemctl restart mysql

              # Configuration de la réplication MySQL pour le slave
              sudo mysql -u root <<EOL
              CHANGE MASTER TO
                  MASTER_HOST='${var.master_eip_public_ip}',
                  MASTER_USER='replicator',
                  MASTER_PASSWORD='arcl',
                  MASTER_LOG_FILE='mysql-bin.000001',  -- Remplacez avec le fichier bin réel du master
                  MASTER_LOG_POS=4;                   -- Remplacez avec la position réelle du master
              START SLAVE;
              EOL

              # Vérifie si le master est en ligne toutes les 10 secondes
              while true; do
                  if ! ping -c 1 ${var.master_eip_public_ip} > /dev/null; then
                      echo "Master down, initiating failover."

                      # Récupère l'ID de cette instance
                      INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

                      # Associe l'Elastic IP du master à l'instance slave
                      aws ec2 associate-address --instance-id $INSTANCE_ID --allocation-id ${var.master_eip_id} --region ${var.region}

                      # Change les configurations MySQL pour activer le slave en master
                      sudo sed -i 's/read_only=1/read_only=0/' /etc/mysql/mysql.conf.d/mysqld.cnf
                      sudo systemctl restart mysql
                      break
                  else
                      echo "Master is online. Checking again in 10 seconds."
                      sleep 10
                  fi
              done
              EOF
  )
  associate_public_ip_address = true
}

resource "aws_autoscaling_group" "mysql_asg" {
  desired_capacity     = var.desired_capacity
  max_size             = var.max_size
  min_size             = var.min_size
  vpc_zone_identifier = [var.public_subnet_id_1, var.public_subnet_id_2]
  launch_configuration = aws_launch_configuration.mysql_config.id

  target_group_arns = [var.target_group_arn]

  tag {
    key = "Name"
    value = "database-asg"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "mysql_sg" {
  name        = "mysql_sg"
  description = "Security group for MySQL instances"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
