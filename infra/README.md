# CAPI Scalability Tests - Infrastructure

Install terraform and then do:

```shell
terraform init
terraform plan
terraform apply
```

## To Enable Profiling

- Add the profiler address to the CAPI/provider deployment:

```bash
kubectl -n capi-kubeadm-control-plane-system patch deployment capi-kubeadm-control-plane-controller-manager \
--type=json \
-p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--profiler-address=localhost:6060"}]'
```

- After the new rollout of the pod start forwarding to it:

```bash
kubectl port-forward --namespace capi-kubeadm-control-plane-system pods/capi-kubeadm-control-plane-controller-manager-6677b9ddc7-vh65z 13000:6060
```

- Collect a profile:

```bash
go tool pprof -http=: "http://localhost:13000/debug/pprof/profile?seconds=60"
```

## Acknowledgements

The infrastructure setup is heavily inspired by [@moio](https://github.com/moio) who has done lots of scalability testing of Rancher: https://github.com/moio/scalability-tests.

Early on in the tests we ran into [this issue](https://github.com/kubernetes-sigs/cluster-api/issues/8602), thanks to [@lentzi](https://github.com/) for investigating the issue and identifying the "signature"/cause and thanks to [@fabriziopandini](https://github.com/fabriziopandini) for [fixing the issue](https://github.com/kubernetes-sigs/cluster-api/pull/8617). 
