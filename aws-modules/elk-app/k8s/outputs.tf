output "cluster_endpoint" {
  value = aws_eks_cluster.elk_cluster.endpoint
}

output "cluster_arn" {
  value = aws_eks_cluster.elk_cluster.arn
}

output "security_group_id" {
  value = aws_security_group.default_sg.id
}