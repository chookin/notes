# 部署

## hadoop

### 创建用户

```shell
## in remote_cmds.sh
# create user hadoop
useradd hadoop && echo "hadoop_Ln17" | passwd --stdin hadoop
```

### 建立ssh互信

在客户机cm01上操作

```shell
## in remote_cmds.sh
su --session-command="cd && ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && chmod 700 ~/.ssh" hadoop

## in cmds.sh script
# manual do ssh $host to update known_hosts and then rsync to other hosts
rsync -av /root/.ssh/known_hosts $host:/root/.ssh/
rsync -av $host:/home/hadoop/.ssh/id_rsa.pub /home/hadoop/.ssh/id_rsa.pub.$host/

## in cm01 shell
cd /home/hadoop/.ssh/
cat id_rsa.pub.* > authorized_keys
chown -R hadoop.hadoop authorized_keys
chmod 600 authorized_keys
# manual do ssh $host to update known_hosts

## in cmds.sh script
rsync -av /home/hadoop/.ssh/known_hosts $host:/home/hadoop/.ssh/
rsync -av /home/hadoop/.ssh/authorized_keys $host:/home/hadoop/.ssh/
```



其中，手动添加到可信hosts

```shell
[hadoop@PZMG-WB01-VAS ~]$ ssh cm02
The authenticity of host 'cm02 (172.17.128.12)' can't be established.
RSA key fingerprint is f8:f2:de:a5:fd:6e:af:f4:d3:72:0b:5d:a6:14:bf:9b.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'cm02,172.17.128.12' (RSA) to the list of known hosts.
 Authorized users only. All activity may be monitored and reported
hadoop@cm02's password:
```

### 创建数据文件夹

```shell
mkdir -p /home/data/hadoop
chown -R hadoop.hadoop /home/data/hadoop
ln -s /home/data/hadoop /data/hadoop
su - hadoop -c 'mkdir /data/hadoop/nn'
su - hadoop -c 'mkdir /home/hadoop/local'
```

### bash_profile

环境变量配置文件

`/home/hadoop/.bash_profile`

```shell
# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
        . ~/.bashrc
fi

# User specific environment and startup programs
PATH=$HOME/bin:$PATH

export PATH

######### HADOOP ENVIRONMENT #########
export HADOOP_HOME=$HOME/local/hadoop
export HADOOP_CONF_DIR=$HOME/local/hadoop-conf
export PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH
export HADOOP_HOME_WARN_SUPPRESS=1

export JAVA_HOME=$HOME/local/jdk
export PATH=$JAVA_HOME/bin:$PATH

export SPARK_HOME=$HOME/local/spark
export PATH=$SPARK_HOME/bin:$PATH

export PATH=/home/work/local/python/bin:$PATH

export LD_LIBRARY_PATH=/home/work/local/mcript/lib:/home/work/local/mysql/lib:/home/work/local/libpng/lib:/home/work/local/jpeg/lib:lib:/usr/lib:/usr/lib64:/usr/local/lib:$LD_LIBRARY_PATH
```

因为任务脚本需要在hadoop用户下访问work用户的文件，所以需要修改work用户的文件夹权限

```shell
find /home/work -type d | xargs chmod 755
```

### 安装java

```shell
cd /home/hadoop/local
tar xvf /data/cmri-docs/soft/java/jdk-7u79-linux-x64.tar.gz
mv jdk1.7* jdk

rsync -av /home/hadoop/local $host:/home/hadoop
rsync -av /home/hadoop/.bash_profile $host:/home/hadoop
```



### 安装hadoop

```shell
cd /home/hadoop/local
tar xvf /data/cmri-docs/soft/hadoop/hadoop-2.7.2.tar.gz
mv hadoop-2.* hadoop
```

### 配置

#### core-site.xml

```xml
<configuration>
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://hadoopnn:9100</value>
  </property>
  <property>
    <name>hadoop.tmp.dir</name>
    <value>/data/hadoop/tmp</value>
    <description>A base for other temporary directories.</description>
  </property>
  <property>
    <name>io.file.buffer.size</name>
    <value>131072</value>
  </property>
  <property>
    <name>fs.trash.interval</name>
    <value>1440</value>
    <description>Number of minutes between trash checkpoints. If zero, the trash feature is disabled.</description>
  </property>

  <property>
    <name>fs.checkpoint.period</name>
    <value>300</value>
    <description>The number of seconds between two periodic checkpoints.
    </description>
  </property>

  <property>
    <name>fs.checkpoint.size</name>
    <value>67108864</value>
    <description>The size of the current edit log (in bytes) that triggers  a periodic checkpoint even if the fs.checkpoint.period hasn't expired.
    </description>
  </property>
</configuration>
```

#### hdfs-site.xml

```xml
<configuration>
  <property>
    <name>dfs.replication</name>
    <value>2</value>
  </property>
  <property>
    <name>dfs.namenode.name.dir</name>
    <value>/data/hadoop/nn</value>
  </property>
  <property>
    <name>dfs.datanode.data.dir</name>
    <value>/data/hadoop/dn</value>
  </property>
  <property>
    <name>dfs.blocksize</name>
    <value>134217728</value>
  </property>
  <property>
　　 <name>dfs.balance.bandwidthPerSec</name>
　　 <value>10485760</value>
　　 <description>
　　　　Specifies the maximum amount of bandwidth that each datanode
　　　　can utilize for the balancing purpose in term of
　　　　the number of bytes per second.
　　 </description>
  </property>
  <property>
    <name>dfs.namenode.handler.count</name>
    <value>100</value>
  </property>
  <property>
    <name>dfs.webhdfs.enabled</name>
    <value>true</value>
  </property>

  <property>
    <name>dfs.namenode.http-address</name>
    <value>hadoopnn:50070</value>
  </property>
  <property>
      <name>dfs.namenode.secondary.http-address</name>
      <value>hadoopsnn:50090</value>
  </property>
</configuration>
```

必须手工创建namenode的数据文件夹

#### hadoop-env.sh

Hadoop-env配置文件为hadoop运行相关环境变量配置（主要是配置JAVA_HOME）：

```shell
# hadoop-env.sh
export JAVA_HOME=/home/hadoop/local/jdk
export HADOOP_NAMENODE_OPTS="-Dcom.sun.management.jmxremote $HADOOP_NAMENODE_OPTS"
export HADOOP_SECONDARYNAMENODE_OPTS="-Dcom.sun.management.jmxremote $HADOOP_SECONDARYNAMENODE_OPTS"
export HADOOP_DATANODE_OPTS="-Dcom.sun.management.jmxremote $HADOOP_DATANODE_OPTS"
export HADOOP_BALANCER_OPTS="-Dcom.sun.management.jmxremote $HADOOP_BALANCER_OPTS"
export HADOOP_JOBTRACKER_OPTS="-Dcom.sun.management.jmxremote $HADOOP_JOBTRACKER_OPTS"

export HADOOP_LOG_DIR=/data/hadoop/logs
export HADOOP_PID_DIR=/data/hadoop/pid
export HADOOP_OPTS=-Djava.net.preferIPv4Stack=true
```

#### yarn-env.sh

```shell
export YARN_LOG_DIR=/data/hadoop/logs
```

#### mapred-env.sh

配置jobhistory的日志路径。

```shell
export HADOOP_MAPRED_LOG_DIR=/data/hadoop/logs
```

#### mapred-site.xml

配置mapreduce.framework.name的值为yarn，表示使用yarn运行mapreduce程序。

```xml
<configuration>
  <property>
   <name>mapreduce.framework.name</name>
    <value>yarn</value>
  </property>

  <property>
   <name>mapreduce.map.memory.mb</name>
    <value>1536</value>
  </property>

  <property>
   <name>mapreduce.map.java.opts</name>
    <value>-Xmx1024M</value>
  </property>

  <property>
   <name>mapreduce.reduce.memory.mb</name>
    <value>3072</value>
  </property>

  <property>
   <name>mapreduce.reduce.java.opts</name>
    <value>-Xmx2560M</value>
  </property>

  <property>
   <name>mapreduce.task.io.sort.mb</name>
    <value>512</value>
  </property>

  <property>
    <name>mapreduce.task.io.sort.factor</name>
    <value>100</value>
  </property>

  <property>
   <name>mapreduce.reduce.shuffle.parallelcopies</name>
    <value>50</value>
  </property>

  <property>
   <name>mapreduce.jobhistory.address</name>
    <value>hadoopjobhist:10020</value>
  </property>

  <property>
   <name>mapreduce.jobhistory.webapp.address</name>
    <value>hadoopjobhist:19888</value>
  </property>
</configuration>
```

#### yarn-site.xml

yarn-site.xml文件为计算框架Yarn的配置文件：

```xml
<configuration>
  <property>
    <name>yarn.nodemanager.aux-services</name>
   <value>mapreduce_shuffle</value>
 </property>

 <property>
   <name>yarn.resourcemanager.hostname</name>
   <value>yarnmaster</value>
 </property>

 <property>
   <name>yarn.log-aggregation-enable</name>
   <value>true</value>
 </property>

 <property>
   <name>yarn.scheduler.minimum-allocation-mb</name>
   <value>512</value>
 </property>

 <property>
   <name>yarn.scheduler.maximum-allocation-mb</name>
   <value>4096</value>
 </property>

 <property>
   <name>yarn.nodemanager.address</name>
   <value>0.0.0.0:8041</value>
   <description>the nodemanagers bind to this port, the default is random</description>
 </property>

 <property>
   <name>yarn.nodemanager.resource.memory-mb</name>
   <value>16384</value>
 </property>

 <property>
   <name>yarn.nodemanager.vmem-pmem-ratio</name>
   <value>2</value>
 </property>

 <property>
   <name>yarn.nodemanager.local-dirs</name>
   <value>/data/hadoop/middle</value>
 </property>

 <property>
   <name>yarn.nodemanager.log-dirs</name>
   <value>/data/hadoop/logs</value>
  </property>

 <property>
   <name>yarn.nodemanager.aux-services</name>
   <value>mapreduce_shuffle</value>
 </property>

 <property>
   <name>yarn.log-aggregation.retain-seconds</name>
   <value>864000</value>
 </property>
</configuration>
```

#### slaves

```
cm11
cm12
cm13
cm14
cm15
cm16
```

#### 调整文件数

`/etc/security/limits.conf`

```shell
hadoop  -  nofile  1000000
hadoop  -  nproc   1000000
```

#### 禁用交换区

修改`/etc/sysctl.conf`文件，关闭swappiness。增加以下一行：

```shell
vm.swappiness = 0
```

执行`sysctl -p`使之生效

查看是否生效

```shell
$ cat /proc/sys/vm/swappiness
0
```

### 启动

#### 初始化文件系统

配置完成后，在首次启动hadoop之前，需初始化文件系统。

在namenode节点初始化namenode数据

```shell
hdfs namenode -format
```

#### 批量启动

hadoop文件系统格式化完成之后，可以使用批量脚本启动整个集群

```shell
$ bin/start-all.sh
```

使用批量停止脚本停止整个集群

```shell
$ bin/stop-all.sh
```



也可以直接启停单节点的服务。

```shell
hadoop-daemon.sh start namenode
hadoop-daemon.sh start secondarynamenode
hadoop-daemon.sh start datanode
yarn-daemon.sh start resourcemanager
yarn-daemon.sh start nodemanager
yarn-daemon.sh start proxyserver
mr-jobhistory-daemon.sh start historyserver
hadoop-daemon.sh stop namenode
```

### 测试

#### 文件系统检查

```
[hadoop@PZMG-WB10-VAS ~]$ hdfs fsck /
17/03/06 14:54:46 WARN util.NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
Connecting to namenode via http://hadoopnn:50070/fsck?ugi=hadoop&path=%2F
FSCK started by hadoop (auth:SIMPLE) from /172.17.128.20 for path / at Mon Mar 06 14:54:48 CST 2017
Status: HEALTHY
 Total size:    0 B
 Total dirs:    4
 Total files:   0
 Total symlinks:                0
 Total blocks (validated):      0
 Minimally replicated blocks:   0
 Over-replicated blocks:        0
 Under-replicated blocks:       0
 Mis-replicated blocks:         0
 Default replication factor:    2
 Average block replication:     0.0
 Corrupt blocks:                0
 Missing replicas:              0
 Number of data-nodes:          6
 Number of racks:               1
FSCK ended at Mon Mar 06 14:54:48 CST 2017 in 2 milliseconds


The filesystem under path '/' is HEALTHY
```

#### 集群状态检查

```
# 查看集群中的节点
$ hdfs dfsadmin -report
17/03/07 15:36:45 WARN util.NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
Configured Capacity: 898335326208 (836.64 GB)
Present Capacity: 842981722479 (785.09 GB)
DFS Remaining: 842575626240 (784.71 GB)
DFS Used: 406096239 (387.28 MB)
DFS Used%: 0.05%
Under replicated blocks: 0
Blocks with corrupt replicas: 0
Missing blocks: 0
Missing blocks (with replication factor 1): 0

-------------------------------------------------
Live datanodes (6):

Name: 172.17.128.26:50010 (cm16)
Hostname: cm16
Decommission Status : Normal
Configured Capacity: 149722554368 (139.44 GB)
DFS Used: 67276800 (64.16 MB)
Non DFS Used: 9140445184 (8.51 GB)
DFS Remaining: 140514832384 (130.86 GB)
DFS Used%: 0.04%
DFS Remaining%: 93.85%
Configured Cache Capacity: 0 (0 B)
Cache Used: 0 (0 B)
Cache Remaining: 0 (0 B)
Cache Used%: 100.00%
Cache Remaining%: 0.00%
Xceivers: 1
Last contact: Tue Mar 07 15:39:08 CST 2017
...
```

#### 文件夹创建

```
[hadoop@PZMG-WB10-VAS ~]$ hdfs dfs -mkdir -p /user/hadoop/test
17/03/06 14:53:53 WARN util.NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
[hadoop@PZMG-WB10-VAS ~]$ hdfs dfs -ls .
17/03/06 14:54:00 WARN util.NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
Found 1 items
drwxr-xr-x   - hadoop supergroup          0 2017-03-06 14:53 test
```

#### pi测试

```shell

```

#### mr任务测试

```shell
hdfs dfs -put /etc/hosts test
input=test/hosts
output=test/hosts-out.log
hdfs dfs -rm -r -f $output
hadoop jar $HOME/local/hadoop/share/hadoop/tools/lib/hadoop-streaming-2.7.2.jar \
    -D mapred.reduce.tasks=16 \
    -D stream.num.map.output.key.fields=15 \
    -D mapred.text.key.partitioner.options=-k4,5 \
    -D mapred.output.key.comparator.class=org.apache.hadoop.mapred.lib.KeyFieldBasedComparator \
    -D mapred.text.key.comparator.options="-k4,4 -k5,5"  \
    -input $input \
    -output $output \
    -mapper /bin/cat \
    -reducer /bin/cat  \
    -partitioner org.apache.hadoop.mapred.lib.KeyFieldBasedPartitioner
```

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

## 端口使用情况

### namenode

通过9100端口与datanode互联。

50070 namenode web管理页面

```shell
[root@PZMG-WB10-VAS ~]# netstat -lanp |grep `ps aux |grep NameNode | grep -v Second |grep -v grep | awk '{print $2}'` |grep -v unix
tcp        0      0 0.0.0.0:52491               0.0.0.0:*                   LISTEN      22310/java
tcp        0      0 172.17.128.20:9100          0.0.0.0:*                   LISTEN      22310/java
tcp        0      0 0.0.0.0:50070               0.0.0.0:*                   LISTEN      22310/java
tcp        0      0 172.17.128.20:9100          172.17.128.23:42063         ESTABLISHED 22310/java
tcp        0      0 172.17.128.20:9100          172.17.128.26:32894         ESTABLISHED 22310/java
tcp        0      0 172.17.128.20:9100          172.17.128.25:54731         ESTABLISHED 22310/java
tcp        0      0 172.17.128.20:9100          172.17.128.22:58919         ESTABLISHED 22310/java
tcp        0      0 172.17.128.20:9100          172.17.128.24:38582         ESTABLISHED 22310/java
tcp        0      0 172.17.128.20:9100          172.17.128.20:36762         ESTABLISHED 22310/java
tcp        0      0 172.17.128.20:9100          172.17.128.21:56929         ESTABLISHED 22310/java
```

### SecondaryNameNode

50090 web管理页面

```shell
[root@PZMG-WB10-VAS ~]# netstat -lanp |grep `ps aux |grep SecondaryNameNode | grep -v grep | awk '{print $2}'` |grep -v unix
tcp        0      0 0.0.0.0:37652               0.0.0.0:*                   LISTEN      22622/java
tcp        0      0 0.0.0.0:50090               0.0.0.0:*                   LISTEN      22622/java
```

### DataNode

50075 web管理页面

```shell
[root@PZMG-WB11-VAS ~]# netstat -lanp |grep `ps aux |grep DataNode | grep -v grep | awk '{print $2}'` |grep -v unix
tcp        0      0 0.0.0.0:                0.0.0.0:*                   LISTEN      13638/java
tcp        0      0 127.0.0.1:36270             0.0.0.0:*                   LISTEN      13638/java
tcp        0      0 0.0.0.0:50010               0.0.0.0:*                   LISTEN      13638/java
tcp        0      0 0.0.0.0:50075               0.0.0.0:*                   LISTEN      13638/java
tcp        0      0 0.0.0.0:50020               0.0.0.0:*                   LISTEN      13638/java
tcp        0      0 172.17.128.21:56929         172.17.128.20:9100          ESTABLISHED 13638/java
```

### ResourceManager

8088 web管理页面

```shell
[root@PZMG-WB10-VAS ~]# netstat -lanp |grep `ps aux |grep ResourceManager | grep -v grep | awk '{print $2}'` |grep -v unix
tcp        0      0 ::ffff:172.17.128.20:8088   :::*                        LISTEN      22792/java
tcp        0      0 ::ffff:172.17.128.20:8030   :::*                        LISTEN      22792/java
tcp        0      0 ::ffff:172.17.128.20:8031   :::*                        LISTEN      22792/java
tcp        0      0 ::ffff:172.17.128.20:8032   :::*                        LISTEN      22792/java
tcp        0      0 ::ffff:172.17.128.20:8033   :::*                        LISTEN      22792/java
tcp        0      0 ::ffff:172.17.128.20:8031   ::ffff:172.17.128.22:52887  ESTABLISHED 22792/java
tcp        0      0 ::ffff:172.17.128.20:8031   ::ffff:172.17.128.24:38544  ESTABLISHED 22792/java
tcp        0      0 ::ffff:172.17.128.20:8031   ::ffff:172.17.128.23:58167  ESTABLISHED 22792/java
tcp        0      0 ::ffff:172.17.128.20:8031   ::ffff:172.17.128.21:41407  ESTABLISHED 22792/java
tcp        0      0 ::ffff:172.17.128.20:8031   ::ffff:172.17.128.26:53584  ESTABLISHED 22792/java
tcp        0      0 ::ffff:172.17.128.20:8031   ::ffff:172.17.128.25:43478  ESTABLISHED 22792/java
```

### NodeManager

8042 web端口

```shell
[root@PZMG-WB11-VAS ~]# netstat -lanp |grep `ps aux |grep NodeManager | grep -v grep | awk '{print $2}'` |grep -v unix
tcp        0      0 :::51478                    :::*                        LISTEN      13765/java
tcp        0      0 :::13562                    :::*                        LISTEN      13765/java
tcp        0      0 :::8040                     :::*                        LISTEN      13765/java
tcp        0      0 :::8042                     :::*                        LISTEN      13765/java
tcp        0      0 ::ffff:172.17.128.21:41407  ::ffff:172.17.128.20:8031   ESTABLISHED 13765/java
```

### JobHistoryServer

19888 web端口

```shell
[root@PZMG-WB10-VAS ~]# netstat -lanp |grep `ps aux |grep JobHistoryServer | grep -v grep | awk '{print $2}'` |grep -v unix
tcp        0      0 172.17.128.20:19888         0.0.0.0:*                   LISTEN      95714/java
tcp        0      0 0.0.0.0:10033               0.0.0.0:*                   LISTEN      95714/java
tcp        0      0 172.17.128.20:10020         0.0.0.0:*                   LISTEN      95714/java
```

# 常见问题

1.    执行hdfs等命令时，提示找不到原生库。

WARN util.NativeCodeLoader: Unable to loadnative-hadoop library for your platform... using builtin-java classes whereapplicable

解决办法：I assume you're running Hadoop on 64bit CentOS. The reason you sawthat warning is the native Hadoop library *$HADOOP_HOME/lib/native/libhadoop.so.1.0.0* was actuallycompiled on 32 bit.

Anyway, it's just a warning, and won'timpact Hadoop's functionalities.

Here is the way if you do want to eliminatethis warning, download the source code of Hadoop and recompilelibhadoop.so.1.0.0 on 64bit system, then replace the 32bit one.

编译hadoop的命令：

mvn package -Dmaven.javadoc.skip=true-Pdist,native -DskipTests -Dtar

参考：

[hadoop-unable-to-load-native-hadoop-library-for-your-platform-error-on-centos](http://stackoverflow.com/questions/19943766/hadoop-unable-to-load-native-hadoop-library-for-your-platform-error-on-centos)

或者，从http://dl.bintray.com/sequenceiq/sequenceiq-bin/  下载，同一小版本的，将准备好的64位的lib包解压到已经安装好的hadoop安装目录的lib/native 和 lib目录下。


# next

# 参考

- [Hadoop 2.x常用端口及查看方法](http://www.cnblogs.com/jancco/p/4447756.html)
- [Hadoop-2.2.0集群安装配置实践](http://shiyanjun.cn/archives/561.html)
