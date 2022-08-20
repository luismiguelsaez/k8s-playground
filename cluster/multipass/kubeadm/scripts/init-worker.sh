#!/bin/env bash

set -e

K8S_VERSION=${1:-"1.22.13"}
HOSTNAME=${2:-"default-master"}
MASTER_IP=${3:-"127.0.0.1"}
WORKER_IP=${4:-"127.0.0.1"}

echo "Initializing worker node [${HOSTNAME}:${WORKER_IP}]: ${K8S_VERSION}"

kubeadm join ${MASTER_IP}:6443 --token ppozut.y9dh2r1bdowfay3x --discovery-token-unsafe-skip-ca-verification
