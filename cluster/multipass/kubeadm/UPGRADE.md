
# CONTROL NODES

## Check available versions
```
apt-cache policy kubeadm | grep "1.20"
```
## Drain node(s)
```
k get no
NAME                STATUS   ROLES    AGE   VERSION
kubeadm-control-1   Ready    master   21m   v1.19.16
kubeadm-worker-1    Ready    <none>   13m   v1.19.16
kubeadm-worker-2    Ready    <none>   11m   v1.19.16

k drain kubeadm-control-1 --ignore-daemonsets
k cordon kubeadm-control-1
```
## Upgrade `kubeadm` package(s)
```
sudo apt-get install -y kubeadm=1.20.15-00
```
## Check version
```
kubeadm version -o short
v1.20.15
```
## Get plan and upgrade
```
sudo kubeadm upgrade plan
sudo kubeadm upgrade apply v1.20.15
```
## Upgrade remaining packages
```
sudo apt-get install -y kubelet=1.20.15-00 kubectl=1.20.15-00
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
```
k drain kubeadm-worker-1 --ignore-daemonsets
k cordon kubeadm-worker-1
```
## Upgrade `kubeadm` package(s)
```
sudo apt-get install -y kubeadm=1.20.15-00
```
## Check version
```
kubeadm version -o short
v1.20.15
```
## Upgrade components
```
sudo kubeadm upgrade node
```
## Upgrade remaining packages
```
sudo apt-get install -y kubelet=1.20.15-00 kubectl=1.20.15-00
```
## Restart `kubelet` service
```
sudo systemctl daemon-reload
sudo systemctl restart kubelet.service
sudo journalctl -fu kubelet
```
## Uncordon node
```
k uncordon kubeadm-worker-1
```
