# security_groups/main.tf

# Security Group for Web Load Balancer
resource "aws_security_group" "web_sg" {
  vpc_id = var.vpc_id
  
  # Allow HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Allow HTTPS from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Allow ICMP
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Allow SSH
  ingress {
    from_port   = var.db_ingress_ssh_from_port
    to_port     = var.db_ingress_ssh_to_port
    protocol    = var.db_ingress_ssh_protocol
    cidr_blocks = var.db_ingress_ssh_cidr_blocks
  }
  
  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = var.web_sg_name
  }
}

# Security Group for Application Tier
resource "aws_security_group" "app_sg" {
  vpc_id = var.vpc_id
  
  # Allow HTTP from anywhere (since we're using public subnets)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Allow HTTPS if needed
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Allow SSH for management
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.db_ingress_ssh_cidr_blocks
  }
  
  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.app_sg_name
  }
}

# Security Group for Database Tier
resource "aws_security_group" "db_sg" {
  vpc_id = var.vpc_id
  
  # Allow MySQL/Aurora from App tier
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 3307
    to_port         = 3307
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 3307
    to_port         = 3307
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Allow SSH
  ingress {
    from_port   = var.db_ingress_ssh_from_port
    to_port     = var.db_ingress_ssh_to_port
    protocol    = var.db_ingress_ssh_protocol
    cidr_blocks = var.db_ingress_ssh_cidr_blocks
  }
  
  # Allow ICMP
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Allow traffic between database instances (for replication)
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    self            = true
  }
  
  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = var.db_sg_name
  }
}