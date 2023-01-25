#!/bin/env bash

set -e

K8S_VERSION=${1:-"1.22.13"}
HOSTNAME=${2:-"default-master"}
NODE_IP=${3:-"127.0.0.1"}

CILIUM_CLI_URL="https://github.com/cilium/cilium-cli/releases/download/v0.12.12/cilium-linux-arm64.tar.gz"

echo "Initializing master node [${HOSTNAME}:${NODE_IP}]: ${K8S_VERSION}"

kubeadm config images pull
kubeadm init --kubernetes-version ${K8S_VERSION} --node-name ${HOSTNAME} --apiserver-cert-extra-sans=${NODE_IP} --token ppozut.y9dh2r1bdowfay3x --pod-network-cidr=10.244.0.0/16 --service-cidr=10.96.0.0/16 --apiserver-advertise-address ${NODE_IP}

su - ubuntu -c "mkdir ~/.kube"
cp /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
chown -R $(id -u ubuntu).$(id -u ubuntu) /home/ubuntu/.kube/config

# Copy config file to shared folder
#cp /etc/kubernetes/admin.conf /ubuntu/kubeadm.conf

cat << EOF >> /home/ubuntu/.bashrc
# kubectl command setup
alias k="kubectl"
source <(kubectl completion bash)
complete -F __start_kubectl k
EOF

# Install tools

## cilium
curl -sL ${CILIUM_CLI_URL} -o- | tar -xz -C /usr/local/bin

## etcdctl

curl -sL https://github.com/etcd-io/etcd/releases/download/v3.5.7/etcd-v3.5.7-linux-arm64.tar.gz | tar -xz -C /tmp/
cp /tmp/etcd-*-arm64/etcdctl /usr/local/bin
rm -rf /tmp/etcd-*-arm64

## helm

curl -sL https://get.helm.sh/helm-v3.8.0-linux-arm64.tar.gz | tar -xz -C /tmp
mv /tmp/linux-arm64/helm /usr/local/bin
rm -rf /tmp/linux-arm64
