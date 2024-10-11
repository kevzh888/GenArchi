resource "aws_vpc" "default_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "default_vpc"
  }
} 

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.default_vpc.id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "default_route_table" {
  vpc_id = aws_vpc.default_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "default_route_table"
  }
}

