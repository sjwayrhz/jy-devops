前提：
需要集群中部署ingress-nginx

使用的nginx创建的url为 `gitlab.sjhz.tk`

如果使用ingress,虽然可以在7层转发URL,但是git clone的时候占用的是4层TCP层，所以还是需要对gitlab中的ssh（22）端口做映射，比较复杂。不太推荐。