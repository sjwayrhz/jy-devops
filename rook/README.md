For documentation on running Rook in your Kubernetes cluster see the [Kubernetes Quickstart Guide](/Documentation/quickstart.md)

```
kubectl create -f crds.yaml -f common.yaml -f operator.yaml
kubectl create -f cluster.yaml
```
