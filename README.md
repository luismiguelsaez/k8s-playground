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
