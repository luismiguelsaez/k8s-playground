
# Create cluster with the right version
## Check exam version
- URL: https://training.linuxfoundation.org/certification/certified-kubernetes-administrator-cka/
## Create a cluster
```
minikube start --cni=cilium --kubernetes-version=1.22.3 --driver=virtualbox --nodes=3 --container-runtime=containerd 
```
