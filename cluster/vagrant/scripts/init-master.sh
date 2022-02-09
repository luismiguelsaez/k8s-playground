#!/bin/env bash

set -e

echo "Initializing master node [${HOSTNAME}:${NODE_IP}]: ${K8S_VERSION}"

kubeadm config images pull
kubeadm init --kubernetes-version ${K8S_VERSION} --node-name ${HOSTNAME} --apiserver-cert-extra-sans=${NODE_IP} --token ppozut.y9dh2r1bdowfay3x --pod-network-cidr=10.244.0.0/16 --service-cidr=10.96.0.0/16 --apiserver-advertise-address 192.168.56.4

mkdir ~/.kube
cp /etc/kubernetes/admin.conf ~/.kube/config

# Cilium networking plutin
#curl -sL https://get.helm.sh/helm-v3.8.0-linux-amd64.tar.gz | tar -xz linux-amd64/helm
#linux-amd64/helm repo add cilium https://helm.cilium.io/
#linux-amd64/helm install cilium cilium/cilium --version 1.11.1 --namespace kube-system --wait

# Flannel networking plugin
#kubectl apply -f https://github.com/coreos/flannel/raw/master/Documentation/kube-flannel.yml
#kubectl create -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel-rbac.yml
#kubectl wait pod --for condition=ready --all -n kube-system --timeout=300s

# Calico
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# kubeadm token create --print-join-command
# Fix wrong internal ip
# /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
# --node-ip=<IP>