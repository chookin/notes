[TOC]
# 概述
Mysql内建的复制功能是构建大型，高性能应用程序的基础。将Mysql的数据分布到多个系统上去，这种分布的机制，是通过将Mysql的某一台主机的数据复制到其它主机（slaves）上，并重新执行一遍来实现的。复制过程中一个服务器充当主服务器，而一个或多个其它服务器充当从服务器。主服务器将更新写入二进制日志文件，并维护文件的一个索引以跟踪日志循环。这些日志可以记录发送到从服务器的更新。当一个从服务器连接主服务器时，它通知主服务器从服务器在日志中读取的最后一次成功更新的位置。从服务器接收从那时起发生的任何更新，然后封锁并等待主服务器通知新的更新。

请注意当你进行复制时，所有对复制中的表的更新必须在主服务器上进行。否则，你必须要小心，以避免用户对主服务器上的表进行的更新与对从服务器上的表所进行的更新之间的冲突。
## mysql支持的复制类型：

1. 基于语句的复制：在主服务器上执行的SQL语句，在从服务器上执行同样的语句。MySQL默认采用基于语句的复制，效率比较高。一旦发现没法精确复制时，会自动选着基于行的复制。
2. 基于行的复制：把改变的内容复制过去，而不是把命令在从服务器上执行一遍. 从mysql5.0开始支持。
3. 混合类型的复制: 默认采用基于语句的复制，一旦发现基于语句的无法精确的复制时，就会采用基于行的复制。

## 复制解决的问题

MySQL复制技术有以下一些特点：

1. 数据分布 (Data distribution )
2. 负载平衡(load balancing)
3. 备份(Backups)
4. 高可用性和容错行 High availability and failover 

## 复制如何工作 

整体上来说，复制有3个步骤：

1. master将改变记录到二进制日志(binary log)中（这些记录叫做二进制日志事件，binary log events）；
2. slave将master的binary log events拷贝到它的中继日志(relay log)；
3. slave重做中继日志中的事件，将改变反映它自己的数据。

下图描述了复制的过程：

![mysql 主从配置](res/mysql-master-slave-bin-log-reply.jpg)

该过程的第一部分就是master记录二进制日志。在每个事务更新数据完成之前，master在二进制日志记录这些改变。MySQL将事务串行的写入二进制日志，即使事务中的语句都是交叉执行的。在事件写入二进制日志完成后，master通知存储引擎提交事务。

下一步就是slave将master的binary log拷贝到它自己的中继日志。首先，slave开始一个工作线程——I/O线程。I/O线程在master上打开一个普通的连接，然后开始binlog dump process。Binlog dump process从master的二进制日志中读取事件，如果已经跟上master，它会睡眠并等待master产生新的事件。I/O线程将这些事件写入中继日志。

SQL slave thread（SQL从线程）处理该过程的最后一步。SQL线程从中继日志读取事件，并重放其中的事件而更新slave的数据，使其与master中的数据一致。只要该线程与I/O线程保持一致，中继日志通常会位于OS的缓存中，所以中继日志的开销很小。

此外，在master中也有一个工作线程：和其它MySQL的连接一样，slave在master中打开一个连接也会使得master开始一个线程。复制过程有一个很重要的限制——复制在slave上是串行化的，也就是说master上的并行更新操作不能在slave上并行操作。
# 配置
## 在主库上建立同步帐户

1.在主服务器上设置一个从数据库的账户,使用`REPLICATION SLAVE`赋予权限,如：在主库上新增加一个名为slave的账户,其中`mysql_slave1`为从库的hostname。

```sql
mysql> grant replication slave on *.* to 'slave'@'lab51' identified by 'OC3ABgWVIEltoU9Y';
mysql> FLUSH PRIVILEGES;
```

2.查看主库上的用户帐户

```sql
mysql> select user,host,password from mysql.user;
```

## 配置master
1.对master进行配置，包括打开二进制日志，指定唯一的servr ID，并在修改配置后重启mysql.
```shell
# server-id为主服务器的ID值
server-id=1
# log-bin为二进制变更日值
log-bin=mysql-bin
```

2.查看主库信息

```sql
mysql> show master status;
+------------------+----------+--------------+------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB |
+------------------+----------+--------------+------------------+
| mysql-bin.000001 |     5328 |              |                  |
+------------------+----------+--------------+------------------+
1 row in set (0.00 sec)
```

如果结果为空，那么检查是否开启了开启二进制日志。

```sql
mysql> show variables like '%log_bin%';
+---------------------------------+-------+
| Variable_name                   | Value |
+---------------------------------+-------+
| log_bin                         | OFF   |
| log_bin_basename                |       |
| log_bin_index                   |       |
| log_bin_trust_function_creators | OFF   |
| log_bin_use_v1_row_events       | OFF   |
| sql_log_bin                     | ON    |
+---------------------------------+-------+
```

## 建立主库的数据库快照
现在可以停止主数据的的更新操作，并生成主数据库的备份。我们可以将数据文件复制到从数据库，也可以通过mysqldump导出数据到从数据库。

1.在导出数据之前先对主数据库进行READ LOCK，以保证数据的一致性。READ LOCK会阻塞写请求，但不会阻塞读请求。

```sql
mysql> flush tables with read lock;
```

2.创建mysql数据目录的快照

```shell
$ cd /data/work/ && tar zcvf /tmp/mysql-snapshot.tgz mysql
```

3.在主服务器上重新启用写活动
```sql
mysql> unlock tables;
```

## 配置从库
1.编译安装mysql数据库或者采用rsync同步主库的数据到从库。

```shell
$ cd /home/work/local # 进入到mysql安装目录的上级目录
$ rsync -av mysql node146:~/local/ --exclude=mysql/var/*
```

2.配置slave

```shell
# required unique id between 1 and 2^32 - 1
# (and different from the master)
server-id       = 2
# 配置中继日志，默认是$hostname-relay-bin，如果hostname改变则会出现问题
relay_log       = mysql-relay-bin
# log_slave_updates 表示 slave 将复制事件写进自己的二进制日志
log-slave-updates
# slave 没有必要开启二进制日志,但是在一些情况下,必须设置,例如,如果 slave 为其它 slave 的 master,必须设置 bin_log
#log_bin = mysql-bin
```

注意： server-id不能与主库相同。

3.测试从库是否能和主库相连接
```shell
$ bin/mysql --defaults-file=etc/my.cnf -h mysql_master -u slave -p -P23306
```
连接成功，下一步，开始同步主从数据库。

## 同步主从数据库
1.启动从数据库 

```shell
$ bin/mysqld_safe  --defaults-file=etc/my.cnf & 
```

2.和主数据库同步

登录从库

```sql
mysql>stop slave;
mysql>CHANGE MASTER TO MASTER_HOST='mysql_master', MASTER_PORT=23306, MASTER_USER='slave', MASTER_PASSWORD='OC3ABgWVIEltoU9Y';
mysql>start slave;
```

3.检测同步状态

```sql
mysql> show slave status\G;
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: mysql_master
                  Master_User: slave
                  Master_Port: 23306
                Connect_Retry: 60
              Master_Log_File: mysql-bin.000001
          Read_Master_Log_Pos: 107
               Relay_Log_File: mysql-relay-bin.000003
                Relay_Log_Pos: 253
        Relay_Master_Log_File: mysql-bin.000001
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
              Replicate_Do_DB: 
          Replicate_Ignore_DB: 
           Replicate_Do_Table: 
       Replicate_Ignore_Table: 
      Replicate_Wild_Do_Table: 
  Replicate_Wild_Ignore_Table: 
                   Last_Errno: 0
                   Last_Error: 
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 107
              Relay_Log_Space: 409
              Until_Condition: None
               Until_Log_File: 
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File: 
           Master_SSL_CA_Path: 
              Master_SSL_Cert: 
            Master_SSL_Cipher: 
               Master_SSL_Key: 
        Seconds_Behind_Master: 0
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error: 
               Last_SQL_Errno: 0
               Last_SQL_Error: 
  Replicate_Ignore_Server_Ids: 
             Master_Server_Id: 1
```

`Slave_IO_Running`和`Slave_SQL_Running`均是`yes`表明slave的两个同步线程状态正常。
此时，可以在我们的主服务器做一些更新的操作,然后在从服务器查看是否已经更新

## 其他
### 查看master和slave上线程的状态
在master上，可以看到slave的I/O线程创建的连接：
```sql
mysql> show processlist\G;
*************************** 8. row ***************************
     Id: 330
   User: slave
   Host: lab51:53111
     db: NULL
Command: Binlog Dump
   Time: 104
  State: Master has sent all binlog to slave; waiting for binlog to be updated
   Info: NULL
```
行8为处理slave的I/O线程的连接。

在slave服务器上运行该语句：
```sql
mysql> show processlist\G;
*************************** 3. row ***************************
     Id: 7
   User: system user
   Host: 
     db: NULL
Command: Connect
   Time: 273
  State: Waiting for master to send event
   Info: NULL
*************************** 4. row ***************************
     Id: 8
   User: system user
   Host: 
     db: NULL
Command: Connect
   Time: 267
  State: Slave has read all relay log; waiting for the slave I/O thread to update it
   Info: NULL
```

行3为I/O线程状态，行4为SQL线程状态。

## 常见问题
1）在slave机器上执行`show slave status\G;`报错

```sql
mysql> show slave status\G;
…
Last_IO_Error: Fatal error: The slave I/O thread stops because master and slave have equal MySQL server UUIDs; these UUIDs must be different for replication to work.
```

问题原因，拷贝整个data目录，把auto.cnf文件也拷贝过来了，里面记录了数据库的uuid，每个库的uuid应该是不一样的。因此，修改该值为其他数据即可。

2) 在slave机器上执行show slave status\G；报错

```
mysql> show slave status\G;
…
Last_Errno: 1062
Last_Error: Error 'Duplicate entry '%-test-' for key 'PRIMARY'' on query. Default database: 'mysql'. Query: 'INSERT INTO db SELECT * FROM tmp_db WHERE @had_db_table=0;'
```
解决办法：分别登录主库和从库的mysql，执行如下命令。

```
# in both nodes
STOP SLAVE;
RESET MASTER;
RESET SLAVE;
# on slave node
start slave;
```


