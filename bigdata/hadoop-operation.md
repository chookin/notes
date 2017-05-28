# 运维

## NameNode故障恢复

NameNode故障恢复有两种模式，视情况而定。如果NameNode故障后能够启动，则尽量启动原Master，测试数据可用性，在索引没有损坏的情况下可以恢复整个系统数据。如果NameNode不能启动或者索引损坏，需要使用备份切换，查看主节点索引文件，更新集群配置master节点信息，并启动Secondary NameNode作为集群主节点。

## DataNode故障恢复

Hadoop集群本身具有冗余机制，集群上数据采用多个备份，正常情况下，单机故障不会影响到hadoop集群的数据可用性。如果某一台DataNode故障，直接启动起来即可，如果机器不可用，可以直接下架，不影响已有服务。

## 块丢失

```
WARNING : There are about 74 missing blocks. Please check the log or run fsck.
```

打印损坏的文件

```shell
hadoop fsck / > fsck.log
```

看输出内容的结尾部分

```
.............Status: HEALTHY
 Total size:    10566879576039 B (Total open files size: 10112232448 B)
 Total dirs:    47301
 Total files:   283013 (Files currently being written: 18)
 Total blocks (validated):      321211 (avg. block size 32897004 B) (Total open file blocks (not validated): 94)
 Minimally replicated blocks:   321211 (100.0 %)
 Over-replicated blocks:        39739 (12.371618 %)
 Under-replicated blocks:       1581 (0.49219984 %)
 Mis-replicated blocks:         0 (0.0 %)
 Default replication factor:    2
 Average block replication:     2.3728888
 Corrupt blocks:                0
 Missing replicas:              3162 (0.41485283 %)
 Number of data-nodes:          8
 Number of racks:               1
FSCK ended at Wed Apr 05 14:39:36 CST 2017 in 6546 milliseconds
```

上面的检查说明实际上没有块丢失，不需处理。

若确实是有块丢失，则可以移除丢失的块对应的文件。

```shell
# 可以移除 missing block
hadoop fsck -delete
# 會把有錯誤的檔案移到 HDFS 的 /lost+found
hadoop fsck -move
```

## 增加节点

修改`namenode`的配置文件`conf/slaves`， 添加新增节点的ip或host

在新节点的机器上，启动服务

```shell
hadoop-daemon.sh start datanode
hadoop-daemon.sh starttasktracker
```

均衡block

```shell
start-balancer.sh
```

1）如果不balance，那么cluster会把新的数据都存放在新的node上，这样会降低mapred的工作效率

2）设置平衡阈值，默认是10%，值越低各节点越平衡，但消耗时间也更长

```shell
start-balancer.sh -threshold 5
```

3）设置balance的带宽，默认只有1M/s

```xml
<property>
 　　<name>dfs.balance.bandwidthPerSec</name>
 　　<value>1048576</value>
　　<description>
　　　　Specifies themaximum amount of bandwidth that each datanode
　　　　can utilizefor the balancing purpose in term of
　　　　the number ofbytes per second.
 　　</description>
 </property>
```

## 节点下架
配置`hdfs-site.xml`
```xml
<property>
　　<name>dfs.hosts.exclude</name>
　　<value>/home/hadoop/hadoop-installed/conf/excludes</value>
　　<description>Names a file that contains a list of hosts that are
　　not permitted to connect to the namenode.  The full pathname of the
　　file must be specified.  If the value is empty, no hosts are
　　excluded.</description>
</property>
```

在由`dfs.hosts.exclude`指定的文件中填写需要下架的节点名或者IP，一行一条，这将阻止他们去连接Namenode。例如：

```shell
[hadoop@lab02 conf]$ cat excludes
lab15
lab16
```

通知namenode集群节点发生调整。

```shell
hadoop dfsadmin -refreshNodes
```

这个将阻止他们去连接Namenode。

查看要下架机器的实时状态

```shell
[hadoop@lab02 conf]$ hadoop dfsadmin -report
Configured Capacity: 130066118893568 (118.29 TB)
Present Capacity: 83787080124954 (76.2 TB)
DFS Remaining: 58966465683456 (53.63 TB)
DFS Used: 24820614441498 (22.57 TB)
DFS Used%: 29.62%
Under replicated blocks: 50983
Blocks with corrupt replicas: 0
Missing blocks: 237

-------------------------------------------------
Datanodes available: 7 (10 total, 3 dead)

Name: 172.31.167.172:50010
Decommission Status : Normal
Configured Capacity: 29461337632768 (26.79 TB)
DFS Used: 4453441767188 (4.05 TB)
Non DFS Used: 9464185571564 (8.61 TB)
DFS Remaining: 15543710294016(14.14 TB)
DFS Used%: 15.12%
DFS Remaining%: 52.76%
Last contact: Wed Apr 05 11:15:00 CST 2017
...
Name: 172.31.167.161:50010
Decommission Status : Normal
Configured Capacity: 0 (0 KB)
DFS Used: 0 (0 KB)
Non DFS Used: 0 (0 KB)
DFS Remaining: 0(0 KB)
DFS Used%: 100%
DFS Remaining%: 0%
Last contact: Sat Apr 01 15:41:50 CST 2017


Name: 172.31.167.162:50010
Decommission Status : Decommissioned
Configured Capacity: 0 (0 KB)
DFS Used: 0 (0 KB)
Non DFS Used: 0 (0 KB)
DFS Remaining: 0(0 KB)
DFS Used%: 100%
DFS Remaining%: 0%
Last contact: Sat Apr 01 15:41:51 CST 2017
```

正在执行Decommission，会显示：

```
Decommission Status : Decommission inprogress
```

执行完毕后，会显示：

```
Decommission Status : Decommissioned
```

也可以在浏览器[http://master:50070](http://master:50070)里查看实时迁移状态。

登录要下架的机器，会发现DataNode进程没有了，但是TaskTracker依然存在，需要手工停掉。

最后将下架的节点从slaves文件中移除，接着可删除excludes文件里的内容。

## 文件状态检查

```shell
hadoop fsck /
```

用这个命令可以检查整个文件系统的健康状况，但是要注意它不会主动恢复备份缺失的block，这个是由NameNode单独的线程异步处理的。

```shell
Status: HEALTHY
 Totalsize:    5470747167287 B (Total openfiles size: 4563138560 B)
 Totaldirs:    10120
 Totalfiles:   81095 (Files currently beingwritten: 36)
 Totalblocks (validated):      102871 (avg.block size 53180655 B) (Total open file blocks (not validated): 93)
 Minimallyreplicated blocks:   102871 (100.0 %)
 Over-replicated blocks:        5680 (5.521478 %)
 Under-replicated blocks:       0 (0.0 %)
 Mis-replicated blocks:         0 (0.0 %)
 Defaultreplication factor:    2 # 缺省的备份参数2
 Averageblock replication:     2.5096772
 Corruptblocks:                0 # 破损的block数0
 Missingreplicas:              0 (0.0 %)
 Number ofdata-nodes:          16
 Number ofracks:               1

FSCK ended at Tue Jan 27 14:00:00 CST 2015 in2024 milliseconds
The filesystem under path '/' is HEALTHY
```

## 注意事项

- hadoop各任务节点性能需要保持相似，如果两任务机性能相差太大，在hadoop分配任务时其中一台运行时间将远大于另外一台，结果会造成整体性能下降。
