output "role_id" {
  value = aws_iam_role.role.id
}
output "role_name" {
  value = aws_iam_role.role.name
}
output "instance_profile_name" {
  value = aws_iam_instance_profile.ec2_instance_profile[*].id
}