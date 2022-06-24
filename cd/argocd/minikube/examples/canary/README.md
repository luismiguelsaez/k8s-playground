
### Install

```bash
kubectl apply -f nginx-ingress.yaml
```

### Upgrade

```bash
kubectl argo rollouts set image rollouts-demo rollouts-demo=argoproj/rollouts-demo:yellow
kubectl argo rollouts get rollout rollouts-demo
```
