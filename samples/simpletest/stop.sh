#!/bin/bash
num=$1;
prefix=$2
for i in $(seq 1 $num)
do
    kubectl delete cluster test-$prefix-$i
done

