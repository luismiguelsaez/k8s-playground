
module "eks_cluster" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.6.1"

  cluster_version           = "1.22"
  vpc_id                    = module.vpc.vpc_id
  private_subnet_ids        = module.vpc.private_subnets

  managed_node_groups = {
    t3_medium = {
      node_group_name = "managed-ondemand"
      instance_types  = ["t3.medium","t3a.medium"]
      subnet_ids      = module.vpc.private_subnets
    }
  }
}

# https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/modules/kubernetes-addons#inputs
module "eks_blueprints_kubernetes_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=v4.0.2"

  eks_cluster_id = module.eks_cluster.eks_cluster_id

  enable_argocd                       = true
  enable_aws_load_balancer_controller = true
  argocd_manage_add_ons               = false

  argocd_helm_config = {
    name             = "argo-cd"
    chart            = "argo-cd"
    repository       = "https://argoproj.github.io/argo-helm"
    version          = "3.36.4"
    namespace        = "argocd"
    timeout          = "1200"
    create_namespace = true
    values = [templatefile("${path.module}/argocd-values.yaml", {})]
  }
}
