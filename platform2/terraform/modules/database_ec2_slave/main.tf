resource "aws_instance" "db_slave_instance" {
  ami           = var.db_ami_id
  instance_type = var.db_instance_type
  subnet_id     = var.public_subnet_id
  security_groups = [var.db_sg_id]

  tags = {
    Name = var.db_instance_name
  }

  user_data = <<-EOF
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
                  MASTER_HOST='${var.master_public_ip}',
                  MASTER_USER='replicator',
                  MASTER_PASSWORD='arcl',
                  MASTER_LOG_FILE='mysql-bin.000001',  -- Remplacez avec le fichier bin réel du master
                  MASTER_LOG_POS=4;                   -- Remplacez avec la position réelle du master
              START SLAVE;
              EOL

              # Vérifie si le master est en ligne toutes les 10 secondes
              while false; do
                  if ! ping -c 1 ${var.master_public_ip} > /dev/null; then
                      echo "Master down, initiating failover."

                      # Récupère l'ID de cette instance
                      INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

                      # Associe l'Elastic IP du master à l'instance slave
                      aws ec2 associate-address --instance-id $INSTANCE_ID --allocation-id ${aws_eip.db_master_eip.id} --region ${var.region}

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
}
