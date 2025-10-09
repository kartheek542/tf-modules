resource "aws_security_group" "default_sg" {
  name   = "${terraform.workspace}-elk-app-default-sg"
  vpc_id = data.aws_subnet.public_subnet.vpc_id

  tags = {
    Name = "${terraform.workspace}-elk-app-default-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ports" {
  count             = length(var.allowed_ports)
  security_group_id = aws_security_group.default_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = var.allowed_ports[count.index]
  to_port           = var.allowed_ports[count.index]
  ip_protocol       = "tcp"
}
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  count             = terraform.workspace == "prod" ? 1 : 0
  security_group_id = aws_security_group.default_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
