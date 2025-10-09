output "public_ip" {
  value = aws_instance.jump-server.public_ip
}

output "private_ip" {
  value = aws_instance.jump-server.private_ip
}

output "instance_id" {
  value = aws_instance.jump-server.id
}