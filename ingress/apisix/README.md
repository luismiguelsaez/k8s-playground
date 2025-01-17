
## Helm setup
```bash
helm repo add apisix https://charts.apiseven.com
helm repo add bitnami https://charts.bitnami.com/bitnami

helm upgrade --kube-context stage --install apisix-redis bitnami/redis --version 20.3.0 -n apisix --create-namespace -f values-redis.yaml
helm upgrade --kube-context stage --install apisix apisix/apisix --version 2.10.0 -n apisix --create-namespace -f values-apisix.yaml -f values-apisix-stage.yaml
```
## Create ingress
```bash
kubectl --context stage apply -f ingress.yaml
```

## Issues

- Whenever an `ApisixUpstream` resource is created, the ingress controller continuously logs the error:
```
2024-12-17T23:26:59+08:00       error   apisix/apisix_upstream.go:333   failed to get upstream identity-stage_admin-api-stage_80_service: not found
```

  - [Related issue](https://github.com/apache/apisix-ingress-controller/issues/1855)