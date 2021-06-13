
This is a test to see how default k8s internal DNS works. We're creating a deployment and exposing it through a `ClusterIP` and a `headless` service.

## Apply the manifests
```
k apply -f deployment.yaml
k apply -f service.yaml
```

## List the created resources
```
kgp -n nginx
NAME                     READY   STATUS    RESTARTS   AGE
nginx-7fb7fd49b4-2zwgs   1/1     Running   0          23m
nginx-7fb7fd49b4-dcv2d   1/1     Running   0          23m
nginx-7fb7fd49b4-th6kw   1/1     Running   0          23m
```

```
❯ kgs -n nginx
NAME             TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
nginx            ClusterIP   10.109.34.234   <none>        80/TCP    12m
nginx-headless   ClusterIP   None            <none>        80/TCP    12m
```

## Check resolver configuration

### Pod internal file
```
k run test --rm=true -it --image=alpine:3.11 --restart=Never --command -- sh

/ # cat /etc/resolv.conf
nameserver 10.96.0.10
search default.svc.cluster.local svc.cluster.local cluster.local
options ndots:5
```

### Headless service DNS resolution

The `headless`service will return the underlying pods IPs
```
/ # nslookup nginx-headless.nginx.svc.cluster.local
Server:		10.96.0.10
Address:	10.96.0.10:53


Name:	nginx-headless.nginx.svc.cluster.local
Address: 172.17.0.3
Name:	nginx-headless.nginx.svc.cluster.local
Address: 172.17.0.4
Name:	nginx-headless.nginx.svc.cluster.local
Address: 172.17.0.5
```

### ClusterIP service DNS resolution

The `ClusterIP` service will return the service IP
```
/ # nslookup nginx.nginx.svc.cluster.local
Server:		10.96.0.10
Address:	10.96.0.10:53


Name:	nginx.nginx.svc.cluster.local
Address: 10.109.34.234
```

### Services connection
```
/ # curl nginx-headless.nginx.svc.cluster.local -o/dev/null -s -w "%{http_code}\n"
200

/ # curl nginx.nginx.svc.cluster.local -o/dev/null -s -w "%{http_code}\n"
200
```