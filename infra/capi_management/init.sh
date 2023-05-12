#!/usr/bin/env bash

set -xe

export EXP_MACHINE_POOL=true
export EXP_CLUSTER_RESOURCE_SET=true
export CLUSTER_TOPOLOGY=true

/root/clusterctl init --kubeconfig /etc/rancher/rke2/rke2.yaml --config /root/clusterctl.yaml --infrastructure docker-rich:${docker_provider_version}