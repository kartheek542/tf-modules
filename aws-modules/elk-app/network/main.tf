resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${terraform.workspace}-elk-app-vpc"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    subnet-type = "public"
    Name        = "${terraform.workspace}-elk-app-public-subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index % 2]

  tags = {
    subnet-type = "private"
    Name        = "${terraform.workspace}-elk-app-private-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${terraform.workspace}-elk-app-igw"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "elk-app-nat-eip"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "elk-app-nat-gw"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "public_app_route_table" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${terraform.workspace}-elk-public-app-route-table"
  }
}

resource "aws_route_table" "private_app_route_table" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${terraform.workspace}-elk-private-app-route-table"
  }
}

resource "aws_route" "ig_route" {
  route_table_id         = aws_route_table.public_app_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "ngw_route" {
  route_table_id         = aws_route_table.private_app_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.nat_gw.id
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_app_route_table.id
}

resource "aws_route_table_association" "private_subnet_association" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_app_route_table.id
}