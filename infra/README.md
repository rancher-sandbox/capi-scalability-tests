# CAPI Scalability Tests - Infrastructure

Install terraform and then do:

```shell
terraform init
terraform plan
terraform apply
```

## TODO:

- [ ] Add option to enable profiler for KCP...execute the following if its true:

```bash
kubectl -n capi-kubeadm-control-plane-system patch deployment capi-kubeadm-control-plane-controller-manager \
--type=json \
-p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--profiler-address=localhost:6060"}]'
```

## Acknowledgements

The infrastructure setup is heavily insipred by @moio who has done lots of scalability testing of Rancher: https://github.com/moio/scalability-tests
