#!/bin/bash
num=$1;
for i in $(seq 1 $num)
do
    kubectl delete cluster test$i
done

