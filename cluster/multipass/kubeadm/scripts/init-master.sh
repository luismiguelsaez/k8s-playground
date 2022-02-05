set -e

K8S_VERSION=${1:-1.18.9}

IP=$(ip -o -4 addr show dev ens3 | awk '{split($4,a,"/");print a[1]}')
sudo sed -i s/.*$HOSTNAME.*//g /etc/hosts
echo "$IP $HOSTNAME" | sudo tee -a /etc/hosts

sudo kubeadm config images pull
sudo kubeadm init --kubernetes-version ${K8S_VERSION} --token ppozut.y9dh2r1bdowfay3x --pod-network-cidr=10.244.0.0/16

mkdir ~/.kube
sudo cp /etc/kubernetes/admin.conf ~/.kube/config
sudo chown -R $(id -u).$(id -u) ~/.kube

# Flannel networking plugin
kubectl apply -f https://github.com/coreos/flannel/raw/master/Documentation/kube-flannel.yml
kubectl wait pod --for condition=ready --all -n kube-system --timeout=300s
