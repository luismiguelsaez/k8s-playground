provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project = "k8s-test"
      Owner = "luismiguel.saez"
    }
  }
}

#provider "helm" {
#  kubernetes {
#    host = module.eks_cluster.cluster_endpoint
#    token = data.aws_eks_cluster_auth.main.token
#    cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority_data)
#  }
#}
