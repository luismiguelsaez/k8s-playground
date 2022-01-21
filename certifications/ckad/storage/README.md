# Persistent volumes practice

## Create `pv`
```
cat << EOF | k apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ckad-test
spec:
  storageClassName: normal
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /data/web
  capacity:
    storage: 100Mi
EOF
```

## Create `pvc`
```
cat << EOF | k apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ckad-test
spec:
  storageClassName: normal
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: "50Mi"
    limits:
      storage: "100Mi"
  volumeName: ckad-test
EOF
```

## Create `pod`
```
cat << EOF | k apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: pod-pv
spec:
  initContainers:
    - name: webcontent
      image: busybox
      command:
        - /bin/sh
        - -c
      args:
        - "echo 'TESTING VOLUMES' > /data/web/index.html"
      volumeMounts:
        - name: web
          mountPath: /data/web
  containers:
    - name: nginx
      image: nginx:1.20.1-alpine
      resources:
        requests:
          cpu: 100m
          memory: 50Mi
      volumeMounts:
        - name: web
          mountPath: /usr/share/nginx/html
      ports:
        - name: http
          containerPort: 80
  volumes:
    - name: web
      persistentVolumeClaim:
        claimName: ckad-test
EOF
```

## Test web content
```
k run test --image=busybox --restart=Never -it --rm -l allow-http=true --command -- wget -O- --timeout=2 --server-response http://10.244.0.145
```
```
Connecting to 10.244.0.145 (10.244.0.145:80)
  HTTP/1.1 200 OK
  Server: nginx/1.20.1
  Date: Fri, 21 Jan 2022 11:22:08 GMT
  Content-Type: text/html
  Content-Length: 16
  Last-Modified: Fri, 21 Jan 2022 11:21:08 GMT
  Connection: close
  ETag: "61ea9724-10"
  Accept-Ranges: bytes
  
writing to stdout
TESTING VOLUMES
```
