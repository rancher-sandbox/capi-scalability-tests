#!/usr/bin/env bash

set -xe


/root/clusterctl init --kubeconfig /etc/rancher/rke2/rke2.yaml --config /root/clusterctl.yaml --infrastructure docker-rich:${docker_provider_version}