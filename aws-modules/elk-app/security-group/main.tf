resource "aws_security_group" "sg" {
  name   = "${terraform.workspace}-elk-app-default-sg"
  vpc_id = var.vpc_id

  tags = {
    Name = "${terraform.workspace}-${var.name}-default-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  count             = length(var.allowed_ranges)
  security_group_id = aws_security_group.sg.id
  cidr_ipv4         = var.allowed_ranges[count.index]
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "allow_basic" {
  count             = length(var.allowed_ranges)
  security_group_id = aws_security_group.sg.id
  cidr_ipv4         = var.allowed_ranges[count.index]
  from_port         = 10
  to_port           = 1000
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "allow_80_series" {
  count             = length(var.allowed_ranges)
  security_group_id = aws_security_group.sg.id
  cidr_ipv4         = var.allowed_ranges[count.index]
  from_port         = 8000
  to_port           = 9000
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "allow_public_https" {
  count             = var.public ? 1 : 0
  security_group_id = aws_security_group.sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "allow_public_ssh" {
  count             = var.public ? 1 : 0
  security_group_id = aws_security_group.sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  count             = terraform.workspace == "prod" ? 1 : 0
  security_group_id = aws_security_group.sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

