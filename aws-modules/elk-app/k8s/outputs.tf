output "cluster_endpoint" {
  value = aws_eks_cluster.elk_cluster.endpoint
}

output "cluster_arn" {
  value = aws_eks_cluster.elk_cluster.arn
}
