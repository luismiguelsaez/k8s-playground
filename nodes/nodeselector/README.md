
## Create cluster ( minikube )
### Start kubernetes multi-node cluster
```
❯ minikube start --nodes 3 -p multinode-test
```
### Check status
```
❯ kgno
NAME                 STATUS   ROLES                  AGE     VERSION
multinode-test       Ready    control-plane,master   2m50s   v1.20.2
multinode-test-m02   Ready    <none>                 2m5s    v1.20.2
multinode-test-m03   Ready    <none>                 74s     v1.20.2
```
### Add label to nodes
```
❯ kubectl label nodes multinode-test-m02 app=db
❯ kubectl label nodes multinode-test-m03 app=web
```
```
❯ kubectl get nodes -l app=web
NAME                 STATUS   ROLES    AGE   VERSION
multinode-test-m03   Ready    <none>   13m   v1.20.2

❯ kubectl get nodes -l app=db
NAME                 STATUS   ROLES    AGE   VERSION
multinode-test-m02   Ready    <none>   14m   v1.20.2
```

## Deploy logging forwarder
### Add helm repo
```
❯ helm repo add fluent https://fluent.github.io/helm-charts
```
### Install chart
```
❯ k create namespace logging
❯ helm install fluentbit fluent/fluent-bit --version 0.15.14 -f values-fluentbit.yaml -n logging
```

## Deploy nginx
### Apply manifest
```
❯ k apply -f deployment-nginx.yaml
```
### Test service
```
❯ k run test --rm=true -it --image=busybox --restart=Never --command -- wget nginx.nginx.svc.cluster.local -O- --quiet
```
### Check nodeAffinity
```
❯ k get pods -ogo-template='{{ range .items }}{{ printf "%s\n" .spec.nodeName }}{{ end }}' -n nginx
multinode-test-m03
multinode-test-m03
multinode-test-m03
```

## Deploy mongodb
### Add helm repo
```
❯ helm repo add bitnami https://charts.bitnami.com/bitnami
```
### Install chart
```
k create namespace mongodb
helm install mongodb bitnami/mongodb --version 10.19.0 -f values-mongodb.yaml -n mongodb
```
### Check nodeAffinity
```
❯ k get pods -ogo-template='{{ range .items }}{{ printf "%s\n" .spec.nodeName }}{{ end }}' -n mongodb
multinode-test-m02
```