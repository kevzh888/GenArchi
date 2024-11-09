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
              sudo apt update -y
              sudo apt install -y mysql-server
              sudo systemctl start mysql
              sudo systemctl enable mysql

              # Configure MySQL for slave replication
              sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf > /dev/null <<EOL

              [mysqld]
              server-id=2
              relay_log=/var/log/mysql/mysql-relay-bin.log
              read_only=1
              EOL

              # Restart MySQL to apply the configuration
              sudo systemctl restart mysql

              # Set up the replication on the slave
              mysql -u root <<EOL
              CHANGE MASTER TO
                  MASTER_HOST='${var.master_public_ip}',
                  MASTER_USER='replicator',
                  MASTER_PASSWORD='arcl',
                  MASTER_LOG_FILE='mysql-bin.000001',  # Replace with actual log file from master
                  MASTER_LOG_POS=4;  # Replace with actual log position from master
              START SLAVE;
              EOL

              # Display slave status to confirm configuration
              mysql -u root -e "SHOW SLAVE STATUS\G"
              EOF
}
