resource "aws_subnet" "public_subnet" {
  count                   = 2
  vpc_id                  = var.vpc_id
  cidr_block             = cidrsubnet(var.vpc_cidr_block, 8, count.index)
  availability_zone       = element([var.public_subnet_az_1, var.public_subnet_az_2], count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet_${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnet" {
  count             = 2
  vpc_id            = var.vpc_id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, count.index + 2)
  availability_zone = element([var.private_subnet_az_1, var.private_subnet_az_2], count.index)
  tags = {
    Name = "private_subnet_${count.index + 1}"
  }
}

# AWS NAT gateway
resource "aws_eip" "nat_eip" {
  vpc = true

  tags = {
    Name = "nat_gateway_eip"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name = "nat_gateway"
  }

  depends_on = [aws_eip.nat_eip]
}

resource "aws_route_table" "nat_route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }
}

# Création de la table de routage
resource "aws_route_table" "public_route_table" {
  vpc_id = var.vpc_id

  # Route pour l'accès Internet
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }

  tags = {
    Name = "PublicRouteTable"
  }
}

resource "aws_route_table_association" "rt_association_nat_gateway" {
  subnet_id = aws_subnet.private_subnet[0].id
  route_table_id = aws_route_table.nat_route_table.id
}

# Association de la table de routage au sous-réseau public 1
resource "aws_route_table_association" "rt_association_s1" {
  subnet_id      = aws_subnet.public_subnet[0].id
  route_table_id = aws_route_table.public_route_table.id
}

# Association de la table de routage au sous-réseau public 2
resource "aws_route_table_association" "rt_association_s2" {
  subnet_id      = aws_subnet.public_subnet[1].id
  route_table_id = aws_route_table.public_route_table.id
}