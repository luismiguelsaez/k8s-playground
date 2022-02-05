#!/usr/bin/env bash

CONTROL_NUM=1
WORKERS_NUM=2

NODES_NAME_PREFFIX="kubeadm"
NODES_CONTROL_NAME_PREFFIX="control"
NODES_WORKERS_NAME_PREFFIX="worker"

OS_VERS=20.4
K8S_VERS=1.18.9

for N in $(seq $CONTROL_NUM)
do
    echo -e "\e[37mDestroying control node ${NODES_NAME_PREFFIX}-${NODES_CONTROL_NAME_PREFFIX}-${N} ...\e[0m"
    multipass delete ${NODES_NAME_PREFFIX}-${NODES_CONTROL_NAME_PREFFIX}-${N}
done

for N in $(seq $WORKERS_NUM)
do
    echo -e "\e[37mDestroying control node ${NODES_NAME_PREFFIX}-${NODES_WORKERS_NAME_PREFFIX}-${N} ...\e[0m"
    multipass delete ${NODES_NAME_PREFFIX}-${NODES_WORKERS_NAME_PREFFIX}-${N}
done

multipass purge
