

# Testing CPU throttling

```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts

helm upgrade --install --create-namespace -n monitoring prometheus-server prometheus-community/prometheus --version 19.3.3
helm upgrade --install --create-namespace -n monitoring prometheus-crds prometheus-community/prometheus-operator-crds --version 1.1.0
helm upgrade --install --create-namespace -n monitoring grafana-server grafana/grafana --version 6.50.7 -f grafana-values.yaml

k apply -f pod.yaml -n default

k get secret grafana-server -o jsonpath="{.data.admin-password}" | base64 -d
k port-forward svc/prometheus-server-server 8080:80
k port-forward svc/grafana-server 8080:80
```

- Check metrics
  ```sql
  avg by (pod) (kube_pod_container_resource_limits{pod="resources-test",resource="cpu"})

  avg by (pod) (rate(container_cpu_usage_seconds_total{pod="resources-test"}[5m]))

  avg by (pod) (rate(container_cpu_cfs_throttled_seconds_total{pod="resources-test"}[5m]))
  ```


```bash
POD_IP=$(k get po -n default resources-test -o jsonpath='{.items[0].status.podIP}')

k run request --image busybox -it --rm  -- sh -c "wget http://${POD_IP}:8080/ConsumeCPU --timeout=2 --quiet --post-data='millicores=100&durationSec=60' -O-"
k run request --image busybox -it --rm  -- sh -c "wget http://${POD_IP}:8080/ConsumeMem --timeout=2 --quiet --post-data='megabytes=300&durationSec=60' -O-"
```
