#!/usr/bin/env bash

set -xe

curl -fL --output /root/node_exporter-1.5.0.linux-amd64.tar.gz https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz
tar -xvf node_exporter-1.5.0.linux-amd64.tar.gz node_exporter-1.5.0.linux-amd64/node_exporter
mv node_exporter-1.5.0.linux-amd64/node_exporter /root/node_exporter
rm -rf root/node_exporter-1.5.0.linux-amd64

cat >/etc/systemd/system/node_exporter.service <<EOF
[Unit]
Description=Node Exporter
Requires=node_exporter.socket

[Service]
User=root
EnvironmentFile=/etc/sysconfig/node_exporter
ExecStart=/root/node_exporter --web.systemd-socket $OPTIONS

[Install]
WantedBy=multi-user.target
EOF

cat >/etc/systemd/system/node_exporter.socket <<EOF
[Unit]
Description=Node Exporter

[Socket]
ListenStream=9100

[Install]
WantedBy=sockets.target
EOF

mkdir -p /etc/sysconfig
cat >/etc/sysconfig/node_exporter <<EOF
OPTIONS="--collector.textfile.directory /var/lib/node_exporter/textfile_collector"
EOF

systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter