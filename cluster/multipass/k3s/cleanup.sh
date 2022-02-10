#!/usr/bin/env bash

NODES_NUM=3
NODES_NAME_PREFFIX="k3s-node"

for N in $(seq $NODES_NUM)
do
  multipass delete ${NODES_NAME_PREFFIX}-${N}
done

multipass purge
