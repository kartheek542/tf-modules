output "role_id" {
  value = aws_iam_role.role.id
}
output "role_name" {
  value = aws_iam_role.role.name
}
output "instance_profile_id" {
  value = aws_iam_instance_profile.instance_profile[*].id
}