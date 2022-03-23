StatufulSet非常适合类似数据库实例部署等对数据持久性、启动顺序、实例之间相互访问的场景，在创建的过程中要注意创建顺序：创建PV->创建PVC->创建Headless Service->创建StatufulSet。

$(podname).(headless server name)
FQDN： $(podname).(headless server name).namespace.svc.cluster.local

为什么需要 headless service 无头服务？
在用Deployment时，每一个Pod名称是没有顺序的，是随机字符串，因此是Pod名称是无序的，但是在statefulset中要求必须是有序 ，每一个pod不能被随意取代，pod重建后pod名称还是一样的。而pod IP是变化的，所以是以Pod名称来识别。pod名称是pod唯一性的标识符，必须持久稳定有效。这时候要用到无头服务，它可以给每个Pod一个唯一的名称 。

为什么需要volumeClaimTemplate？ 对于有状态的副本集都会用到持久存储，对于分布式系统来讲，它的最大特点是数据是不一样的，所以各个节点不能使用同一存储卷，每个节点有自已的专用存储，但是如果在Deployment中的Pod template里定义的存储卷，是所有副本集共用一个存储卷，数据是相同的，因为是基于模板来的 ，而statefulset中每个Pod都要自已的专有存储卷，所以statefulset的存储卷就不能再用Pod模板来创建了，于是statefulSet使用volumeClaimTemplate，称为卷申请模板，它会为每个Pod生成不同的pvc，并绑定pv， 从而实现各pod有专用存储。这就是为什么要用volumeClaimTemplate的原因。

如果集群中没有StorageClass的动态供应PVC的机制，也可以提前手动创建多个PV、PVC，手动创建的PVC名称必须符合之后创建的StatefulSet命名规则：(volumeClaimTemplates.name)-(pod_name)
```
https://www.cnblogs.com/tylerzhou/p/11027559.html
```
