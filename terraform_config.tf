provider "aws" {
  region = var.region
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "DevOps Assessment VPC"
  }
}

resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index}.0/24"
  availability_zone = "${var.region}${count.index == 0 ? "a" : "b"}"
  
  tags = {
    Name = "Public Subnet ${count.index + 1}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "Main Internet Gateway"
  }
}

resource "aws_iam_role" "eks_cluster" {
  name = "devops-assessment-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_eks_cluster" "primary" {
  name     = "devops-assessment-cluster"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = aws_subnet.public[*].id
  }
}

resource "aws_iam_role" "eks_nodes" {
  name = "devops-assessment-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_eks_node_group" "primary_nodes" {
  cluster_name    = aws_eks_cluster.primary.name
  node_group_name = "devops-assessment-node-pool"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = aws_subnet.public[*].id

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 2
  }

  instance_types = ["t3.medium"]
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-west-2"
}