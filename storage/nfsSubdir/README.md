## 部署nfs共享存储

### 替换rbac的namespace为kube-system
```
$ NAMESPACE=kube-system
$ sed -i'' "s/namespace:.*/namespace: $NAMESPACE/g" 1-rbac.yaml 2-nfs-client-provisioner.yaml
$ kubectl create -f 1-rbac.yaml
```
### 部署nfs-client-provisioner
这里部署nfs-client-provisioner到kube-system的namespace
注意： 
`<YOUR NFS SERVER HOSTNAME>` 需要填写nfs-server的ip地址
`<YOUR NFS SERVER SHARED DIR>`需要填写nfs-server的共享文件夹路径
例如nfs共享路径为 192.168.177.206:/data
```
$ sed -i'' "s/<YOUR NFS SERVER HOSTNAME>/192.168.177.206/g" 2-nfs-client-provisioner.yaml
$ sed -i'' "s/<YOUR NFS SERVER SHARED DIR>/\/data/g" 2-nfs-client-provisioner.yaml
$ kubectl create -f 2-nfs-client-provisioner.yaml
```
### 部署nfs-client.yaml
```
$ kubectl create -f 3-nfs-client.yaml
```