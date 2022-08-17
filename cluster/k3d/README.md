
## Create cluster

```bash
k3d cluster create --config k3d.yaml
```

## Create tunnel to reach LB

```bash
kubectl -n kube-system port-forward svc/traefik 8080:80
```

