
# CONTROL NODES

## Check available versions
```
apt-cache policy kubeadm | grep "1.19"
```
## Upgrade `kubeadm` package(s)
```
sudo apt-get install kubeadm=1.19.16-00 kubectl=1.19.16-00 kubelet=1.19.16-00
```
## Drain node
```
kubectl drain kubeadm-control-01
kubectl cordon kubeadm-control-01
```
## Get plan and upgrade `kubeadm`
```
sudo kubeadm upgrade plan
sudo kubeadm upgrade apply v1.19.16
```
## Restart `kubelet` service
```
sudo systemctl daemon-reload
sudo systemctl restart kubelet.service
sudo journalctl -fu kubelet
```
## Uncordon node
```
kubeadm uncordon kubeadm-control-01
```

# WORKER NODES
## Drain and cordon node
## Upgrade `kubeadm` package(s)
```
sudo apt-get install kubeadm=1.19.16-00 kubectl=1.19.16-00 kubelet=1.19.16-00
```
## Upgrade components
```
sudo kubeadm upgrade node
```
## Restart `kubelet` service
```
sudo systemctl daemon-reload
sudo systemctl restart kubelet.service
sudo journalctl -fu kubelet
```
## Uncordon node

# TEST CLUSTER
```
kubectl create deploy nginx --image=nginx:1.21-alpine --replicas=4 --port=80
kubectl expose deploy nginx --port=8080 --target-port=80
kubectl run test-connection --image=busybox -it --rm --restart=Never -- wget -O- --timeout=2 http://nginx.default.svc.cluster.local:8080
```
