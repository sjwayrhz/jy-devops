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