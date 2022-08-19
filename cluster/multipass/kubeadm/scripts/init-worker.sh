#!/bin/env bash

set -e

echo "Initializing worker node [${HOSTNAME}:${NODE_IP}]: ${K8S_VERSION}"

kubeadm join ${MASTER_IP}:6443 --token ppozut.y9dh2r1bdowfay3x --discovery-token-unsafe-skip-ca-verification
