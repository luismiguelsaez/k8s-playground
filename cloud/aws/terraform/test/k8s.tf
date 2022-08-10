resource "helm_release" "cilium" {
  name  = "cilium"
  chart = "https://github.com/cilium/charts/raw/master/cilium-1.12.0.tgz"

  create_namespace = false
  namespace = "kube-system"

  wait = false

  values = [
    file("cilium/values.yaml")
  ]
}

# https://registry.terraform.io/modules/cloudposse/helm-release/aws/0.5.0
module "helm_release" {
  source  = "cloudposse/helm-release/aws"
  version = "0.5.0"

  name = "argocd"

  repository    = "https://argoproj.github.io/argo-helm"
  chart         = "argo-cd"
  chart_version = "4.10.4"

  create_namespace     = true
  kubernetes_namespace = "argocd"

  atomic          = false
  cleanup_on_fail = false
  timeout         = "300"
  wait            = false

  eks_cluster_oidc_issuer_url = module.eks_cluster.cluster_oidc_issuer_url

  values = [
    templatefile(
      "argocd/values.yaml",
      {
        argoCDHost              = "",
        adminPass               = bcrypt("admin"),
        corpRepoUrl             = "https://github.com/luismiguelsaez/",
        corpRepoToken           = "",
        repoUrl                 = "https://github.com/luismiguelsaez/argocd-playground",
        repoPath                = "overlays/test",
        repoToken               = "",
        oktaCAData              = base64encode(""),
        oktaIssuer              = "http://www.okta.com/00000000000",
        oktaSSOUrl              = "https://umbrellacorp.okta.com/app/argocd_1/00000000000/sso/saml",
        certificateArn          = "",
        notificationsSlackToken = "",
        vault_addr              = "https://vault.umbrellacorp.cloud",
        vault_token             = "",
      }
    )
  ]

  depends_on = [module.eks-nodegroup-monitoring]
}
