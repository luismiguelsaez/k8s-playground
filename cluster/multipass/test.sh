k create deploy nginx --image=nginx:1.20.1-alpine --replicas=6 --port=80
k expose deploy nginx --name=nginx --port=8080 --target-port=80
k run test-nginx --image=busybox --restart=Never --rm -it --command -- wget --server-response --timeout=2 http://nginx.default.svc.cluster.local:8080
