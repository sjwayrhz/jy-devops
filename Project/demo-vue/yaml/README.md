## create sjhz-deployment.yaml 

## change sjhz-deployment.yaml to sjhz-daemonset.yaml

### Question:
error: error validating "sjhz-daemonset.yaml": error validating data: ValidationError(DaemonSet.spec): unknown field "replicas" in io.k8s.api.apps.v1.DaemonSetSpec; if you choose to ignore these errors, turn validation off with --validate=false
### Answer:
replicas can't be used in DaemonSet


## change sjhz-deployment.yaml to sjhz-statefulset.yaml
### Question:
error: error validating "sjhz-statefulset.yaml": error validating data: ValidationError(StatefulSet.spec): missing required field "serviceName" in io.k8s.api.apps.v1.StatefulSetSpec; if you choose to ignore these errors, turn validationoff with --validate=false
### Answer:
create a serviceName can solve this problem , just like `serviceName: sjhz-service` . and the we should use service to expose the app.
```
$ cat /etc/hosts | grep sjhz
10.4.1.76       sjhz-0.sjhz-service.default.svc.cluster.local   sjhz-0
```
