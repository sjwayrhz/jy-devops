
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

