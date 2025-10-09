output "cluster_endpoint" {
  value = aws_eks_cluster.elk_cluster.endpoint
}

output "cluster_arn" {
  value = aws_eks_cluster.elk_cluster.arn
}

output "security_group_id" {
  value = aws_eks_cluster.elk_cluster.vpc_config[0].security_group_ids[0]
}