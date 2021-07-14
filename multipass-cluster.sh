#!/bin/bash

multipass launch --cpus 1 -d 10G -m 1024M --cloud-init multipass-cluster.yml
