
# Server bootstrapping

- https://rtfm.co.ua/en/argocd-declarative-projects-applications-and-argocd-deploy-from-jenkins/#Projects

## Create cluster
```bash
kind create cluster --name argo-test --config kind-cluster-4no-ingress.yml
```
## ArgoCD charts
https://github.com/argoproj/argo-helm/tree/master/charts
## Add repository
```bash
helm repo add argo https://argoproj.github.io/argo-helm
```
## Install ArgoCD
```bash
kubectl create ns argocd
helm upgrade --install argocd argo/argo-cd --wait -n argocd --values values.yaml --create-namespace --version 4.10.6
kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=argocd --timeout=300s -n argocd
```
## Connect ArgoCD
### Get admin user initial password
```
kubectl get secret argocd-initial-admin-secret -o jsonpath={.data.password} | base64 -d
```
### Create tunnel ( local testing minikube )
```
kubectl port-forward service/argocd-server 8080:80
```

# ArgoCD applications ( CLI )
## Login
```
argocd login 127.0.0.1:8080 --insecure --username admin --password $(kubectl get secret argocd-initial-admin-secret -o jsonpath={.data.password} | base64 -d)
```
## Create sample blue-green application ( https://github.com/argoproj/argocd-example-apps/tree/master/blue-green )
### Install rollouts controller ( https://github.com/argoproj/argo-rollouts#installation )
```
kubectl create namespace argo-rollouts
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
k wait --for=condition=ready pod -l app.kubernetes.io/name=argo-rollouts --timeout=300s -n argo-rollouts
```
### Create application
```
argocd app create --name blue-green --repo https://github.com/argoproj/argocd-example-apps --dest-server https://kubernetes.default.svc --dest-namespace default --path blue-green
k wait --for=condition=ready pod -l app=helm-guestbook --timeout=300s -n default
argocd app sync blue-green
```
