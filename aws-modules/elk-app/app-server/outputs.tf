output "public_ip" {
    value = aws_instance.app-server.public_ip
}

output "instance_id" {
  value = aws_instance.app-server.id
}