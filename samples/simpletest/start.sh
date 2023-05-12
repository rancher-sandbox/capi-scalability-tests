#!/bin/bash
num=$1;
prefix=$2
host=$3
for i in $(seq 1 $num)
do
    cat capd-host.yaml |  PREFIX=$prefix HOST=$host CLUSTER_NUM=$i WORKER_MACHINE_COUNT=1 CONTROL_PLANE_MACHINE_COUNT=1 envsubst | kubectl apply -f -
done

