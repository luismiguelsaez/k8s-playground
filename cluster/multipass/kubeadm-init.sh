set -e

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

cat << EOF > /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-ip6tables=1
net.bridge.bridge-nf-call-iptables=1
net.ipv4.ip_forward=1
EOF

sysctl --system

systemctl enable kubelet

#ADDR=$(ip -o -4 address show dev enp0s8 | awk '{split($4,a,"/");print a[1]}')
#echo "KUBELET_EXTRA_ARGS='--node-ip=${ADDR} --network-plugin=cni'" > /etc/default/kubelet
