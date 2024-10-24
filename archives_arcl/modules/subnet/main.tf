# Création du sous-réseau 1
resource "aws_subnet" "subnet1" {
  vpc_id                  = var.vpc-id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-3a"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet1"
  }
}

# Création du sous-réseau 2
resource "aws_subnet" "subnet2" {
  vpc_id                  = var.vpc-id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-west-3b"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet2"
  }
}

# Création du sous-réseau 3
resource "aws_subnet" "subnet3" {
  vpc_id                  = var.vpc-id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "eu-west-3c"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet3"
  }
}

# Association de la table de routage au sous-réseau 1
resource "aws_route_table_association" "rt_association_s1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = var.route-table-id
}

# Association de la table de routage au sous-réseau 2
resource "aws_route_table_association" "rt_association_s2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = var.route-table-id
}

# Association de la table de routage au sous-réseau 3
resource "aws_route_table_association" "rt_association_s3" {
  subnet_id      = aws_subnet.subnet3.id
  route_table_id = var.route-table-id
}