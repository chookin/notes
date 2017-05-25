# [spark](http://spark.apache.org)

下载 http://spark.apache.org/downloads.html

## ssh无密码访问

**配置ssh使得服务器A的用户user_a1可以无密码访问服务器B的用户user_b1**

操作：
1）在A服务器的用户user_a1上执行如下命令，将在.ssh路径下自动生成id_rsa.pub文件

```shell
cd && ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && chmod 700 ~/.ssh
```

2）配置B服务器
登录B服务器的用户user_b1。
如果路径~/.ssh/不存在，则执行命令

```shell
cd && ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && chmod 700 ~/.ssh
```

拷贝步骤1生成的`id_rsa.pub`文件内容并追加到服务器B的`.ssh/authorized_keys`文件中（如果`.ssh/authorized_keys`不存在，创建之），其中拷贝命令示例：

```shell
rsync -av root@cm03:/home/yimr/.ssh/id_rsa.pub ~/.ssh/id_rsa.pub.cm03
```

然后执行如下命令

```shell
chmod 600 $HOME/.ssh/authorized_keys;
```

如果步骤1生成的id_rsa.pub文件内容是以hostname结尾，那么还需要把服务器A的ip与hostname配置到服务器B的/etc/hosts文件中。

3）测试A对B的访问

在A上执行

```shell
ssh user_b1@hostname_B -v
```

如果可以成功访问，OK

## 配置

### 数据文件夹

数据放在`/data/spark`路径下。若`/home`磁盘分区空间较大，则可以使用软链接的方式做映射。

```shell
mkdir -p /home/data/spark
chown -R hadoop.hadoop /home/data/spark
ln -s /home/data/spark /data/spark
```

### spark-env.sh

```shell
export SPARK_MASTER_IP=sparkmaster

export SPARK_WORKER_CORES=4
export SPARK_WORKER_MEMORY=24g
export SPARK_WORKER_DIR=/data/spark/worker
export SPARK_PID_DIR=/data/spark/var
export SPARK_LOG_DIR=/data/spark/logs
# restrict only one instance on a slave
export SPARK_EXECUTOR_INSTANCES=1
# restrict work port
export SPARK_WORKER_PORT=8082

# defautl is 7077
export SPARK_MASTER_PORT=7077

# defaut is 8081
export SPARK_WORKER_WEBUI_PORT=8081
```

SPARK_WORKER_PORT 端口限定之前

```
17/03/06 16:23:07 INFO Utils: Successfully started service 'sparkWorker' on port 44190.
17/03/06 16:23:08 INFO Worker: Starting Spark worker 172.17.128.25:44190 with 4 cores, 24.0 GB RAM
```

限定之后

```
17/03/07 17:34:21 INFO Utils: Successfully started service 'sparkWorker' on port 8082.
17/03/07 17:34:21 INFO Worker: Starting Spark worker 172.17.128.25:8082 with 4 cores, 24.0 GB RAM
```

### spark-defaults.conf

限定具体端口

```conf
spark.driver.port 8083
```

端口限定之前

```
17/03/07 16:43:22 INFO ExecutorRunner: Launch command: "/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.45.x86_64/jre/bin/java" "-cp" "/home/hadoop/local/spark/conf/:/home/hadoop/local/sp
ark/jars/*" "-Xmx1024M" "-Dspark.driver.port=33791" "-XX:MaxPermSize=256m" "org.apache.spark.executor.CoarseGrainedExecutorBackend" "--driver-url" "spark://CoarseGrainedSchedule
r@172.17.128.26:33791" "--executor-id" "1" "--hostname" "172.17.128.25" "--cores" "4" "--app-id" "app-20170307164325-0000" "--worker-url" "spark://Worker@172.17.128.25:48767"
```

限定之后

```
17/03/07 17:34:37 INFO ExecutorRunner: Launch command: "/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.45.x86_64/jre/bin/java" "-cp" "/home/hadoop/local/spark/conf/:/home/hadoop/local/sp
ark/jars/*" "-Xmx1024M" "-Dspark.driver.port=8083" "-XX:MaxPermSize=256m" "org.apache.spark.executor.CoarseGrainedExecutorBackend" "--driver-url" "spark://CoarseGrainedScheduler
@172.17.128.24:8083" "--executor-id" "1" "--hostname" "172.17.128.25" "--cores" "4" "--app-id" "app-20170307173440-0000" "--worker-url" "spark://Worker@172.17.128.25:8082"
```

### slaves

配置从节点，例如

```
cm14
cm15
cm16
```

### log4j.properties

```ini
log4j.rootCategory=INFO, console
log4j.appender.console=org.apache.log4j.ConsoleAppender
log4j.appender.console.target=System.err
log4j.appender.console.layout=org.apache.log4j.PatternLayout
log4j.appender.console.layout.ConversionPattern=%d{yy/MM/dd HH:mm:ss} %p %c{1}: %m%n

log4j.logger.org.eclipse.jetty=WARN
log4j.logger.org.eclipse.jetty.util.component.AbstractLifeCycle=ERROR
log4j.logger.org.apache.spark.repl.SparkIMain$exprTyper=INFO
log4j.logger.org.apache.spark.repl.SparkILoop$SparkILoopInterpreter=INFO
```

### 环境变量

```shell
# 在环境变量文件中配置SPARK_CONF_DIR不一定完全有效
#export SPARK_HOME=/home/yimr/local/spark
#export SPARK_CONF_DIR=/home/yimr/local/spark/conf
#export SPARK_LOG_DIR=/data/spark/logs

export SPARK_HOME=$HOME/local/spark
export PATH=$PATH:$SPARK_HOME/bin

export LD_LIBRARY_PATH=/home/work/local/mysql/lib:$LD_LIBRARY_PATH
```

## 启动

```shell
./start-master.sh
./start-slaves.sh
```

http://stackoverflow.com/questions/29936821/starting-a-single-spark-slave-or-worker
> I'm using spark 1.6.1, and you no longer need to indicate a worker number, so the actual usage is:

```shell
start-slave.sh spark://<master>:<port>
```

## 测试

```shell
spark-submit --class org.apache.spark.examples.SparkPi --master spark://sparkmaster:7077 $HOME/local/spark/examples/jars/spark-examples*.jar 10

spark-submit --class org.apache.spark.examples.SparkPi --master yarn $HOME/local/spark/examples/jars/spark-examples*.jar 10spark-submit --class org.apache.spark.examples.SparkPi --master yarn $HOME/local/spark/examples/jars/spark-examples*.jar 10
```

# 运维

## 端口

### master

8080 web端口

```shell
[root@PZMG-WB14-VAS ~]# netstat -lanp |grep `ps aux |grep spark |grep master | grep -v grep | awk '{print $2}'` |grep -v unix
tcp        0      0 :::8080                     :::*                        LISTEN      11959/java
tcp        0      0 ::ffff:172.17.128.24:6066   :::*                        LISTEN      11959/java
tcp        0      0 ::ffff:172.17.128.24:7077   :::*                        LISTEN      11959/java
tcp        0      0 ::ffff:172.17.128.24:7077   ::ffff:172.17.128.26:43139  ESTABLISHED 11959/java
tcp        0      0 ::ffff:172.17.128.24:7077   ::ffff:172.17.128.24:60547  ESTABLISHED 11959/java
tcp        0      0 ::ffff:172.17.128.24:7077   ::ffff:172.17.128.25:48194  ESTABLISHED 11959/java
```

### worker

8081 web端口

```shell
[root@PZMG-WB14-VAS ~]# netstat -lanp |grep `ps aux |grep spark |grep worker | grep -v grep | awk '{print $2}'` |grep -v unix
tcp        0      0 :::8081                     :::*                        LISTEN      12054/java
tcp        0      0 ::ffff:172.17.128.24:56452  :::*                        LISTEN      12054/java
tcp        0      0 ::ffff:172.17.128.24:60547  ::ffff:172.17.128.24:7077   ESTABLISHED 12054/java
```



# 参考

- [第35课Spark Master、Worker、Driver、Executor工作流程详解](http://blog.csdn.net/zhumr/article/details/52518506)
