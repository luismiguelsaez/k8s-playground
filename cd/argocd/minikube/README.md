
## Create minikube cluster

- Start minikube
  - Simple
    ```bash
    minikube start --addons=ingress
    ```

  - Multi node
    ```bash
    minikube start --kubernetes-version=1.22.3 --driver=docker --nodes=3 --container-runtime=containerd --addons=ingress
    ```

## Bootstrap ArgoCD

```bash
helm upgrade --install argocd argo/argo-cd -n argocd --values values.yaml --create-namespace --version 4.10.6 --wait
```

## Connecto to ArgoCD UI

- Get IP and host to configure `/etc/hosts` file ( Linux only )
```bash
kubectl get ingress -n argocd argocd-cicd-main -o jsonpath="{.status.loadBalancer.ingress[0].ip}"
kubectl get ingress -n argocd argocd-cicd-main -o jsonpath="{.spec.rules[0].host}"
```

- Open tunnel
```bash
k port-forward svc/argocd-cicd-main 8080:80 -n argocd
k port-forward svc/prometheus-stack-grafana 8080:80 -n monitoring
k port-forward svc/kube-prom-prometheus 8080:9090 -n monitoring
```