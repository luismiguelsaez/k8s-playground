
# Create cluster with the right version

## Check exam version
- URL: https://training.linuxfoundation.org/certification/certified-kubernetes-administrator-cka/

## Create a cluster
```
minikube start --cni=cilium --kubernetes-version=1.22.3 --driver=virtualbox --nodes=3 --container-runtime=containerd 
```

## Debugging commands

### Connect to minikube nodes
For CKA certification, you will need to SSH into the nodes to be able to troubleshoot problems, so it is useful to simulate it in your local environment
```
k get no

NAME           STATUS   ROLES                  AGE     VERSION
minikube       Ready    control-plane,master   15m     v1.22.3
minikube-m02   Ready    <none>                 4m59s   v1.22.3
minikube-m03   Ready    <none>                 3m42s   v1.22.3
```
```
minikube ssh -n minikube-m02
```

## Exercises and references

- https://www.katacoda.com/djkormo
- https://github.com/alijahnas/CKA-practice-exercises
- https://github.com/scriptcamp/vagrant-kubeadm-kubernetes
- https://devopscube.com/kubernetes-cluster-vagrant/
