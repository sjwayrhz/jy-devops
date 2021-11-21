
## 部署方法
假设你想安装ingress到linux主机名为`k8s-master`的主机上
先确认集群中的linux主机名
```
cat /etc/hosts
10.230.7.20 k8s-master
```
你可以直接apply此yaml文件
```bash
$ kubectl apply -f ingress-nginx.yaml
```

假设你想安装ingress到linux主机名为`ghost-k8s-master`的主机上
先确认集群中的linux主机名
```
cat /etc/hosts
192.168.177.45 ghost-k8s-master
```
你需要替换`k8s-master`为`ghost-k8s-master`再apply此yaml文件
```bash
$ sed -i 's/k8s-master/ghost-k8s-master/g' ingress-nginx.yaml
$ kubectl apply -f ingress-nginx.yaml
```

## 新yaml修改内容
### 修改nodeSelector
baremetal 环境下原生支持的nodeSelector是hostname是linux，可以改为如k8s-master这样的主机名
```
      nodeSelector:
        kubernetes.io/os: linux
```
可以修改为
```
      nodeSelector:
        kubernetes.io/hostname: k8s-master
      tolerations:
      - key: node-role.kubernetes.io/master
        effect: NoSchedule
```
这可能有三处相同的参数需要修改
单独修改nodeSelector是不够的，还需要添加容忍。

### 修改image ID
镜像名称需要修改
```
k8s.gcr.io/ingress-nginx/controller:v1.0.5@sha256:55a1fcda5b7657c372515fe402c3e39ad93aa59f6e4378e82acd99912fe6028d
k8s.gcr.io/ingress-nginx/kube-webhook-certgen:v1.1.1@sha256:64d8c73dca984af206adf9d6d7e46aa550362b1d7a01f3a0a91b20cc67868660
```
修改为
```
sjwayrhz/controller:v1.0.5
sjwayrhz/kube-webhook-certgen:v1.1.1
```
## 增加NodePort端口