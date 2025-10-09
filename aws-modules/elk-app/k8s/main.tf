# security group for jump server
data "aws_subnet" "private_subnet" {
  id = var.cluster_subnet_ids[0]
}

resource "aws_security_group" "default_sg" {
  name   = "${terraform.workspace}-elk-cluster-user-sg"
  vpc_id = data.aws_subnet.private_subnet.vpc_id

  tags = {
    Name = "${terraform.workspace}-elk-cluster-default-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  count             = length(var.jump_server_ports)
  security_group_id = aws_security_group.default_sg.id
  cidr_ipv4         = "${var.jump_server_ip}/0"
  from_port         = var.jump_server_ports[count.index]
  to_port           = var.jump_server_ports[count.index]
  ip_protocol       = "tcp"
}

# cluster
resource "aws_eks_cluster" "elk_cluster" {
  name = "${terraform.workspace}-elk-eks-cluster"

  access_config {
    authentication_mode = "API"
  }

  role_arn = aws_iam_role.cluster.arn
  version  = var.cluster_version

  kubernetes_network_config {
    ip_family         = "ipv4"
    service_ipv4_cidr = var.pods_ip_cidr
  }

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true

    security_group_ids = [aws_security_group.default_sg.id]
    subnet_ids         = var.cluster_subnet_ids
  }

  depends_on = [
    # wait for iam role and policy attachment
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]
}

resource "aws_iam_role" "eks_cluster" {
  name = "${terraform.workspace}-eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

# Node Groups
resource "aws_iam_role" "elk_eks_node_group" {
  name = "${terraform.workspace}-eks-node-group-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "elk-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.elk_eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "elk-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.elk_eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "elk-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.elk_eks_node_group.name
}



resource "aws_eks_node_group" "example" {
  count           = length(var.node_groups)
  cluster_name    = aws_eks_cluster.elk_cluster.name
  node_group_name = var.node_groups[count.index].name
  node_role_arn   = aws_iam_role.example.arn
  subnet_ids      = var.cluster_subnet_ids

  disk_size      = var.node_groups[count.index].disk_size
  instance_types = [var.node_groups[count.index].instance_type]

  scaling_config {
    desired_size = var.node_groups[count.index].group_size
    max_size     = var.node_groups[count.index].group_size
    min_size     = var.node_groups[count.index].group_size
  }

  labels = {
    node-group-name = var.node_groups[count.index].name
  }

  update_config {
    max_unavailable = 1
  }

  # wait for iam role and policy attachment
  depends_on = [
    aws_iam_role_policy_attachment.elk-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.elk-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.elk-AmazonEC2ContainerRegistryReadOnly,
  ]
}