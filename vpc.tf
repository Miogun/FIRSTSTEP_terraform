provider "aws" {
    region = "ap-northeast-2"
}

# vpc
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc"
  }
}

# subnet (public)
resource "aws_subnet" "public_subnet_2a" {
  vpc_id =  aws_vpc.vpc.id
  cidr_block = "10.0.10.0/24"
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "public_subnet_2a"
  }
}

resource "aws_subnet" "public_subnet_2c" {
  vpc_id =  aws_vpc.vpc.id
  cidr_block = "10.0.30.0/24"
  availability_zone = "ap-northeast-2c"
  tags = {
    Name = "public_subnet_2c"
  }
}

# subnet (private)
resource "aws_subnet" "private_subnet_2a" {
  vpc_id =  aws_vpc.vpc.id
  cidr_block = "10.0.20.0/24"
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "private_subnet_2a"
  }
}
resource "aws_subnet" "private_subnet_2c" {
  vpc_id =  aws_vpc.vpc.id
  cidr_block = "10.0.40.0/24"
  availability_zone = "ap-northeast-2c"
  tags = {
    Name = "private_subnet_2c"
  }
}

# igw
resource "aws_internet_gateway" "vpc_igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "vpc_igw"
  }
}

# route_table(public)
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_igw.id
  }
  tags = {
    Name = "public_route_table"
  }
}

resource "aws_route_table_association" "public_rtb_a" {
  subnet_id      = aws_subnet.public_subnet_2a.id
  route_table_id = aws_route_table.public_route_table.id
}


resource "aws_route_table_association" "public_rtb_b" {
  subnet_id      = aws_subnet.public_subnet_2c.id
  route_table_id = aws_route_table.public_route_table.id
}

# route_table(private)
resource "aws_route_table" "private_route_table_1" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "private_route_table_1"
  }
}
resource "aws_route_table_association" "private_rtb_1_a" {
  subnet_id = aws_subnet.private_subnet_2a.id
  route_table_id = aws_route_table.private_route_table_1.id
}

resource "aws_route_table" "private_route_table_2" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "private_route_table_2"
  }
}
resource "aws_route_table_association" "private_rtb_2_a" {
  subnet_id = aws_subnet.private_subnet_2c.id
  route_table_id = aws_route_table.private_route_table_2.id
}