#!/usr/bin/env bash


CONTROL_NUM=${CONTROL_NUM:-1}
WORKERS_NUM=${WORKERS_NUM:-2}

OS_VERS=${OS_VERS:-20.04}
K8S_VERS=${K8S_VERS:-1.19.16}

NODES_NAME_PREFFIX="kubeadm"
NODES_CONTROL_NAME_PREFFIX="control"
NODES_WORKERS_NAME_PREFFIX="worker"


for N in $(seq $CONTROL_NUM)
do
    NODE_STATUS=$( multipass list | grep ${NODES_NAME_PREFFIX}-${NODES_CONTROL_NAME_PREFFIX}-${N} )

    if [ -z "$NODE_STATUS" ]
    then
        echo -ne "\e[37mCreating control node \e[34m${NODES_NAME_PREFFIX}-${NODES_CONTROL_NAME_PREFFIX}-${N}\e[0m ... \e[0m"
        LAUNCH_OUT=$( multipass launch ${OS_VERS} -n ${NODES_NAME_PREFFIX}-${NODES_CONTROL_NAME_PREFFIX}-${N} -c 2 -m 2048M  -d 20G --cloud-init cloud-config.yaml 2>&1 )
        if [ $? -eq 0 ]
        then
            echo -e "\e[32mOK\e[0m"
        else
            echo -e "\e[31mERROR\e[0m"
            echo "${LAUNCH_OUT}"
        fi

        echo -ne "\e[37mMounting scripts in control node ${NODES_NAME_PREFFIX}-${NODES_WORKERS_NAME_PREFFIX}-${N} ... \e[0m"
        MOUNT_OUT=$( 
            multipass mount scripts ${NODES_NAME_PREFFIX}-${NODES_CONTROL_NAME_PREFFIX}-${N}:/scripts 2>&1
            multipass mount manifests ${NODES_NAME_PREFFIX}-${NODES_CONTROL_NAME_PREFFIX}-${N}:/manifests 2>&1 
        )
        if [ $? -eq 0 ]
        then
            echo -e "\e[32mOK\e[0m"
        else
            echo -e "\e[31mERROR\e[0m"
            echo "${MOUNT_OUT}"
        fi

        echo -ne "\e[37mProvisioning control node ${NODES_NAME_PREFFIX}-${NODES_CONTROL_NAME_PREFFIX}-${N} ... \e[0m"
        PROVISION_OUT=$( multipass exec ${NODES_NAME_PREFFIX}-${NODES_CONTROL_NAME_PREFFIX}-${N} -- bash /scripts/init-master.sh ${K8S_VERS} 2>&1 )
        if [ $? -eq 0 ]
        then
            echo -e "\e[32mOK\e[0m"
        else
            echo -e "\e[31mERROR\e[0m"
            echo "${PROVISION_OUT}" | bat -l bash
        fi
    else
        if [ "$( echo $NODE_STATUS | awk '{print $2;}' )" == "Stopped" ]
        then
            echo -e "\e[32mNode ${NODES_NAME_PREFFIX}-${NODES_CONTROL_NAME_PREFFIX}-${N} already exists. Starting ... \e[32m"
            multipass start ${NODES_NAME_PREFFIX}-${NODES_CONTROL_NAME_PREFFIX}-${N} >/dev/null 2>&1
        else
            echo -e "\e[32mNode ${NODES_NAME_PREFFIX}-${NODES_CONTROL_NAME_PREFFIX}-${N} already exists\e[0m"
        fi
    fi
done

MASTER_IP=$(multipass info ${NODES_NAME_PREFFIX}-${NODES_CONTROL_NAME_PREFFIX}-1 | awk '/^IPv4/{print $2}')

for N in $(seq $WORKERS_NUM)
do
    NODE_STATUS=$( multipass list | grep ${NODES_NAME_PREFFIX}-${NODES_WORKERS_NAME_PREFFIX}-${N} )

    if [ -z "$NODE_STATUS" ]
    then
        echo -ne "\e[37mCreating worker node \e[35m${NODES_NAME_PREFFIX}-${NODES_WORKERS_NAME_PREFFIX}-${N}\e[0m ... \e[0m"
        LAUNCH_OUT=$( multipass launch ${OS_VERS} -n ${NODES_NAME_PREFFIX}-${NODES_WORKERS_NAME_PREFFIX}-${N} -c 1 -m 1024M  -d 20G --cloud-init cloud-config.yaml 2>&1 )
        if [ $? -eq 0 ]
        then
            echo -e "\e[32mOK\e[0m"
        else
            echo -e "\e[31mERROR\e[0m"
            echo "${LAUNCH_OUT}"
        fi

        echo -ne "\e[37mMounting scripts in worker node ${NODES_NAME_PREFFIX}-${NODES_WORKERS_NAME_PREFFIX}-${N} ... \e[0m"
        MOUNT_OUT=$( multipass mount scripts ${NODES_NAME_PREFFIX}-${NODES_WORKERS_NAME_PREFFIX}-${N}:/scripts 2>&1 )
        if [ $? -eq 0 ]
        then
            echo -e "\e[32mOK\e[0m"
        else
            echo -e "\e[31mERROR\e[0m"
            echo "${MOUNT_OUT}"
        fi

        echo -ne "\e[37mProvisioning worker node ${NODES_NAME_PREFFIX}-${NODES_WORKERS_NAME_PREFFIX}-${N} ... \e[0m"
        PROVISION_OUT=$(multipass exec ${NODES_NAME_PREFFIX}-${NODES_WORKERS_NAME_PREFFIX}-${N} -- bash /scripts/init-worker.sh ${MASTER_IP}:6443 2>&1)
        if [ $? -eq 0 ]
        then
            echo -e "\e[32mOK\e[0m"
        else
            echo -e "\e[31mERROR\e[0m"
            echo "${PROVISION_OUT}" | bat -l bash
        fi
    else
        if [ "$( echo $NODE_STATUS | awk '{print $2;}' )" == "Stopped" ]
        then
            echo -e "\e[32mNode ${NODES_NAME_PREFFIX}-${NODES_WORKERS_NAME_PREFFIX}-${N} already exists. Starting ... \e[32m"
            multipass start ${NODES_NAME_PREFFIX}-${NODES_WORKERS_NAME_PREFFIX}-${N} >/dev/null 2>&1
        else
            echo -e "\e[32mNode ${NODES_NAME_PREFFIX}-${NODES_WORKERS_NAME_PREFFIX}-${N} already exists\e[0m"
        fi
    fi
done

multipass exec ${NODES_NAME_PREFFIX}-${NODES_CONTROL_NAME_PREFFIX}-1 -- sudo cat /etc/kubernetes/admin.conf > ~/.kube/kubeadm-cluster.conf
