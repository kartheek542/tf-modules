data "aws_subnet" "public_subnet" {
  id = var.public_subnet_id
}

data "aws_subnet" "private_subnets" {
  count = length(var.private_subnet_ids)
  id    = var.private_subnet_ids[count.index]
}

resource "aws_security_group" "database_sg" {
  name   = "${terraform.workspace}-elk-app-database-sg"
  vpc_id = data.aws_subnet.public_subnet.vpc_id

  tags = {
    Name = "${terraform.workspace}-elk-app-default-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "public_subnet_pg_port" {
  security_group_id = aws_security_group.database_sg.id
  cidr_ipv4         = data.aws_subnet.public_subnet.cidr_block
  from_port         = var.db_port
  to_port           = var.db_port
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "private_subnet_pg_port" {
  count             = length(var.private_subnet_ids)
  security_group_id = aws_security_group.database_sg.id
  cidr_ipv4         = data.aws_subnet.private_subnets[count.index].cidr_block
  from_port         = var.db_port
  to_port           = var.db_port
  ip_protocol       = "tcp"
}