# https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/18.26.6?tab=inputs
module "eks_cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.26.6"

  create = true

  cluster_name    = var.name
  cluster_version = "1.22"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  manage_aws_auth_configmap = false
  #aws_auth_accounts = [data.aws_caller_identity.current.account_id]
  #aws_auth_roles = [
  #  {
  #    rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Admin"
  #    username = "Admin"
  #    groups   = ["system:masters"]
  #  },
  #]
}

# https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/18.26.6/submodules/eks-managed-node-group?tab=inputs
module "eks-nodegroup-monitoring" {
  source  = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  version = "18.26.6"

  create = true

  name            = "monitoring"
  cluster_name    = module.eks_cluster.cluster_id
  cluster_version = module.eks_cluster.cluster_version

  platform       = "linux"
  capacity_type  = "ON_DEMAND"
  instance_types = [ "t3a.medium","t3.medium","c5a.large","c5.large" ]

  min_size     = 1
  desired_size = 2
  max_size     = 5

  vpc_id                            = module.vpc.vpc_id
  subnet_ids                        = module.vpc.private_subnets
  cluster_primary_security_group_id = module.eks_cluster.cluster_primary_security_group_id
  vpc_security_group_ids            = [ module.eks_cluster.cluster_security_group_id ]

  tags = {
    "k8s.io/cluster-autoscaler/enabled" = "true",
    "k8s.io/cluster-autoscaler/${var.name}" = "owned"
  }

  metadata_options = {
    "http_endpoint": "enabled",
    "http_put_response_hop_limit": "2",
    "http_tokens": "required"
  }

  labels = {
    "role": "monitoring",
    "env": "dev",
    "project": "k8s-test",
    "service": "monitoring"
  }

  #depends_on = [ helm_release.cilium ]
}
