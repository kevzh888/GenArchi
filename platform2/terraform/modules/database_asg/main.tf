# modules/asg/main.tf

resource "aws_launch_template" "mysql_template" {
  name_prefix   = "database-"
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

              # Mettre à jour la liste des paquets
              echo "Updating package list..."
              sudo apt-get update -y > /dev/null 2>&1

              # Installer les dépendances nécessaires
              echo "Installing dependencies..."
              sudo apt-get install -y debconf-utils unzip curl > /dev/null 2>&1

              # Installation d'AWS CLI v2
              echo "Installing AWS CLI v2..."
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip -q awscliv2.zip
              sudo ./aws/install

              # Configurer les credentials AWS
              echo "Setting up AWS credentials..."
              mkdir -p /root/.aws
              cat > /root/.aws/credentials <<END
              [default]
              aws_access_key_id = ${var.aws_access_key}
              aws_secret_access_key = ${var.aws_secret_key}
              region = ${var.region}
              END
              
              # Délai pour la deuxième instance
              # Obtenir un jeton
              TOKEN_D=$(curl -X PUT -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" -s http://169.254.169.254/latest/api/token)
              INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN_D" -s http://169.254.169.254/latest/meta-data/instance-id)
              echo "For delay Instance id is: $INSTANCE_ID"
              INSTANCE_NAME=$(aws ec2 describe-tags \
                  --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=Name" \
                  --query "Tags[0].Value" \
                  --output text)              
              echo "For delay Instance name is: $INSTANCE_NAME"
              INSTANCE_INDEX=$(echo "$INSTANCE_NAME" | grep -o '[0-9]*$')
              echo "For delay Instance Index is: $INSTANCE_INDEX"

              if [ -z "$INSTANCE_INDEX" ]; then
                  echo "Failed to retrieve Instance Index from metadata."
                  exit 1
              fi

              INSTANCE_INDEX=$((INSTANCE_INDEX))

              if [ "$INSTANCE_INDEX" -gt 1 ]; then
                  echo "Delaying startup for this instance..."
                  sleep 60
              fi
              
              # Configurer mysql-server pour une installation non-interactive
              echo "Configuring MySQL installation..."
              sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password root"
              sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password root"
              
              # Installer MySQL
              echo "Installing MySQL..."
              sudo DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server
              if [ $? -ne 0 ]; then
                echo "Failed to install MySQL"
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

              echo "Checking if master is available with retries..."
              RETRY_COUNT=3
              RETRY_DELAY=2
              ATTEMPT=0

              if ! [ "$INSTANCE_INDEX" -gt 1 ]; then
                  echo "First instance then no retries"
                  RETRY_COUNT=1
              fi
              echo "Retry count: $RETRY_COUNT, Retry delay: $RETRY_DELAY"

              while [ $ATTEMPT -lt $RETRY_COUNT ]; do
                  if mysql -h ${var.master_eip_public_ip} -P 3306 -u replicator -parcl -e "SHOW MASTER STATUS\G" &>/dev/null; then
                      echo "Master is available, retrieving replication log status..."
                      MASTER_STATUS=$(mysql -h ${var.master_eip_public_ip} -P 3306 -u replicator -parcl -e "SHOW MASTER STATUS\G")
                      MASTER_LOG_FILE=$(echo "$MASTER_STATUS" | grep 'File' | awk '{print $2}')
                      MASTER_LOG_POS=$(echo "$MASTER_STATUS" | grep 'Position' | awk '{print $2}')

                      echo "Exporting data from master and importing to slave..."

                      # Créer un dump de la base de données sur le master
                      mysqldump -h ${var.master_eip_public_ip} -P 3306 -u replicator -parcl --all-databases | mysql -u root -proot
                      if [ $? -ne 0 ]; then
                        echo "Failed to create database dump from master."
                        exit 1
                      fi

                      echo "Data migration from master to slave completed successfully."
                      break

                  else
                      echo "Master is not available, retrying in $RETRY_DELAY seconds... (Attempt $((ATTEMPT + 1))/$RETRY_COUNT)"
                      ATTEMPT=$((ATTEMPT + 1))
                      sleep $RETRY_DELAY
                  fi
              done

              echo "All retries are finished"

              if [ $ATTEMPT -eq $RETRY_COUNT ]; then
                  echo "Failed to connect to master after $RETRY_COUNT attempts. Using default values..."
                  MASTER_LOG_FILE="mysql-bin.000001"
                  MASTER_LOG_POS=4
              fi

              echo "Master Log File: $MASTER_LOG_FILE"
              echo "Master Log Position: $MASTER_LOG_POS"

              # Configurer MySQL pour la réplication
              echo "Configuring MySQL replication..."
              cat >> /etc/mysql/mysql.conf.d/mysqld.cnf <<EOL

              [mysqld]
              server-id=$INSTANCE_INDEX
              relay_log=/var/log/mysql/mysql-relay-bin.log
              read_only=true
              bind-address = 0.0.0.0
              EOL
              
              sudo sed -i 's/^bind-address[[:space:]]*=[[:space:]]*127\.0\.0\.1$/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf

              # Redémarrer MySQL pour appliquer la configuration
              echo "Restarting MySQL to apply configuration..."
              systemctl restart mysql
              sudo service mysql restart
              
              # Attendre que MySQL soit complètement démarré
              echo "Waiting for MySQL to be ready..."
              while ! mysqladmin ping -h localhost --silent; do
                sleep 1
              done

              # Configurer la réplication
              echo "Setting up replication..."

              mysql -u root -proot <<EOL
              ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root';
              
              -- Création de l'utilisateur 'replicator' avec les privilèges nécessaires
              CREATE USER IF NOT EXISTS 'replicator'@'%' IDENTIFIED WITH mysql_native_password BY 'arcl';

              -- Accorder les privilèges REPLICATION SLAVE et REPLICATION CLIENT
              GRANT REPLICATION CLIENT, REPLICATION SLAVE, LOCK TABLES, SHOW VIEW, RELOAD, PROCESS, SELECT ON *.* TO 'replicator'@'%' WITH GRANT OPTION;

              -- User nodeapp utilisé par le tier app
              CREATE USER IF NOT EXISTS 'nodeapp'@'%'IDENTIFIED BY 'arcl';
              GRANT ALL PRIVILEGES ON quotes_db.* TO 'nodeapp'@'%';

              -- Appliquer les changements de privilèges
              FLUSH PRIVILEGES;

              -- Configurer la réplication en utilisant les informations du master
              CHANGE MASTER TO
                  MASTER_HOST='${var.master_eip_public_ip}',
                  MASTER_USER='replicator',
                  MASTER_PASSWORD='arcl',
                  MASTER_LOG_FILE='$MASTER_LOG_FILE',
                  MASTER_LOG_POS=$MASTER_LOG_POS;

              -- Démarrer la réplication sur le slave
              START SLAVE;
              EOL

              # Configurer le monitoring du master
              echo "Setting up master monitoring..."
              cat > /usr/local/bin/check-master.sh <<'SCRIPT'
              #!/bin/bash
              export AWS_CONFIG_FILE=/root/.aws/credentials

              while true; do
                  if ! ping -c 1 ${var.master_eip_public_ip} > /dev/null; then
                      echo "Master down, initiating failover."
                      
                      # Obtenir un jeton
                      TOKEN=$(curl -X PUT -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" -s http://169.254.169.254/latest/api/token)

                      INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id)
                      echo "Instance ID is: $INSTANCE_ID"
                      
                      /usr/local/bin/aws ec2 associate-address \
                          --instance-id "$INSTANCE_ID" \
                          --allocation-id "${var.master_eip_id}" \
                          --region "${var.region}" \
                          --allow-reassociation
                      
                      if [ $? -eq 0 ]; then
                          echo "EIP associated. Promoting to master."
                          mysql -u root -proot -e "STOP SLAVE; RESET SLAVE ALL;"
                          sudo sed -i 's/^read_only[[:space:]]*=[[:space:]]*true$/#read_only=true/' /etc/mysql/mysql.conf.d/mysqld.cnf
                          systemctl restart mysql
                          sudo service mysql restart
                          break
                      else
                          echo "Failed to associate EIP."
                          sleep 10
                      fi
                  else
                      echo "Master is online. Checking again in 10 seconds."
                      sleep 10
                  fi
              done
              SCRIPT

              chmod +x /usr/local/bin/check-master.sh
              chmod 600 /root/.aws/credentials

              # Démarrer le script de monitoring
              sudo nohup /usr/local/bin/check-master.sh > /var/log/check-master.log 2>&1 &

              echo "User data script completed"
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "database-asg"
    }
  }
}

resource "aws_autoscaling_group" "mysql_asg" {
  count         = var.desired_capacity
  desired_capacity    = var.desired_capacity - 1
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
    value               = "database-asg-${count.index + 1}"
    propagate_at_launch = true
  }
}
