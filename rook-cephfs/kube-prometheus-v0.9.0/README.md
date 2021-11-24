# kube-prometheus v0.9.0
## 官方项目地址
`https://github.com/prometheus-operator/kube-prometheus`
## 官方manifests文件
官方的manifests目录下的yaml脚本转移到github-manifests文件夹中
官方的manifests/setup目录下的yaml脚本转移到github-manifests-setup文件夹中

> 注意 :官方没有做持久化存储，容器丢失数据

## 在均瑶科创公司修改后的manifests文件
移动manifests目录下的yaml脚本转移到juneyao-manifests文件夹中
移动manifests/setup目录下的yaml脚本转移到juneyao-manifests-setup文件夹中

## 部署方法
```bash
$ kubectl apply -f juneyao-manifests-setup
$ until kubectl get servicemonitors --all-namespaces ; do date; sleep 1; echo ""; done
$ kubectl apply -f juneyao-manifests
```

## 修改内容
### 替换镜像源
根据images.md中记录的镜像文件进行修改
### 修改promethus参数
- 依据文件prometheus-service.yaml，设置service nodeport 30001
- 依据文件prometheus-prometheus.yaml，设置storageclassname: rook-cephfs
### 修改grafana参数
- 依据文件grafana-service.yaml，设置service nodeport 30002
- 依据文件grafana-deployment.yaml,设置storageclassname: rook-cephfs
### 修改altermanager参数
- 依据文件altermanager-service.yaml，设置service nodeport 30003
- 依据文件alertmanager-alertmanager.yaml,设置storageclassname: rook-cephfs
### 添加loki，并修改参数
在juneyao-manifests中添加loki+promtail在monitoring namespaces里面
添加文件 monitoring-loki.yaml，monitoring-promtail.yaml
- 依据monitoring-loki.yaml，设置service nodeport 30004
- 设置storageclassname: rook-cephfs
### 修改prometheus日志保留时间
修改文件为juneyao-manifests-setup/prometheus-operator-deployment.yaml
- storage.tsdb.retention.time=30d
设置日志保留一个月