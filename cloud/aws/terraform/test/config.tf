provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project = "k8s-test"
      Owner = "luismiguel.saez"
    }
  }
}

provider "helm" {
  kubernetes {
    host = data.aws_eks_cluster.main.endpoint
    token = data.aws_eks_cluster_auth.main.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority[0].data)
  }
}
