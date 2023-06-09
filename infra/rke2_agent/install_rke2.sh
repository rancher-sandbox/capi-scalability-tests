#!/usr/bin/env bash

set -xe

# HACK: work around https://github.com/k3s-io/k3s/issues/2306
sleep ${sleep_time}

# https://docs.rke2.io/known_issues/#networkmanager
# cat >/etc/NetworkManager/conf.d/rke2-canal.conf <<EOF
# [keyfile]
# unmanaged-devices=interface-name:cali*;interface-name:flannel*
# EOF
# systemctl reload NetworkManager

# https://docs.rke2.io/known_issues/#wicked
cat >/etc/sysctl.d/90-rke2.conf <<EOF
net.ipv4.conf.all.forwarding=1
net.ipv6.conf.all.forwarding=1
EOF

# pre-shared secrets
mkdir -p /var/lib/rancher/rke2/server/tls/
cat >/var/lib/rancher/rke2/server/tls/client-ca.key <<EOF
${client_ca_key}
EOF
cat >/var/lib/rancher/rke2/server/tls/client-ca.crt <<EOF
${client_ca_cert}
EOF
cat >/var/lib/rancher/rke2/server/tls/server-ca.key <<EOF
${server_ca_key}
EOF
cat >/var/lib/rancher/rke2/server/tls/server-ca.crt <<EOF
${server_ca_cert}
EOF
cat >/var/lib/rancher/rke2/server/tls/request-header-ca.key <<EOF
${request_header_ca_key}
EOF
cat >/var/lib/rancher/rke2/server/tls/request-header-ca.crt <<EOF
${request_header_ca_cert}
EOF

mkdir -p /etc/rancher/rke2/
cat >/etc/rancher/rke2/config.yaml <<EOF
server: ${jsonencode(server_url)}
token: ${jsonencode(token)}
tls-san:
%{ for san in sans ~}
  - ${jsonencode(san)}
%{ endfor ~}
kubelet-arg: "config=/etc/rancher/rke2/kubelet-custom.config"
kube-controller-manager-arg: "node-cidr-mask-size=${node_cidr_mask_size}"
%{ if length(node_labels) > 0 ~}
node-label:
%{ for label in node_labels ~}
  - ${jsonencode(label)}
%{ endfor ~}
%{endif ~}
%{ if length(node_taints) > 0 ~}
node-taint:
%{ for taint in node_taints ~}
  - ${jsonencode(taint)}
%{ endfor ~}
%{endif ~}
EOF

cat > /etc/rancher/rke2/kubelet-custom.config <<EOF
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
maxPods: ${max_pods}
EOF

cat >>/root/.bash_profile <<EOF
export PATH=\$PATH:/var/lib/rancher/rke2/bin/
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
EOF

cat >>/root/.bashrc <<EOF
export PATH=\$PATH:/var/lib/rancher/rke2/bin/
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
EOF

# installation
export INSTALL_RKE2_VERSION=${rke2_version}
export INSTALL_RKE2_TYPE=agent

curl -sfL https://get.rke2.io | sh -
systemctl enable rke2-agent.service
systemctl restart rke2-agent.service