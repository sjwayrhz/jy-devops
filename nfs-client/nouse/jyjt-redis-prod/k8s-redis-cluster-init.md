启动一个centos来干活
```
kubectl run -it centos --image=centos:7 --restart=Never -n app-prod bash
```
创建cluster
```
# redis-cli --cluster create \
  `dig +short redis-0.redis.app-prod.svc.cluster.local`:6379 \
  `dig +short redis-1.redis.app-prod.svc.cluster.local`:6379 \
  `dig +short redis-2.redis.app-prod.svc.cluster.local`:6379
```
查找cluster id 
```
redis-cli -h `dig +short redis-0.redis.app-prod.svc.cluster.local` -p 6379
10.2.89.184:6379> cluster info
cluster_state:ok
cluster_slots_assigned:16384
cluster_slots_ok:16384
cluster_slots_pfail:0
cluster_slots_fail:0
cluster_known_nodes:3
cluster_size:3
cluster_current_epoch:3
cluster_my_epoch:1
cluster_stats_messages_ping_sent:718
cluster_stats_messages_pong_sent:699
cluster_stats_messages_sent:1417
cluster_stats_messages_ping_received:697
cluster_stats_messages_pong_received:718
cluster_stats_messages_meet_received:2
cluster_stats_messages_received:1417
10.2.89.184:6379> cluster nodes
059dd2b2f924ac73af7ef69ce2fc6a1f6523f6bf 10.2.16.126:6379@16379 master - 0 1630446783260 2 connected 5461-10922
ce303e0515c9142eeb31109a0b29bf425678b469 10.2.44.250:6379@16379 master - 0 1630446784262 3 connected 10923-16383
47f7d58bff8f6c37691c1ee20e9024f21ce1ccf2 10.2.89.184:6379@16379 myself,master - 0 1630446783000 1 connected 0-5460
```
添加cluster master slave
```
redis-cli  --cluster add-node `dig +short redis-3.redis.app-prod.svc.cluster.local`:6379 `dig +short redis-0.redis.app-prod.svc.cluster.local`:6379 --cluster-slave --cluster-master-id 47f7d58bff8f6c37691c1ee20e9024f21ce1ccf2
redis-cli  --cluster add-node `dig +short redis-4.redis.app-prod.svc.cluster.local`:6379 `dig +short redis-1.redis.app-prod.svc.cluster.local`:6379 --cluster-slave --cluster-master-id 47f7d58bff8f6c37691c1ee20e9024f21ce1ccf2
redis-cli  --cluster add-node `dig +short redis-5.redis.app-prod.svc.cluster.local`:6379 `dig +short redis-2.redis.app-prod.svc.cluster.local`:6379 --cluster-slave --cluster-master-id 47f7d58bff8f6c37691c1ee20e9024f21ce1ccf2
```


集群哪怕只有一个节点可访问，也要按照集群配置方式
```
  否则报错例如MOVED 1545 10.244.3.239:6379","data":false
  如本文的情况，redis cluster的每个节点都是一个跑在k8s里面的pod，这些pod并不能被外部直接访问，而是通过ingress等方法对外暴露一个访问接口，即只有一个统一的ip：port给外部访问。经由k8s的调度，对这个统一接口的访问会被发送到redis集群的某个节点。这时候对redis的用户来说，看起来这就像是一个单节点的redis。但是，此时无论是直接使用命令行工具redis-cli，还是某种语言的sdk，还是需要按照集群来配置redis的连接信息，才能正确连接。
```

参考链接`https://blog.csdn.net/miss1181248983/article/details/106841329`