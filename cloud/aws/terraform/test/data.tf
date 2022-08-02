
data "aws_caller_identity" "current" {}

data "aws_eks_cluster_auth" "main" {
  name = module.eks_cluster.cluster_id
}

data "aws_eks_cluster" "main" {
  name = module.eks_cluster.cluster_id
}
