
## Customized Helm chart

### Create repository
*Set the repository name to the `name` field in the chart's `Chart.yml` file*
```bash
aws ecr-public --profile maroot create-repository --repository-name apisix --region us-east-1
```
### Login to the registry
```bash
aws ecr-public --profile maroot get-login-password --region us-east-1 | helm registry login --username AWS --password-stdin public.ecr.aws
```
### Create package
```bash
helm package ~/github/apisix-helm-chart/charts/apisix
```
### Push package
```bash
helm push apisix-2.9.0.tgz oci://public.ecr.aws/mechanicadvisor
```
### Show values
```bash
helm show values oci://public.ecr.aws/mechanicadvisor/apisix --version 2.9.0
```
### Deploy
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami

helm upgrade --kube-context stage --install apisix-redis bitnami/redis --version 20.3.0 -n apisix --create-namespace -f values-redis.yaml
helm upgrade --kube-context stage --install apisix oci://public.ecr.aws/mechanicadvisor --version 2.9.0 -n apisix --create-namespace -f values-apisix.yaml -f values-apisix-stage.yaml
```

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