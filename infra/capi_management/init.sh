#!/usr/bin/env bash

set -xe

export EXP_MACHINE_POOL=true
export EXP_CLUSTER_RESOURCE_SET=true
export CLUSTER_TOPOLOGY=true

export CABPK_CONFIG_CONCURRENCY=${capi_concurrency}
export CAPI_CLUSTER_CONCURRENCY=${capi_concurrency}
export CAPI_MACHINE_CONCURRENCY=${capi_concurrency}
export CAPI_MACHINESET_CONCURRENCY=${capi_concurrency}
export CAPI_MACHINEDEPLOYMENT_CONCURRENCY=${capi_concurrency}
export CAPI_MACHINEHC_CONCURRENCY=${capi_concurrency}
export KCP_CONFIG_CONCURRENCY=${capi_concurrency}
export CAPD_CONCURRENCY=${capi_concurrency}

export CABPK_API_QPS=${capi_kube_api_qps}
export CAPI_API_QPS=${capi_kube_api_qps}
export KCP_API_QPS=${capi_kube_api_qps}
export CAPD_API_QPS=${capi_kube_api_qps}

export CABPK_API_BURST=${capi_kube_api_burst}
export CAPI_API_BURST=${capi_kube_api_burst}
export KCP_API_BURST=${capi_kube_api_burst}
export CAPD_API_BURST=${capi_kube_api_burst}



/root/clusterctl init --kubeconfig /etc/rancher/rke2/rke2.yaml --config /root/clusterctl.yaml --infrastructure ${capi_infra_providers}