# Networkpolicy practice

## Create compatible `minikube` cluster
```
minikube start -n 2 --driver=docker --cni=cilium
```

## Create exposed pod(s)
```
k run nginx --image=nginx --restart=OnFailure --port=80 --expose
```

## Check connection ( without `networkpolicy` )
```
k run test --image=busybox --restart=Never -it --rm -l allow-http=true --command -- wget --quiet --timeout=2 --server-response http://nginx.default.svc
```
```
  HTTP/1.1 200 OK
  Server: nginx/1.21.5
  Date: Fri, 21 Jan 2022 10:56:01 GMT
  Content-Type: text/html
  Content-Length: 615
  Last-Modified: Tue, 28 Dec 2021 15:28:38 GMT
  Connection: close
  ETag: "61cb2d26-267"
  Accept-Ranges: bytes
```

## Create `networkpolicy`
```
cat << EOF > networkpolicy.yaml
apiVersion: networking.k8s.io/v1 
kind: NetworkPolicy
metadata:
  name: nginx
spec:
  podSelector:
    matchLabels:
      run: nginx 
  policyTypes:
    - Ingress
  ingress:
    - from:
      - podSelector:
          matchLabels:
            allow-http: "true"
      ports:
        - protocol: TCP
          port: 80
EOF
```
```
k apply -f networkpolicy.yaml
```

## Check connection ( with `networkpolicy` )
### Without `networkpolicy` `podSelector` label
```
k run test --image=busybox --restart=Never -it --rm--command -- wget --quiet --timeout=2 --server-response http://nginx.default.svc
```
```
wget: download timed out
```
### With `networkpolicy` `podSelector` label
```
k run test --image=busybox --restart=Never -it --rm -l allow-http=true --command -- wget --quiet --timeout=2 --server-response http://nginx.default.svc
```
```
  HTTP/1.1 200 OK
  Server: nginx/1.21.5
  Date: Fri, 21 Jan 2022 10:58:37 GMT
  Content-Type: text/html
  Content-Length: 615
  Last-Modified: Tue, 28 Dec 2021 15:28:38 GMT
  Connection: close
  ETag: "61cb2d26-267"
  Accept-Ranges: bytes
```

## Cleanup
```
k delete svc nginx
k delete po nginx --grace-period=0 --force
k delete -f networkpolicy.yaml
```
