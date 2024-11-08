resource "aws_instance" "db_instance" {
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

              # Configure MySQL for master replication
              sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf > /dev/null <<EOL

              [mysqld]
              server-id=1
              log_bin=/var/log/mysql/mysql-bin.log
              binlog_do_db=counter
              EOL

              # Restart MySQL to apply the configuration
              sudo systemctl restart mysql

              # Set up the MySQL replication user
              mysql -u root <<EOL
              CREATE USER 'replicator'@'%' IDENTIFIED BY 'arcl';
              GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'%';
              FLUSH PRIVILEGES;
              EOL

              # Display master status to confirm configuration
              mysql -u root -e "SHOW MASTER STATUS\G"
              EOF
}
