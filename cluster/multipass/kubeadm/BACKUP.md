# ETCD
## Check connection
```
kubectl exec -it etcd-kubeadm-control-1 -n kube-system -- etcdctl --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key member list

kubectl exec -it etcd-kubeadm-control-1 -n kube-system -- etcdctl --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key endpoint status --write-out=table

kubectl exec -it etcd-kubeadm-control-1 -n kube-system -- etcdctl --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key get --prefix /registry/pods/default --keys-only
```
## Create snapshot file
```
kubectl exec -it etcd-kubeadm-control-1 -n kube-system -- etcdctl --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key snapshot save /tmp/snapshot.data

kubectl exec -it etcd-kubeadm-control-1 -n kube-system -- etcdctl --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key snapshot status /tmp/snapshot.data
```

