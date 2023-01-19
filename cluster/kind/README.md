
## Create basic cluster with Cilium CNI

- Kind: https://kind.sigs.k8s.io/docs/user/configuration/
- Cilium: https://docs.cilium.io/en/stable/gettingstarted/k8s-install-helm/

```bash
kind create cluster --config=basic.yaml

helm repo add cilium https://helm.cilium.io/
helm upgrade --install cilium cilium/cilium --version $(curl -s https://raw.githubusercontent.com/cilium/cilium/master/stable.txt) --namespace kube-system --set hubble.enabled=true
```