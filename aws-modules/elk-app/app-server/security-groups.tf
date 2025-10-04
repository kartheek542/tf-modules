resource "aws_security_group" "default_sg" {
  name   = "${terraform.workspace}-elk-app-default-sg"
  vpc_id = data.aws_subnet.public_subnet.vpc_id

  tags = {
    Name = "${terraform.workspace}-elk-app-default-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.default_sg.id
  cidr_ipv4         = data.aws_subnet.public_subnet.cidr_block
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.default_sg.id
  cidr_ipv4         = data.aws_subnet.public_subnet.cidr_block
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.default_sg.id
  cidr_ipv4         = data.aws_subnet.public_subnet.cidr_block
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "allow_public http" {
  security_group_id = aws_security_group.default_sg.id
  cidr_ipv4         = "0.0.0.0/"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "allow_public https" {
  security_group_id = aws_security_group.default_sg.id
  cidr_ipv4         = "0.0.0.0/"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  count             = terraform.workspace == "prod" ? 1 : 0
  security_group_id = aws_security_group.default_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}