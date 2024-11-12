# VPC A
resource "aws_vpc" "vpc_a" {
  cidr_block           = "10.2.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "VPC_A"
  }
}

resource "aws_subnet" "vpc_a_public-a" {
  vpc_id                  = aws_vpc.vpc_a.id
  cidr_block              = "10.2.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "VPC_A_public-a"
  }
}

resource "aws_subnet" "vpc_a_private-a" {
  vpc_id            = aws_vpc.vpc_a.id
  cidr_block        = "10.2.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "VPC_A_private-a"
  }
}

resource "aws_internet_gateway" "vpc_a_igw" {
  vpc_id = aws_vpc.vpc_a.id

  tags = {
    Name = "VPC_A_igw"
  }
}

resource "aws_eip" "vpc_a_eip-a" {
  domain = "vpc"

  tags = {
    Name = "VPC_A_eip-a"
  }
}

resource "aws_nat_gateway" "vpc_a_nat-a" {
  allocation_id = aws_eip.vpc_a_eip-a.id
  subnet_id     = aws_subnet.vpc_a_public-a.id

  tags = {
    Name = "VPC_A_nat-a"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "vpc_a_public" {
  vpc_id = aws_vpc.vpc_a.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_a_igw.id
  }

  route {
    cidr_block                = aws_vpc.vpc_b.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.main.id
  }

  tags = {
    Name = "VPC_A_public-rt"
  }
}

resource "aws_route_table" "vpc_a_private-a" {
  vpc_id = aws_vpc.vpc_a.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.vpc_a_nat-a.id
  }

  route {
    cidr_block                = aws_vpc.vpc_b.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.main.id
  }

  tags = {
    Name = "VPC_A_private-a-rt"
  }
}

resource "aws_route_table_association" "vpc_a_public-a" {
  subnet_id      = aws_subnet.vpc_a_public-a.id
  route_table_id = aws_route_table.vpc_a_public.id
}

resource "aws_route_table_association" "vpc_a_private-a" {
  subnet_id      = aws_subnet.vpc_a_private-a.id
  route_table_id = aws_route_table.vpc_a_private-a.id
}

# VPC B
resource "aws_vpc" "vpc_b" {
  cidr_block           = "10.4.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "VPC_B"
  }
}

resource "aws_subnet" "vpc_b_public-a" {
  vpc_id                  = aws_vpc.vpc_b.id
  cidr_block              = "10.4.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "VPC_B_public-a"
  }
}

resource "aws_subnet" "vpc_b_private-a" {
  vpc_id            = aws_vpc.vpc_b.id
  cidr_block        = "10.4.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "VPC_B_private-a"
  }
}

resource "aws_subnet" "vpc_b_private-b" {
  vpc_id            = aws_vpc.vpc_b.id
  cidr_block        = "10.4.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "VPC_B_private-a"
  }
}

resource "aws_internet_gateway" "vpc_b_igw" {
  vpc_id = aws_vpc.vpc_b.id

  tags = {
    Name = "VPC_B_igw"
  }
}

resource "aws_eip" "vpc_b_eip-a" {
  domain = "vpc"

  tags = {
    Name = "VPC_B_eip-a"
  }
}

resource "aws_nat_gateway" "vpc_b_nat-a" {
  allocation_id = aws_eip.vpc_b_eip-a.id
  subnet_id     = aws_subnet.vpc_b_public-a.id

  tags = {
    Name = "VPC_B_nat-a"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "vpc_b_public" {
  vpc_id = aws_vpc.vpc_b.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_b_igw.id
  }

  route {
    cidr_block                = aws_vpc.vpc_a.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.main.id
  }

  tags = {
    Name = "VPC_B_public-rt"
  }
}

resource "aws_route_table" "vpc_b_private" {
  vpc_id = aws_vpc.vpc_b.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.vpc_b_nat-a.id
  }

  route {
    cidr_block                = aws_vpc.vpc_a.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.main.id
  }

  tags = {
    Name = "VPC_B_private-rt"
  }
}

resource "aws_route_table_association" "vpc_b_public-a" {
  subnet_id      = aws_subnet.vpc_b_public-a.id
  route_table_id = aws_route_table.vpc_b_public.id
}

resource "aws_route_table_association" "vpc_b_private-a" {
  subnet_id      = aws_subnet.vpc_b_private-a.id
  route_table_id = aws_route_table.vpc_b_private.id
}

resource "aws_route_table_association" "vpc_b_private-b" {
  subnet_id      = aws_subnet.vpc_b_private-b.id
  route_table_id = aws_route_table.vpc_b_private.id
}

# Peering
resource "aws_vpc_peering_connection" "main" {
  peer_vpc_id = aws_vpc.vpc_a.id
  vpc_id      = aws_vpc.vpc_b.id
  auto_accept = true

  tags = {
    Name = "VPC_A_B_peering"
  }
}