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
# 第1个数字指的是要运行5次map任务
# 第2个数字指的是每个map任务，要投掷多少次
hadoop jar $HADOOP_HOME/hadoop-*-examples-*.jar pi 5 6
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
- [Hadoop-2.2.0集群安装配置实践](http://shiyanjun.cn/archives/561.html)
