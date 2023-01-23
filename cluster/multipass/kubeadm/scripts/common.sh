#!/bin/env bash

set -e

K8S_VERSION=${1:-"1.22.13"}
HOSTNAME=${2:-"default"}
NODE_IP=${3:-"127.0.0.1"}

CONTAINERD_RELEASE="https://github.com/containerd/containerd/releases/download/v1.6.15/containerd-1.6.15-linux-arm64.tar.gz"

echo "Installing K8s packages [${HOSTNAME}:${NODE_IP}]: ${K8S_VERSION}"

# Configure system
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
swapoff -a

cat << EOF > /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
modprobe br_netfilter
modprobe overlay

cat << EOF > /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-ip6tables=1
net.bridge.bridge-nf-call-iptables=1 
net.ipv4.ip_forward=1                
EOF
sysctl --system

sed -i s/.*${HOSTNAME}.*//g /etc/hosts
cat << EOF >> /etc/hosts
${NODE_IP} ${HOSTNAME}
#192.168.56.11 worker-01
#192.168.56.12 worker-02
EOF

cat << EOF >/etc/crictl.yaml
runtime-endpoint: unix:///var/run/containerd/containerd.sock
image-endpoint: unix:///var/run/containerd/containerd.sock
timeout: 2
debug: false
pull-image-on-create: false
EOF

# Install packages
apt-get update -y
apt-get install -y apt-transport-https ca-certificates curl apache2-utils gnupg2 software-properties-common

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
apt-get update -y
apt-get install -y --allow-change-held-packages containerd kubelet=${K8S_VERSION}-00 kubeadm=${K8S_VERSION}-00 kubectl=${K8S_VERSION}-00
apt-mark hold kubelet kubeadm kubectl

# Configure containerd
mkdir /etc/containerd
containerd config default > /etc/containerd/config.toml
#containerd config default | sed 's/\(SystemdCgroup = \).*/\1true/g' > /etc/containerd/config.toml

# Fix for containerd by installing 1.6.x version
systemctl stop containerd
curl -sL ${CONTAINERD_RELEASE} -o- | tar -xz --transform 's/bin\///g' -C /usr/bin/
systemctl start containerd

systemctl enable kubelet

echo "KUBELET_EXTRA_ARGS='--node-ip=${NODE_IP} --network-plugin=cni'" > /etc/default/kubelet
