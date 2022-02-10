#!/bin/env bash

set -e

echo "Initializing master node [${HOSTNAME}:${NODE_IP}]: ${K8S_VERSION}"

kubeadm config images pull
kubeadm init --kubernetes-version ${K8S_VERSION} --node-name ${HOSTNAME} --apiserver-cert-extra-sans=${NODE_IP} --token ppozut.y9dh2r1bdowfay3x --pod-network-cidr=10.244.0.0/16 --service-cidr=10.96.0.0/16 --apiserver-advertise-address 192.168.56.4

su - vagrant -c "mkdir ~/.kube"
cp /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown -R $(id -u vagrant).$(id -u vagrant) /home/vagrant/.kube/config

cat << EOF >> /home/vagrant/.bashrc
# kubectl command setup
alias k="kubectl"
source <(kubectl completion bash)
complete -F __start_kubectl k
EOF

# Install tools

## etcdctl
curl -sL https://github.com/etcd-io/etcd/releases/download/v3.5.2/etcd-v3.5.2-linux-amd64.tar.gz| tar --transform 's/^etcd-.*linux-arm64//' -xzvf - etcd-v3.5.2-linux-arm64/etcdctl -C /tmp/
mv ./etcdctl /usr/local/bin/
chmod +x /usr/local/bin/etcdctl

# Cilium networking plutin
#curl -sL https://get.helm.sh/helm-v3.8.0-linux-amd64.tar.gz | tar -xz linux-amd64/helm
#linux-amd64/helm repo add cilium https://helm.cilium.io/
#linux-amd64/helm install cilium cilium/cilium --version 1.11.1 --namespace kube-system --wait

# Flannel networking plugin
#kubectl apply -f https://github.com/coreos/flannel/raw/master/Documentation/kube-flannel.yml
#kubectl create -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel-rbac.yml
#kubectl wait pod --for condition=ready --all -n kube-system --timeout=300s

# Calico
su - vagrant "kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml"

# kubeadm token create --print-join-command
# Fix wrong internal ip
# /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
# --node-ip=<IP>