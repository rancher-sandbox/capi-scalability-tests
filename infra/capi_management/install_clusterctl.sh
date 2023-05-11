#!/usr/bin/env bash

set -xe

curl -sfL -o /root/clusterctl https://github.com/kubernetes-sigs/cluster-api/releases/download/v1.4.2/clusterctl-linux-amd64
chmod +x /root/clusterctl