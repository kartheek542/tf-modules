resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${terraform.workspace}-elk-app-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr

  tags = {
    subnet-type = "public"
    Name = "${terraform.workspace}-elk-app-public-subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr

  tags = {
    subnet-type = "private"
    Name = "${terraform.workspace}-elk-app-private-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${terraform.workspace}-elk-app-igw"
  }
}

resource "aws_route_table" "app_route_table" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${terraform.workspace}-elk-app-route-table"
  }
}

resource "aws_route" "ig_route" {
  route_table_id         = aws_route_table.app_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.app_route_table.id
}