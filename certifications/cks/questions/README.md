
# TLS setup

```bash
multipass exec kubeadm-control-1 -- bash
```

## Apiserver

- Check available options
```bash
sudo crictl exec a14aee396e7c7 kube-apiserver --help | grep tls
```

- Modify config
```bash
vi /etc/kubernetes/manifests/kube-apiserver.yaml
```
```yaml
spec:
  containers:
  - command:
    - kube-apiserver
    - --tls-min-version=VersionTLS13
    - --tls-cipher-suites=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
```

## Etcd

- Check available options
```bash
sudo crictl exec 3815e01f383db etcd --help | grep cipher
```

- Modify config
```bash
vi /etc/kubernetes/manifests/etcd.yaml
```
```yaml
spec:
  containers:
  - command:
    - etcd
    - --cipher-suites=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
```
