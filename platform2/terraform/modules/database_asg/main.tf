# modules/asg/main.tf

resource "aws_launch_template" "mysql_template" {
  name_prefix   = "mysql-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = true
    security_groups            = [var.db_sg_id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              
              # Activer le logging détaillé
              exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
              echo "Starting user_data script..."
              
              # Attendre que le système soit prêt
              while [ ! -f /var/lib/cloud/instance/boot-finished ]; do
                echo 'Waiting for cloud-init...'
                sleep 1
              done

              # Mettre à jour la liste des paquets
              echo "Updating package list..."
              apt-get update
              
              # Configurer mysql-server pour une installation non-interactive
              echo "Configuring MySQL installation..."
              export DEBIAN_FRONTEND=noninteractive
              debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
              debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
              
              # Installer MySQL et AWS CLI
              echo "Installing MySQL and AWS CLI..."
              apt-get install -y mysql-server awscli
              if [ $? -ne 0 ]; then
                echo "Failed to install packages"
                exit 1
              fi

              # Vérifier que MySQL est installé
              echo "Checking MySQL installation..."
              if [ ! -d "/etc/mysql" ]; then
                echo "MySQL installation failed - /etc/mysql directory not found"
                exit 1
              fi

              # Démarrer et activer MySQL
              echo "Starting MySQL service..."
              systemctl start mysql
              systemctl enable mysql
              
              # Vérifier que MySQL est en cours d'exécution
              if ! systemctl is-active --quiet mysql; then
                echo "MySQL failed to start"
                exit 1
              fi

              # Configurer MySQL pour la réplication
              echo "Configuring MySQL replication..."
              cat >> /etc/mysql/mysql.conf.d/mysqld.cnf <<EOL

              [mysqld]
              server-id=2
              relay_log=/var/log/mysql/mysql-relay-bin.log
              read_only=1
              bind-address = 0.0.0.0
              EOL

              # Redémarrer MySQL pour appliquer la configuration
              echo "Restarting MySQL to apply configuration..."
              systemctl restart mysql
              
              # Attendre que MySQL soit complètement démarré
              echo "Waiting for MySQL to be ready..."
              while ! mysqladmin ping -h localhost --silent; do
                sleep 1
              done

              # Configurer la réplication
              echo "Setting up replication..."
              mysql -u root <<EOL
              ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root';
              FLUSH PRIVILEGES;
              CHANGE MASTER TO
                  MASTER_HOST='${var.master_eip_public_ip}',
                  MASTER_USER='replicator',
                  MASTER_PASSWORD='arcl',
                  MASTER_LOG_FILE='mysql-bin.000001',
                  MASTER_LOG_POS=4;
              START SLAVE;
              EOL

              # Configurer le monitoring du master
              echo "Setting up master monitoring..."
              cat > /usr/local/bin/check-master.sh <<'SCRIPT'
              #!/bin/bash
              while true; do
                  if ! ping -c 1 ${var.master_eip_public_ip} > /dev/null; then
                      echo "Master down, initiating failover."
                      INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
                      aws ec2 associate-address --instance-id $INSTANCE_ID --allocation-id ${var.master_eip_id} --region ${var.region}
                      sed -i 's/read_only=1/read_only=0/' /etc/mysql/mysql.conf.d/mysqld.cnf
                      systemctl restart mysql
                      break
                  else
                      echo "Master is online. Checking again in 10 seconds."
                      sleep 10
                  fi
              done
              SCRIPT

              chmod +x /usr/local/bin/check-master.sh
              nohup /usr/local/bin/check-master.sh &

              echo "User data script completed"
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "mysql-slave"
    }
  }
}

resource "aws_autoscaling_group" "mysql_asg" {
  desired_capacity    = var.desired_capacity
  max_size           = var.max_size
  min_size           = var.min_size
  vpc_zone_identifier = [var.public_subnet_id_1, var.public_subnet_id_2]
  target_group_arns  = [var.target_group_arn]

  launch_template {
    id      = aws_launch_template.mysql_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value              = "database-asg"
    propagate_at_launch = true
  }
}