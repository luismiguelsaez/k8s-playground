#!/usr/bin/env bash

CONTROL_NUM=1
WORKERS_NUM=2
NODES_NAME_PREFFIX="k3s-kubeadm"

for N in $(seq $CONTROL_NUM)
do
    NODE_STATUS=$( multipass list | grep ${NODES_NAME_PREFFIX}-${N} )

    if [ -z "$NODE_STATUS" ]
    then
        echo -e "\e[32mCreating node ${NODES_NAME_PREFFIX}-${N} ...\e[0m"
        multipass launch -n ${NODES_NAME_PREFFIX}-${N} -c 2 -m 2048M >/dev/null 2>&1
    else
        if [ "$( echo $NODE_STATUS | awk '{print $2;}' )" == "Stopped" ]
        then
            echo -e "\e[32mNode ${NODES_NAME_PREFFIX}-${N} already exists. Starting ...\e[32m"
            multipass start ${NODES_NAME_PREFFIX}-${N} >/dev/null 2>&1
        else
            echo -e "\e[32mNode ${NODES_NAME_PREFFIX}-${N} already exists\e[0m"
        fi
    fi
done

multipass launch 20.04 -n kubeadm-control-01 -c 2 -m 2048M -d 20G --cloud-init cloud-config.yaml
multipass mount scripts kubeadm-control-01:/scripts
multipass exec kubeadm-control-01 bash /scripts/init-master.sh 1.18.9

multipass mount scripts kubeadm-worker-01:/scripts
multipass exec kubeadm-worker-01 bash /scripts/init-worker.sh 1.18.9
