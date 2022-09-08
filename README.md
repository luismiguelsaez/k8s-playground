# K8S playground

## Create cluster ( ingress enabled )
```
kind create cluster --name 4-nodes-ingress-enabled --config=kind-cluster-4no-ingress.yml
```

## Install ingress controller ( watches all namespaces by default )
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml
```

## Delete cluster
```
kind create cluster --name 4-nodes-ingress-enabled
```

## K3D cluster bootstrap
```bash
k3d cluster create --config cluster/k3d/k3d.yaml

helm upgrade --install argocd argo/argo-cd -n argocd --values cd/argocd/minikube/values.yaml --create-namespace --version 4.10.6 --wait

kubectl port-forward svc/argocd-cicd-main 8080:80 -n argocd
```

## Minikube cluster bootstrap
```bash
minikube start --kubernetes-version=1.22.3 --driver=docker --nodes=3 --cpus max --memory=2048m --cni cilium --container-runtime=containerd --addons=ingress
```
