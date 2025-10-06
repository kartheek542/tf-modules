output "vpc_id" {
  value = aws_vpc.main.id
}

output "route_table_id" {
  value = aws_route_table.app_route_table.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnet[*].id
}