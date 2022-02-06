kubectl create deploy nginx --image=nginx:1.20.1-alpine --replicas=6 --port=80
kubectl expose deploy nginx --type=ClusterIP --name=nginx-cip --port=8080 --target-port=80
kubectl expose deploy nginx --type=NodePort --name=nginx-np --port=8080 --target-port=80

kubectl run test-nginx --image=busybox --restart=Never --rm -it --command -- wget -O- --server-response --timeout=2 http://nginx-cip.default.svc.cluster.local:8080
