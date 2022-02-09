#!/bin/env bash

set -e

echo "Installing K8s packages [${HOSTNAME}:${NODE_IP}]: ${K8S_VERSION}"

apt-get update -y
apt-get install -y apt-transport-https ca-certificates curl

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
apt-get update -y
apt-get install -y --allow-change-held-packages containerd kubelet=${K8S_VERSION}-00 kubeadm=${K8S_VERSION}-00 kubectl=${K8S_VERSION}-00
apt-mark hold kubelet kubeadm kubectl

sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
swapoff -a

modprobe br_netfilter
echo br_netfilter >> /etc/modules-load.d/modules.conf
echo net.bridge.bridge-nf-call-ip6tables=1 >> /etc/sysctl.d/kubernetes.conf
echo net.bridge.bridge-nf-call-iptables=1  >> /etc/sysctl.d/kubernetes.conf
echo net.ipv4.ip_forward=1                 >> /etc/sysctl.d/kubernetes.conf
sysctl --system

systemctl enable kubelet

#ADDR=$(ip -o -4 address show dev enp0s8 | awk '{split($4,a,"/");print a[1]}')
echo "KUBELET_EXTRA_ARGS='--node-ip=${NODE_IP} --network-plugin=cni'" > /etc/default/kubelet

sed -i s/.*${HOSTNAME}.*//g /etc/hosts
cat << EOF >> /etc/hosts
192.168.56.4 control-01
192.168.56.11 worker-01
192.168.56.12 worker-02
EOF

cat << EOF >/etc/crictl.yaml
runtime-endpoint: unix:///var/run/containerd/containerd.sock
image-endpoint: unix:///var/run/containerd/containerd.sock
timeout: 2
debug: false
pull-image-on-create: false
EOF
