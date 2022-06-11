
## Create minikube cluster

- Start minikube
  - Simple
    ```bash
    minikube start --addons=ingress
    ```

  - Multi node
    ```bash
    minikube start --cni=cilium --kubernetes-version=1.22.3 --driver=virtualbox --nodes=3 --container-runtime=containerd --addons=ingress
    ```

## Bootstrap ArgoCD

```bash
helm install argocd argo/argo-cd -n argocd --values values.yaml --create-namespace --version 3.35.4
kubectl wait pod -l app.kubernetes.io/instance=argocd --for=condition=Ready -n argocd --timeout=300s
```

## Connecto to ArgoCD UI

- Get IP and host to configure `/etc/hosts` file
```bash
kgi -n argocd argocd-cicd-main -o jsonpath="{.status.loadBalancer.ingress[0].ip}"
kgi -n argocd argocd-cicd-main -o jsonpath="{.spec.rules[0].host}"
```
