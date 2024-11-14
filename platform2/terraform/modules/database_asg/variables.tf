# modules/asg/variables.tf

variable "ami_id" {
  description = "L'AMI ID des instances EC2"
  type        = string
}

variable "instance_type" {
  description = "Type d'instance EC2 pour Master et Slave"
  type        = string
}

variable "user_data" {
  description = "Le script User Data pour initialiser les instances"
  type        = string
  default = <<-EOF
              #!/bin/bash
              set -e

              sudo apt-get update -y
              sudo apt-get install -y mysql-server

              sudo systemctl start mysql
              sudo systemctl enable mysql

              sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf > /dev/null <<EOL
              [mysqld]
              server-id=2
              relay_log=/var/log/mysql/mysql-relay-bin.log
              read_only=1
              EOL

              sudo systemctl restart mysql
              EOF
}

variable "desired_capacity" {
  description = "Nombre désiré d'instances dans l'Auto Scaling Group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Taille maximale du groupe Auto Scaling"
  type        = number
  default     = 3
}

variable "min_size" {
  description = "Taille minimale du groupe Auto Scaling"
  type        = number
  default     = 1
}

variable "subnet_ids" {
  description = "Les subnets dans lesquels les instances ASG seront lancées"
  type        = list(string)
}
