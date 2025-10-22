resource "aws_iam_openid_connect_provider" "eks_oidc" {
  url             = aws_eks_cluster.elk_cluster.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da0ecd0c5e3"]
}

resource "aws_iam_role" "irsa_role" {
  name        = "elk-eks-irsa-role"
  description = "elk-elk-irsa-role-description"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks_oidc.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.eks_oidc.url, "https://", "")}:aud" = "sts.amazonaws.com"
            "${replace(aws_iam_openid_connect_provider.eks_oidc.url, "https://", "")}:sub" = "system:serviceaccount:${var.namespace}:${var.service_account}"
          }
        }
      }
    ]
  })

  depends_on = [aws_iam_openid_connect_provider.eks_oidc]
}

resource "aws_iam_role_policy" "sa_privileges" {
  name = "EKS_ELK_${var.namespace}-${var.service_account}_policy"
  role = aws_iam_role.irsa_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:*",
          "elasticloadbalancing:*",
          "secretsmanager:*"
        ],
        Resource = "*"
      }
    ]
  })
}