data "aws_caller_identity" "current_identity" {}

resource "aws_eks_access_entry" "creator_access" {
  cluster_name  = var.cluster_name
  principal_arn = data.aws_caller_identity.current_identity.arn
  type          = "STANDARD"
}

resource "aws_eks_access_entry" "other_access" {
  count         = length(var.roles)
  cluster_name  = var.cluster_name
  principal_arn = var.roles[count.index]
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "creator_admin_access" {
  cluster_name  = var.cluster_name
  principal_arn = data.aws_caller_identity.current_identity.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.creator_access]
}

resource "aws_eks_access_policy_association" "other_admin_access" {
  count         = length(var.roles)
  cluster_name  = var.cluster_name
  principal_arn = var.roles[count.index]
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.other_access]
}