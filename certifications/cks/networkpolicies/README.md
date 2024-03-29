
- Create namespaces
```bash
k create ns frontend
k create ns backend
```

- Apply ingress deny all policy
```bash
k apply -f ingress-deny-all.yaml -n frontend
k apply -f ingress-deny-all.yaml -n backend
```

- Create pods
```bash
k run nginx --image nginx:1.20.1-alpine -n frontend -l app=frontend
k create deploy nginx-backend -n backend --image nginx:1.20.1 --port 80 --replicas 3
k expose deploy nginx-backend -n backend --type ClusterIP --port 80
```

- Apply frontend policies
```bash
k apply -f egress-frontend.yaml -n frontend
```

- Check connectivity frontend -> backend
```bash
k exec -it -n frontend nginx -- sh -c "curl nginx-backend.backend.svc.cluster.local"
```

- Apply backend policies
```bash
k apply -f ingress-backend.yaml -n backend
k apply -f egress-backend.yaml -n backend
```
