#!/usr/bin/env bash


CONTROL_NUM=1
WORKERS_NUM=2

NODES_NAME_PREFFIX="kubeadm"
NODES_CONTROL_NAME_PREFFIX="control"
NODES_WORKERS_NAME_PREFFIX="worker"

OS_VERS=20.04
K8S_VERS=1.18.9

for N in $(seq $CONTROL_NUM)
do
    NODE_STATUS=$( multipass list | grep ${NODES_NAME_PREFFIX}-${NODES_CONTROL_NAME_PREFFIX}-${N} )

    if [ -z "$NODE_STATUS" ]
    then
        echo -ne "\e[37mCreating control node ${NODES_NAME_PREFFIX}-${NODES_CONTROL_NAME_PREFFIX}-${N} ... \e[0m"
        multipass launch ${OS_VERS} -n ${NODES_NAME_PREFFIX}-${NODES_CONTROL_NAME_PREFFIX}-${N} -c 2 -m 2048M  -d 20G --cloud-init cloud-config.yaml #>/dev/null 2>&1
        if [ $? -eq 0 ]
        then
            echo -e "\e[32mOK\e[0m"
        else
            echo -e "\e[31mERROR\e[0m"
        fi

        multipass mount scripts ${NODES_NAME_PREFFIX}-${NODES_CONTROL_NAME_PREFFIX}-${N}:/scripts

        echo -e "\e[37mProvisioning control node ${NODES_NAME_PREFFIX}-${NODES_CONTROL_NAME_PREFFIX}-${N} ...\e[0m"
        multipass exec ${NODES_NAME_PREFFIX}-${NODES_CONTROL_NAME_PREFFIX}-${N} bash /scripts/init-master.sh ${K8S_VERS}
    else
        if [ "$( echo $NODE_STATUS | awk '{print $2;}' )" == "Stopped" ]
        then
            echo -e "\e[32mNode ${NODES_NAME_PREFFIX}-${NODES_CONTROL_NAME_PREFFIX}-${N} already exists. Starting ...\e[32m"
            multipass start ${NODES_NAME_PREFFIX}-${NODES_CONTROL_NAME_PREFFIX}-${N} >/dev/null 2>&1
        else
            echo -e "\e[32mNode ${NODES_NAME_PREFFIX}-${NODES_CONTROL_NAME_PREFFIX}-${N} already exists\e[0m"
        fi
    fi
done

MASTER_IP=$(multipass info ${NODES_NAME_PREFFIX}-${NODES_CONTROL_NAME_PREFFIX}-${N} | awk '/^IPv4/{print $2}')

for N in $(seq $WORKERS_NUM)
do
    NODE_STATUS=$( multipass list | grep ${NODES_NAME_PREFFIX}-${NODES_WORKERS_NAME_PREFFIX}-${N} )

    if [ -z "$NODE_STATUS" ]
    then
        echo -ne "\e[37mCreating control node ${NODES_NAME_PREFFIX}-${NODES_WORKERS_NAME_PREFFIX}-${N} ... \e[0m"
        multipass launch ${OS_VERS} -n ${NODES_NAME_PREFFIX}-${NODES_WORKERS_NAME_PREFFIX}-${N} -c 1 -m 1024M  -d 20G --cloud-init cloud-config.yaml >/dev/null 2>&1
        if [ $? -eq 0 ]
        then
            echo -e "\e[32mOK\e[0m"
        else
            echo -e "\e[31mERROR\e[0m"
        fi

        multipass mount scripts ${NODES_NAME_PREFFIX}-${NODES_WORKERS_NAME_PREFFIX}-${N}:/scripts

        echo -e "\e[37mProvisioning worker node ${NODES_NAME_PREFFIX}-${NODES_CONTROL_NAME_PREFFIX}-${N} ...\e[0m"
        multipass exec ${NODES_NAME_PREFFIX}-${NODES_WORKERS_NAME_PREFFIX}-${N} bash /scripts/init-worker.sh ${MASTER_IP}
    else
        if [ "$( echo $NODE_STATUS | awk '{print $2;}' )" == "Stopped" ]
        then
            echo -e "\e[32mNode ${NODES_NAME_PREFFIX}-${NODES_WORKERS_NAME_PREFFIX}-${N} already exists. Starting ...\e[32m"
            multipass start ${NODES_NAME_PREFFIX}-${NODES_WORKERS_NAME_PREFFIX}-${N} >/dev/null 2>&1
        else
            echo -e "\e[32mNode ${NODES_NAME_PREFFIX}-${NODES_WORKERS_NAME_PREFFIX}-${N} already exists\e[0m"
        fi
    fi
done

multipass exec ${NODES_NAME_PREFFIX}-${NODES_CONTROL_NAME_PREFFIX}-${N} -- sudo cat /etc/kubernetes/admin.conf > ~/.kube/kubeadm-cluster.conf
