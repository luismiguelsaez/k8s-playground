#!/bin/env bash

set -e

K8S_VERSION=${1:-"1.22.13"}
HOSTNAME=${2:-"default-master"}
NODE_IP=${3:-"127.0.0.1"}
        
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

## etcdctl
#curl -sL https://github.com/etcd-io/etcd/releases/download/v3.5.2/etcd-v3.5.2-linux-amd64.tar.gz | tar --transform 's/^etcd-.*linux-amd64//' -xzvf - etcd-v3.5.2-linux-amd64/etcdctl
#mv ./etcdctl /usr/local/bin/
#chmod +x /usr/local/bin/etcdctl

## helm#
#
#curl -sL https://get.helm.sh/helm-v3.8.0-linux-amd64.tar.gz | tar --transform 's/^linux-amd64//' -xzvf - linux-amd64/helm
#mv ./helm /usr/local/bin/
#chmod +x /usr/local/bin/etcdctl

# Cilium networking plutin
#curl -sL https://get.helm.sh/helm-v3.8.0-linux-amd64.tar.gz | tar -xz linux-amd64/helm
#linux-amd64/helm repo add cilium https://helm.cilium.io/
#linux-amd64/helm install cilium cilium/cilium --version 1.11.1 --namespace kube-system --wait

# Flannel networking plugin
#kubectl apply -f https://github.com/coreos/flannel/raw/master/Documentation/kube-flannel.yml
#kubectl create -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel-rbac.yml
#kubectl wait pod --for condition=ready --all -n kube-system --timeout=300s

# Calico
su - ubuntu -c "kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml"

# Install metrics server
#curl -sL https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml | yq 'select(.kind == "Deployment")|.spec.template.spec.containers[0].args += "--kubelet-insecure-tls"'
#kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
#kubectl patch deploy -n kube-system metrics-server --type=json --patch='[{"op":"replace","path":"/spec/template/spec/containers/0/args","value":["--cert-dir=/tmp","--secure-port=4443","--kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname","--kubelet-use-node-status-port","--metric-resolution=15s","--kubelet-insecure-tls"]}]'

# Install Nginx ingress controller

#helm repo add nginx-ingress https://helm.nginx.com/stable
#helm install nginx-ingress nginx-ingress/nginx-ingress --version 0.12.1 --create-namespace -n nginx

# Install ArgoCD

#export ARGO_PASS="admin"
#ARGO_PASS_ENC="$(htpasswd -nbBC 10 "" ${ARGO_PASS} | tr -d ':\n' | sed 's/$2y/$2a/')"
#export ARGO_PASS_ENC=$(echo ${ARGO_PASS_ENC} | sed 's/\$/\\$/g')

#cat << EOF > /home/ubuntu/install-argocd.sh
#helm repo add argo https://argoproj.github.io/argo-helm
#kubectl create ns argocd
#helm install argocd argo/argo-cd -n argocd --create-namespace --set-string configs.secret.argocdServerAdminPassword="${ARGO_PASS_ENC}"
##helm install argocd argo/argo-cd -n argocd --create-namespace --set-string configs.secret.argocdServerAdminPassword="${ARGO_PASS_ENC}" --values values-override.yaml
#EOF

#chmod +x /home/ubuntu/install-argocd.sh
#su - ubuntu -c /home/ubuntu/install-argocd.sh
#su - ubuntu -c "kubectl expose svc argocd-server --type=NodePort --target-port 8080 --name argocd-server-np -n argocd"

