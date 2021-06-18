
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
