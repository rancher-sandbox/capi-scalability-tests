#!/usr/bin/env bash

set -xe

# This creates the kind network for the docker provider to use


docker network create \
    --driver=bridge \
    --subnet=172.19.0.0/16 \
    --gateway=172.19.0.1 \
    --opt "com.docker.network.bridge.enable_ip_masquerade"="true" \
    --opt "com.docker.network.driver.mtu"="1500" \
    kind