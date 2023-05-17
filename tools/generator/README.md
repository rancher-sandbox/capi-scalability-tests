# Cluster generator

Generate clusters using a number of docker hosts as backing.

Its designed to use the host ip text file that is generated as output from the infra:

```shell
python3 generator.py \
    -d ../../infra/config/docker-host-ips.txt \
    -t template.yaml \
    -n 30 \
    -s 5 \
    -k ../../infra/config/capimgmt.yaml
```
Ideally you should use a virtualenv.