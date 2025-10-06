output "db_address" {
  value = aws_db_instance.db_instance.address
}

output "db_endpoint" {
  value = aws_db_instance.db_instance.endpoint
}