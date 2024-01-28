variable "create_eks_cluster" {
  description = "Whether to create the EKS cluster or not"
  default     = true
}

# IAM Policy Document for EKS Cluster Role
data "aws_iam_policy_document" "assume_role_eks" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# IAM Role for EKS Cluster
resource "aws_iam_role" "eks_cluster" {
  name               = "eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_eks.json
}

# Attach EKS Cluster Policy to IAM Role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Get subnets for EKS Cluster
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Create EKS Cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = "EKS_CLOUD"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = data.aws_subnets.public.ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
  ]
}

# IAM Policy Document for EKS Node Group Role
data "aws_iam_policy_document" "assume_role_eks_node_group" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# IAM Role for EKS Node Group
resource "aws_iam_role" "eks_node_group" {
  name               = "eks-node-group-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_eks_node_group.json
}

# Attach EKS Worker Node Policy to IAM Role
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group.name
}

# Attach EKS CNI Policy to IAM Role
resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group.name
}

# Attach ECR Read Only Policy to IAM Role
resource "aws_iam_role_policy_attachment" "ecr_read_only_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group.name
}

# Create EKS Node Group
resource "aws_eks_node_group" "eks_node_group" {
  count           = var.create_eks_cluster ? 1 : 0
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "eks-node-group"
  node_role_arn   = aws_iam_role.eks_node_group.arn
  subnet_ids      = data.aws_subnets.public.ids

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }
  instance_types = ["t2.medium"]

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ecr_read_only_policy,
  ]
}
