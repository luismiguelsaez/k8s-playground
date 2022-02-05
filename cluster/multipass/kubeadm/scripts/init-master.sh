set -e

K8S_VERSION=${1:-1.18.9}

sudo kubeadm config images pull
sudo kubeadm init --kubernetes-version ${K8S_VERSION} --token ppozut.y9dh2r1bdowfay3x --pod-network-cidr=10.244.0.0/16 --service-cidr=10.96.0.0/16 --apiserver-advertise-address 192.168.56.4

mkdir ~/.kube
sudo cp /etc/kubernetes/admin.conf ~/.kube/config
sudo chown -R $(id -u).$(id -u) ~/.kube

# Flannel networking plugin
kubectl apply -f https://github.com/coreos/flannel/raw/master/Documentation/kube-flannel.yml
kubectl wait pod --for condition=ready --all -n kube-system --timeout=300s
