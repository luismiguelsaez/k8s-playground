set -e

K8S_VERSION=${1:-1.18.9}

IP=$(ip -o -4 addr show dev ens3 | awk '{split($4,a,"/");print a[1]}')
sudo sed -i s/.*$HOSTNAME.*//g /etc/hosts
echo "$IP $HOSTNAME" | sudo tee -a /etc/hosts

sudo kubeadm config images pull
sudo kubeadm init --kubernetes-version ${K8S_VERSION} --token ppozut.y9dh2r1bdowfay3x --pod-network-cidr=192.168.0.0/16

# Setup shell
mkdir ~/.kube
sudo cp /etc/kubernetes/admin.conf ~/.kube/config
sudo chown -R $(id -u).$(id -u) ~/.kube

cat << EOF >> ~/.bashrc
# kubectl command setup
alias k="kubectl"
source <(kubectl completion bash)
complete -F __start_kubectl k
EOF

# Flannel networking plugin
#kubectl apply -f https://github.com/coreos/flannel/raw/master/Documentation/kube-flannel.yml
#kubectl wait pod --for condition=ready --all -n kube-system --timeout=300s

# Calico CNI ( https://projectcalico.docs.tigera.io/getting-started/kubernetes/quickstart )
kubectl create -f https://docs.projectcalico.org/manifests/calico-typha.yaml -o calico.yaml

# Install tools
#sudo curl -sL https://github.com/mikefarah/yq/releases/download/v4.18.1/yq_linux_amd64 -o /usr/local/bin/yq
#sudo chmod +x /usr/local/bin/*

# Install metrics server
#curl -sL https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml | yq 'select(.kind == "Deployment")|.spec.template.spec.containers[0].args += "--kubelet-insecure-tls"'
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl patch deploy -n kube-system metrics-server --type=json --patch='[{"op":"replace","path":"/spec/template/spec/containers/0/args","value":["--cert-dir=/tmp","--secure-port=4443","--kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname","--kubelet-use-node-status-port","--metric-resolution=15s","--kubelet-insecure-tls"]}]'
