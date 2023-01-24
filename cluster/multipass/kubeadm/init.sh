#!/usr/bin/env bash

CONTROL_NUM=${CONTROL_NUM:-1}
WORKERS_NUM=${WORKERS_NUM:-2}

OS_VERS="20.04" # multipass find
K8S_VERS="1.24.10" # https://kubernetes.io/releases/ - try 1.24.10

# Tested versions
#
# Ubuntu 20.04.5 - k8s 1.23.16 - containerd v1.6.15 - works for new provision
# Ubuntu 20.04.5 - k8s 1.24.10 - containerd v1.6.15 - works after upgrading master from 1.23.16
# Ubuntu 20.04.5 - k8s 1.24.10 - containerd v1.6.15 - works for new provision


NODES_NAME_PREFFIX="kubeadm"
NODES_CONTROL_NAME_PREFFIX="control"
NODES_WORKERS_NAME_PREFFIX="worker"

NODES_CONTROL_CPUS=2
NODES_CONTROL_MEMORY=2048M
NODES_CONTROL_DISK=20G

NODES_WORKER_CPUS=1
NODES_WORKER_MEMORY=1024M
NODES_WORKER_DISK=20G

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NOCOLOR='\033[0m'

for N in $(seq $CONTROL_NUM)
do
    NODE_STATUS=$( multipass list | grep ${NODES_NAME_PREFFIX}-${NODES_CONTROL_NAME_PREFFIX}-${N} )

    if [ -z "$NODE_STATUS" ]
    then
        echo -ne "Creating control node ${BLUE}${NODES_NAME_PREFFIX}-${NODES_CONTROL_NAME_PREFFIX}-${N}${NOCOLOR} ...  "
        #LAUNCH_OUT=$( multipass launch ${OS_VERS} -n ${NODES_NAME_PREFFIX}-${NODES_CONTROL_NAME_PREFFIX}-${N} -c ${NODES_CONTROL_CPUS} -m ${NODES_CONTROL_MEMORY} -d ${NODES_CONTROL_DISK} --cloud-init cloud-config.yaml 2>&1 )
        LAUNCH_OUT=$( multipass launch ${OS_VERS} -n ${NODES_NAME_PREFFIX}-${NODES_CONTROL_NAME_PREFFIX}-${N} -c ${NODES_CONTROL_CPUS} -m ${NODES_CONTROL_MEMORY} -d ${NODES_CONTROL_DISK} 2>&1 )
        if [ $? -eq 0 ]
        then
            echo -e "${GREEN}OK${NOCOLOR}"
        else
            echo -e "${RED}ERROR${NOCOLOR}"
            echo "${LAUNCH_OUT}"
        fi

        echo -ne "Mounting scripts in control node ${BLUE}${NODES_NAME_PREFFIX}-${NODES_CONTROL_NAME_PREFFIX}-${N}${NOCOLOR} ... "
        MOUNT_OUT=$( 
            multipass mount scripts ${NODES_NAME_PREFFIX}-${NODES_CONTROL_NAME_PREFFIX}-${N}:/scripts 2>&1
        )
        if [ $? -eq 0 ]
        then
            echo -e "${GREEN}OK${NOCOLOR}"
        else
            echo -e "${RED}ERROR${NOCOLOR}"
            echo "${MOUNT_OUT}"
        fi

        MASTER_IP=$(multipass info ${NODES_NAME_PREFFIX}-${NODES_CONTROL_NAME_PREFFIX}-${N} | awk '/^IPv4/{print $2}')

        echo -ne "Provisioning control node ${BLUE}${NODES_NAME_PREFFIX}-${NODES_CONTROL_NAME_PREFFIX}-${N}${NOCOLOR} (1/2) ... "

        COMMON_OUT=$( multipass exec ${NODES_NAME_PREFFIX}-${NODES_CONTROL_NAME_PREFFIX}-${N} -- sudo bash /scripts/common.sh ${K8S_VERS} "${NODES_NAME_PREFFIX}-${NODES_CONTROL_NAME_PREFFIX}-${N}" ${MASTER_IP} 2>&1 )
        if [ $? -eq 0 ]
        then
            echo -e "${GREEN}OK${NOCOLOR}"
        else
            echo -e "${RED}ERROR${NOCOLOR}"
            echo "${COMMON_OUT}" | bat -l bash
        fi

        echo -ne "Provisioning control node ${BLUE}${NODES_NAME_PREFFIX}-${NODES_CONTROL_NAME_PREFFIX}-${N}${NOCOLOR} (2/2) ... "
        
        PROVISION_OUT=$( multipass exec ${NODES_NAME_PREFFIX}-${NODES_CONTROL_NAME_PREFFIX}-${N} -- sudo bash /scripts/init-master.sh ${K8S_VERS} "${NODES_NAME_PREFFIX}-${NODES_CONTROL_NAME_PREFFIX}-${N}" ${MASTER_IP} 2>&1 )
        if [ $? -eq 0 ]
        then
            echo -e "${GREEN}OK${NOCOLOR}"
        else
            echo -e "${RED}ERROR${NOCOLOR}"
            echo "${PROVISION_OUT}" | bat -l bash
        fi
    else
        if [ "$( echo $NODE_STATUS | awk '{print $2;}' )" == "Stopped" ]
        then
            echo -e "Node ${BLUE}${NODES_NAME_PREFFIX}-${NODES_CONTROL_NAME_PREFFIX}-${N}${NOCOLOR} already exists. Starting ... "
            multipass start ${NODES_NAME_PREFFIX}-${NODES_CONTROL_NAME_PREFFIX}-${N} >/dev/null 2>&1
        else
            echo -e "Node ${BLUE}${NODES_NAME_PREFFIX}-${NODES_CONTROL_NAME_PREFFIX}-${N}${NOCOLOR} already exists"
        fi
    fi
done

MASTER_IP=$(multipass info ${NODES_NAME_PREFFIX}-${NODES_CONTROL_NAME_PREFFIX}-1 | awk '/^IPv4/{print $2}')

if [ $WORKERS_NUM -gt 0 ]
then
    for N in $(seq $WORKERS_NUM)
    do
        NODE_STATUS=$( multipass list | grep ${NODES_NAME_PREFFIX}-${NODES_WORKERS_NAME_PREFFIX}-${N} )

        if [ -z "$NODE_STATUS" ]
        then
            echo -ne "Creating worker node ${BLUE}${NODES_NAME_PREFFIX}-${NODES_WORKERS_NAME_PREFFIX}-${N}${NOCOLOR} ... "
            #LAUNCH_OUT=$( multipass launch ${OS_VERS} -n ${NODES_NAME_PREFFIX}-${NODES_WORKERS_NAME_PREFFIX}-${N} -c ${NODES_WORKER_CPUS} -m ${NODES_WORKER_MEMORY} -d ${NODES_WORKER_DISK} --cloud-init cloud-config.yaml 2>&1 )
            LAUNCH_OUT=$( multipass launch ${OS_VERS} -n ${NODES_NAME_PREFFIX}-${NODES_WORKERS_NAME_PREFFIX}-${N} -c ${NODES_WORKER_CPUS} -m ${NODES_WORKER_MEMORY} -d ${NODES_WORKER_DISK} 2>&1 )
            if [ $? -eq 0 ]
            then
                echo -e "${GREEN}OK${NOCOLOR}"
            else
                echo -e "${RED}ERROR${NOCOLOR}"
                echo "${LAUNCH_OUT}"
            fi

            echo -ne "Mounting scripts in worker node ${BLUE}${NODES_NAME_PREFFIX}-${NODES_WORKERS_NAME_PREFFIX}-${N}${NOCOLOR} ... "
            MOUNT_OUT=$( multipass mount scripts ${NODES_NAME_PREFFIX}-${NODES_WORKERS_NAME_PREFFIX}-${N}:/scripts 2>&1 )
            if [ $? -eq 0 ]
            then
                echo -e "${GREEN}OK${NOCOLOR}"
            else
                echo -e "${RED}ERROR${NOCOLOR}"
                echo "${MOUNT_OUT}"
            fi

            WORKER_IP=$(multipass info ${NODES_NAME_PREFFIX}-${NODES_WORKERS_NAME_PREFFIX}-${N} | awk '/^IPv4/{print $2}')

            echo -ne "Provisioning worker node ${BLUE}${NODES_NAME_PREFFIX}-${NODES_WORKERS_NAME_PREFFIX}-${N}${NOCOLOR} (1/2) ... "

            COMMON_OUT=$( multipass exec ${NODES_NAME_PREFFIX}-${NODES_WORKERS_NAME_PREFFIX}-${N} -- sudo bash /scripts/common.sh ${K8S_VERS} "${NODES_NAME_PREFFIX}-${NODES_CONTROL_NAME_PREFFIX}-${N}" ${WORKER_IP} 2>&1 )
            if [ $? -eq 0 ]
            then
                echo -e "${GREEN}OK${NOCOLOR}"
            else
                echo -e "${RED}ERROR${NOCOLOR}"
                echo "${COMMON_OUT}" | bat -l bash
            fi

            echo -ne "Provisioning worker node ${BLUE}${NODES_NAME_PREFFIX}-${NODES_WORKERS_NAME_PREFFIX}-${N}${NOCOLOR} (2/2) ... "

            PROVISION_OUT=$(multipass exec ${NODES_NAME_PREFFIX}-${NODES_WORKERS_NAME_PREFFIX}-${N} -- sudo bash /scripts/init-worker.sh ${K8S_VERS} "${NODES_NAME_PREFFIX}-${NODES_WORKERS_NAME_PREFFIX}-${N}" ${MASTER_IP} ${WORKER_IP} 2>&1)
            if [ $? -eq 0 ]
            then
                echo -e "${GREEN}OK${NOCOLOR}"
            else
                echo -e "${RED}ERROR${NOCOLOR}"
                echo "${PROVISION_OUT}" | bat -l bash
            fi
        else
            if [ "$( echo $NODE_STATUS | awk '{print $2;}' )" == "Stopped" ]
            then
                echo -e "Node ${BLUE}${NODES_NAME_PREFFIX}-${NODES_WORKERS_NAME_PREFFIX}-${N}${NOCOLOR} already exists. Starting ... "
                multipass start ${NODES_NAME_PREFFIX}-${NODES_WORKERS_NAME_PREFFIX}-${N} >/dev/null 2>&1
            else
                echo -e "Node ${BLUE}${NODES_NAME_PREFFIX}-${NODES_WORKERS_NAME_PREFFIX}-${N}${NOCOLOR} already exists"
            fi
        fi
    done
fi

multipass exec ${NODES_NAME_PREFFIX}-${NODES_CONTROL_NAME_PREFFIX}-1 -- sudo cat /etc/kubernetes/admin.conf > ~/.kube/kubeadm-cluster.conf
