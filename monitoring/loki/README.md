
## Helm

```
helm repo add grafana https://grafana.github.io/helm-charts

helm upgrade --install loki grafana/loki -n monitoring --version 4.6.0 --create-namespace --values config/values-loki.yaml
helm upgrade --install promtail grafana/promtail -n monitoring --version 6.8.2 --create-namespace --values config/values-promtail.yaml
helm upgrade --install grafana grafana/grafana -n monitoring --version 6.50.7 --create-namespace --values config/values-grafana.yaml
```

## Create test deployment

```
k create deploy nginx --image nginx:1.23-alpine --replicas 3 -n default
k expose deploy nginx --type ClusterIP --port 80 -n default
```

## Access

```
k port-forward svc/grafana 8080:80 -n monitoring
```
