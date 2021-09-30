使用的nginx创建的url为 `gitlab.sjhz.tk`

在k8s中，gitlab使用的是nodePort方式对外映射的，gitlab的nodePort映射端口为 ssh:30122 http:30180
部署外部nginx,如果nginx上的8090通过tcp反向代理到ssh:30122 
那么，外部通过git连接到gitlab的情况如下

https的下载方式
```
git clone https://gitlab.sjhz.tk/sjwayrhz/devops.git
```
git clone 的下载方式
```
git clone ssh://git@gitlab.sjhz.tk:8090/sjwayrhz/devops.git
```