# Zookeeper使用笔记

# 部署

```sh
curl -L -O http://mirrors.hust.edu.cn/apache/zookeeper/stable/zookeeper-3.4.10.tar.gz
```

## 单机模式

进入zookeeper目录下的conf子目录, 编辑`zoo.cfg`。

```shell
# The number of milliseconds of each tick
tickTime=2000
# The directory where the snapshot is stored.
# Do not use /tmp for storage.
# Putting the log on a busy device will adversely effect  performance.
dataDir=/data/zookeeper/data
dataLogDir=/data/zookeeper/logs
# the port at which the clients will connect
clientPort=2181
```

## 集群配置

进一步修改`zoo.cfg`，

```shell
# The number of ticks that the initial synchronization phase can take
initLimit=10
# The number of ticks that can pass between sending a request and getting an acknowledgement
syncLimit=5

# 配置集群各节点的地址
server.1=zk01:2888:3888
server.2=zk02:2888:3888
server.3=zk03:2888:3888
```

说明：

server.X=A:B:C 其中X是一个数字, 表示这是第几号server. A是该server所在的IP地址. B配置该server和集群中的leader通信使用的端口. C配置选举leader时所使用的端口.

在`dataDir`参数指定的存储路径中，创建myid文件，myid文件的内容只有一行，且内容只能为1 - 255之间的数字，这个数字亦即上面介绍server.id中的id。

# 操作

## 启动

```shell
zkServer.sh start
```

如果想在前台中运行以便查看服务器进程的输出日志，可以通过以下命令运行：

```shell
zkServer.sh start-foreground
```

## 状态

```shell
$ zkServer.sh status
JMX enabled by default
Using config: /home/hadoop/hbase-installed/zookeeper-3.4.5/bin/../conf/zoo.cfg
Mode: follower
```

## 连接

```shell
bin/zkCli.sh -server zoo1:2181,zoo2:2181,zoo3:2181
```

```shell
ls /
# 创建一个Znode节点，路径标识为“/data”，包含内容“data”
create /data "data"
# 删除Znode节点
delete /data
```

# 附注

## 奇数台机器

我们通常使用zookeeper集群来协同管理另外一个集群，比如HBase集群，一个HBase集群必然对应一个zookeeper集群。在部署zookeeper集群的时候，我们为什么选择奇数台机器呢？

关于zookeeper集群有下面几点说明

- 1.集群中机器数目越多越稳定
- 2.集群通过选举的方式来选出集群的leader，要是有一半以上的机器同一某个机器成为leader,那么这个机器就编程集群中的leader
- 3.要是集群中有一半以上的机器挂掉，整个集群就会挂掉

对于2N和2N+1台机器，选出leader的时候都需要有N+1票，就是说N+1台机器投票给某一台机器，因此2N和2N+1台机器构成的集群在投票过程中所投票数一样，但是2N+1台机器构成的集群稳定。同样2N台机器中挂掉N台的概率是50%，但是2N+1台机器中挂掉N太的概率小于50%，也就是说2N+1台机器构成的集群比较稳定。

综上所述：
zookeeper集群选择2N+1台机器是比较合理的。

# 参考

- [Chapter 2 Getting to Grips with ZooKeeper](http://blog.csdn.net/dslztx/article/details/51077606)
