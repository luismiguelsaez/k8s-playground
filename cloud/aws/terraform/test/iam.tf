# https://registry.terraform.io/modules/cloudposse/eks-iam-role/aws/1.1.0?tab=inputs
module "eks_iam_role_lb_controller" {
  source  = "cloudposse/eks-iam-role/aws"
  version = "1.1.0"

  aws_account_number          = data.aws_caller_identity.current.account_id
  eks_cluster_oidc_issuer_url = module.eks_cluster.cluster_oidc_issuer_url

  service_account_name      = "aws-load-balancer-controller"
  service_account_namespace = "kube-system"
  aws_iam_policy_document = file("aws-load-balancer-controller/iam-policy.json")
}

module "eks_iam_role_external_dns" {
  source  = "cloudposse/eks-iam-role/aws"
  version = "1.1.0"

  aws_account_number          = data.aws_caller_identity.current.account_id
  eks_cluster_oidc_issuer_url = module.eks_cluster.cluster_oidc_issuer_url

  service_account_name      = "external-dns"
  service_account_namespace = "kube-system"
  aws_iam_policy_document = file("external-dns/iam-policy.json")
}
