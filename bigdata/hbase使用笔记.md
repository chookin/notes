配置hbase-env.sh，配置ZooKpeer是否托管。
hmaster http://111.13.47.171:16010
regionserver http://111.13.47.171:16301

hbase-daemon.sh start thrift
Thrift默认监听的端口是9090

注意http端口的变化
https://issues.apache.org/jira/browse/HBASE-10123

    After 0.98 hbase's default ports have changed to be outside of the ephemeral port range:.

    hbase.master.port : 60000 -> 16000
    hbase.master.info.port (http): 60010 -> 16010
    hbase.regionserver.port : 60020 -> 16020
    hbase.regionserver.info.port (http): 60030 -> 16030
    hbase.status.multicast.port : 60100 -> 16100



# 安装

## 配置

### 依赖项版本验证

检查HBASE_HOME/lib下“hadoop-core-*.jar”和“zookeeper-*.jar”是否与系统中部署的Hadoop和Zookeeper版本一致，如果不一致，则需要替换为系统部署的Hadoop和Zookeeper版本的jar。

### setting user limits

Because HBase is a database, it uses a lotof files at the same time. The default ulimit setting of 1024 for the maximum number of open files on Unix-likesystems is insufficient.

In the  `/etc/security/limits.conf` file, add the following lines:

```
hdfs  -       nofile 327680
hbase -       nofile  327680
```

### hbase-env.sh

可以不做如下配置。

```shell
export JAVA_HOME=/usr/local/jdk
export HBASE_REGIONSERVER_OPTS="-Xmx4g -Xms4g -Xmn128m -XX:+UseParNewGC -XX:+UseConcMarkSweepGC -XX:CMSInitiatingOccupancyFraction=70 $HBASE_REGIONSERVER_OPTS"
export HBASE_TMP_DIR=/data/hbase/tmp
export HBASE_LOG_DIR=${HBASE_TMP_DIR}/logs
export HBASE _PID_DIR=${HBASE_TMP_DIR}/pids
# 若使用非HBase自带的zookeeper
export HBASE_MANAGES_ZK=false
```

### hbase-site.xml

```xml
<configuration>
  <property>
    <name>hbase.rootdir</name>
    <value>hdfs://hadoopnn:9100/user/hbase</value>
    <description>The directory shared by region servers and into which HBase persists. Please refer to `fs.defaultFS`</description>
  </property>
  <property>
    <name>hbase.cluster.distributed</name>
    <value>true</value>
    <description>whether cluster</description>
  </property>
  <property>
    <name>hbase.zookeeper.quorum</name>
    <value>zk01,zk02,zk03</value>
    <description>Comma separated list of servers in the ZooKeeper ensemble</description>
  </property>
</configuration>
```

### backup-masters

为了增加hbase集群的可用性，可以为hbase增加多个backup master。当master挂掉后，backup master可以自动接管整个hbase的集群。

在该文件里面增加backup master的机器列表，每台机器一条记录。

### regionservers

配置HBase的RegionServer节点列表

# 维护

## 节点下线

### regionserver decommission

```shell
[hadoop@lab18 ~]$ cd hbase-installed/hbase/bin/
[hadoop@lab18 bin]$ jps
13368 Jps
31132 ThriftServer
17024 TaskTracker
28897 HQuorumPeer
29020 HRegionServer
16868 DataNode
[hadoop@lab18 bin]$ sh graceful_stop.sh lab18
Disabling balancer! (if required)
Previous balancer state was true
Unloading lab18 region(s)
17/04/11 09:57:14 INFO zookeeper.ZooKeeper: Client environment:zookeeper.version=3.4.5-1392090, built on 09/30/2012 17:52 GMT
17/04/11 09:57:14 INFO zookeeper.ZooKeeper: Client environment:host.name=lab18
17/04/11 09:57:14 INFO zookeeper.ZooKeeper: Client environment:java.version=1.7.0_05
17/04/11 09:57:14 INFO zookeeper.ZooKeeper: Client environment:java.vendor=Oracle Corporation
...
17/04/11 09:57:14 INFO zookeeper.ZooKeeper: Client environment:java.library.path=/home/hadoop/hadoop-installed/hadoop-1.2.1/libexec/../lib/native/Linux-amd64-64:/home/hadoop/hbase-installed/hbase/bin/../lib/native/Linux-amd64-64
17/04/11 09:57:14 INFO zookeeper.ZooKeeper: Client environment:java.io.tmpdir=/tmp
17/04/11 09:57:14 INFO zookeeper.ZooKeeper: Client environment:java.compiler=<NA>
17/04/11 09:57:14 INFO zookeeper.ZooKeeper: Client environment:os.name=Linux
17/04/11 09:57:14 INFO zookeeper.ZooKeeper: Client environment:os.arch=amd64
17/04/11 09:57:14 INFO zookeeper.ZooKeeper: Client environment:os.version=2.6.32-642.11.1.el6.x86_64
17/04/11 09:57:14 INFO zookeeper.ZooKeeper: Client environment:user.name=hadoop
17/04/11 09:57:14 INFO zookeeper.ZooKeeper: Client environment:user.home=/home/hadoop
17/04/11 09:57:14 INFO zookeeper.ZooKeeper: Client environment:user.dir=/home/hadoop/hbase-installed/hbase-0.94.12/bin
17/04/11 09:57:14 INFO zookeeper.ZooKeeper: Initiating client connection, connectString=lab17:2181,lab16:2181,lab15:2181,lab14:2181,lab18:2181 sessionTimeout=180000 watcher=hconnection
17/04/11 09:57:14 INFO zookeeper.RecoverableZooKeeper: The identifier of this process is 14422@lab18
17/04/11 09:57:14 INFO zookeeper.ClientCnxn: Opening socket connection to server lab14/172.31.167.161:2181. Will not attempt to authenticate using SASL (unknown error)
17/04/11 09:57:14 INFO zookeeper.ClientCnxn: Socket connection established to lab14/172.31.167.161:2181, initiating session
17/04/11 09:57:14 INFO zookeeper.ClientCnxn: Session establishment complete on server lab14/172.31.167.161:2181, sessionid = 0x592aacd93e03d2, negotiated timeout = 180000
Valid region move targets:
lab11,60020,1482479695222
lab30,60020,1482479689006
lab32,60020,1482479698170
lab05,60020,1482479707907
lab29,60020,1482481213043
lab33,60020,1482479692986
lab02,60020,1486519205168
lab03,60020,1485828606900
lab31,60020,1482479691695
lab06,60020,1482479694249
lab04,60020,1482479686554
17/04/11 09:57:15 INFO region_mover: Moving 61 region(s) from lab18,60020,1482479687982 during this cycle
17/04/11 09:57:15 INFO region_mover: Moving region 1028785192 (0 of 61) to server=lab05,60020,1482479707907
17/04/11 09:57:16 INFO region_mover: Moving region de583bd2884d771484267b070618e061 (1 of 61) to server=lab29,60020,1482481213043
...
17/04/11 09:59:18 INFO region_mover: Moving region c8515ac58bf0c4659371e4b8893835f2 (60 of 61) to server=lab31,60020,1482479691695
17/04/11 09:59:20 INFO region_mover: Wrote list of moved regions to /tmp/lab18
Unloaded lab18 region(s)
lab18: Warning: Permanently added the RSA host key for IP address '172.31.167.153' to the list of known hosts.
lab18: stopping regionserver....
Restoring balancer state to true
[hadoop@lab18 bin]$ jps
31132 ThriftServer
16221 Jps
17024 TaskTracker
28897 HQuorumPeer
16868 DataNode
```
