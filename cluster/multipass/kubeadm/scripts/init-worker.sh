set -e

MASTER_URL=${1:-192.168.56.4:6443}

kubeadm join ${MASTER_URL} --token ppozut.y9dh2r1bdowfay3x --discovery-token-unsafe-skip-ca-verification
