# https://registry.terraform.io/modules/cloudposse/helm-release/aws/0.5.0
resource "helm_release" "cilium" {
  name  = "cilium"
  chart = "https://github.com/cilium/charts/raw/master/cilium-1.12.0.tgz"

  create_namespace     = false
  namespace = "kube-system"

  wait = false

  values = [
    file("cilium/values.yaml")
  ]
}
