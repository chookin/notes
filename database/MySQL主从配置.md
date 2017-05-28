[TOC]
# 概述
MySQL内建的复制功能是构建大型，高性能应用程序的基础。将Mysql的数据分布到多个系统上去，这种分布的机制，是通过将Mysql的某一台主机的数据复制到其它主机（slaves）上，并重新执行一遍来实现的。复制过程中一个服务器充当主服务器，而一个或多个其它服务器充当从服务器。主服务器将更新写入二进制日志文件，并维护文件的一个索引以跟踪日志循环。这些日志可以记录发送到从服务器的更新。当一个从服务器连接主服务器时，它通知主服务器从服务器在日志中读取的最后一次成功更新的位置。从服务器接收从那时起发生的任何更新，然后封锁并等待主服务器通知新的更新。

请注意当进行复制时，所有对复制中的表的**更新必须在主服务器上进行**，以避免用户对主服务器上的表进行的更新与对从服务器上的表所进行的更新之间的冲突。
## 复制解决的问题

MySQL复制技术有以下一些特点：

1. 负载平衡(load balancing)，提高系统读写性能；
2. 数据备份(Backups)；
3. 高可用性和容错行 High availability and failover 。

## 复制如何工作 

整体上来说，复制有3个步骤：

1）**master将改变记录到二进制日志文件**(binary log)中（这些记录叫做二进制日志事件，binary log events）；

2）**slave将master的binary log events拷贝到它的中继日志**(relay log)；
1. Slave 上面的IO线程连接上 Master，并请求从指定日志文件的指定位置(或者从最开始的日志)之后的日志内容;
2. Master 接收到来自 Slave 的 IO 线程的请求后，通过负责复制的 IO 线程根据请求信息读取指定日志指定位置之后的日志信息，返回给 Slave 端的 IO 线程。返回信息中除了日志所包含的信息之外，还包括本次返回的信息在 Master 端的 Binary Log 文件的名称以及在 Binary Log 中的位置;
3. Slave 的 IO 线程接收到信息后，将接收到的日志内容依次写入到 Slave 端的Relay Log文件(mysql-relay-bin.xxxxxx)的最末端，并将读取到的Master端的bin-log的文件名和位置记录到 master-info 文件中，以便在下一次读取的时候能够清楚的高速Master“我需要从某个bin-log的哪个位置开始往后的日志内容，请发给我”

3）**slave重做中继日志中的事件**，将改变反映它自己的数据。
1. Slave 的 SQL 线程检测到 Relay Log 中新增加了内容后，会马上解析该 Log 文件中的内容并在自身执行。这样，实际上就是在 Master 端和 Slave 端执行了同样的操作，所以两端的数据是完全一样的。

下图描述了复制的过程：

![mysql 主从配置](res/mysql-master-slave-bin-log-reply.jpg)

该过程的第一部分就是master记录二进制日志。在每个事务更新数据完成之前，master在二进制日志记录这些改变。在事件写入二进制日志完成后，master通知存储引擎提交事务。

下一步就是slave将master的binary log拷贝到它自己的中继日志。首先，slave开始一个工作线程——I/O线程。I/O线程在master上打开一个普通的连接，然后开始`binlog dump process`。`Binlog dump process`从master的二进制日志中读取事件，如果已经跟上master，它会睡眠并等待master产生新的事件。I/O线程将这些事件写入中继日志。

SQL slave thread（SQL从线程）处理该过程的最后一步。SQL线程从中继日志读取事件，并重放其中的事件而更新slave的数据，使其与master中的数据一致。中继日志通常会位于OS的缓存中，所以中继日志的开销很小。

此外，在master中也有一个工作线程：和其它MySQL的连接一样，**slave在master中打开一个连接也会使得master开始一个线程**。复制过程有一个很重要的限制——复制在slave上是串行化的，也就是说master上的并行更新操作不能在slave上并行操作。
# 搭建主从复制集群
## 在主库上建立同步帐户

1）在主服务器上设置一个从数据库的账户,使用`REPLICATION SLAVE`赋予权限，如：在主库上新增加一个名为slave的账户,其中`mysql_slave1`为从库的hostname。

```sql
mysql> grant replication slave on *.* to 'slave'@'mysql_slave1' identified by 'OC3ABgWVIEltoU9Y';
mysql> FLUSH PRIVILEGES;
```

> 注：出于安全性和灵活性的考虑，不要把root等具有SUPER权限用户作为复制账号。

2）查看主库上的用户帐户

```sql
mysql> select user,host,password from mysql.user;
```

## 配置master
1）对master进行配置，包括打开二进制日志，指定唯一的servr ID，并在修改后重启mysql.

```shell
server-id                       = 51
log-bin                         = mysql-bin
binlog_format                   = mixed
sync_binlog                     = 1
innodb_flush_log_at_trx_commit  = 1
innodb_support_xa               = true
```

参数：

- `server-id` 需要是唯一的，建议配置为IP最后一段；
- `log-bin`配置binlog日志文件名；
- `binlog_format `配置binlog日志文件格式，有 3 种不同的格式可选：Mixed,Statement,Row，默认格式是 Statement，该配置决定了mysql的复制类型；
- `sys_binlog`配置binlog刷写到磁盘的频次；
- `innodb_flush_log_at_trx_commit`配置redo log刷写到磁盘的频次；
- `innodb_support_xa`配置是否启用InnoDB的XA两段式事务提交；
- `auto-increment-increment`和`auto-increment-offset`是为了支持双主而设置的，在只做主从的时候可以不设置。
- `binlog-do-db` 配置需要把哪些数据库的改变记录到binary日志中。
- `binlog-ignore-db` 配置需要忽略的数据库。

mysql支持的复制类型：

1. 基于语句的复制：在主服务器上执行的SQL语句，在从服务器上执行同样的语句。MySQL默认采用基于语句的复制，效率比较高。一旦发现没法精确复制时，会自动选着基于行的复制。
2. 基于行的复制：把改变的内容复制过去，而不是把命令在从服务器上执行一遍. 从mysql5.0开始支持。
3. 混合类型的复制: 默认采用基于语句的复制，一旦发现基于语句的无法精确的复制时，就会采用基于行的复制。

> 注：一定要保证主从服务器各自的server_id唯一，避免冲突。

## 建立主库的数据库快照

现在可以停止主数据的的更新操作，并生成主数据库的备份。我们可以将数据文件复制到从数据库，也可以通过mysqldump导出数据到从数据库。如果数据量很大的话，mysqldump会非常慢，此时直接拷贝数据文件能节省不少时间

1）在导出数据之前先对主数据库进行`READ LOCK`，然后再获得相关的日志信息（File & Position）。`READ LOCK`将导致binlog、数据文件立即刷新磁盘，且阻止writes操作提交。

```sql
--删除所有index file中记录的所有binlog 文件，将日志索引文件清空，创建一个新的日志文件，该命令通常仅用于第一次搭建主从关系时的主库
mysql> RESET MASTER;

mysql> flush tables with read lock;
```

2）查看主库信息

```sql
mysql> show master status;
+------------------+----------+--------------+------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB |
+------------------+----------+--------------+------------------+
| mysql-bin.000001 |     5328 |              |                  |
+------------------+----------+--------------+------------------+
1 row in set (0.00 sec)
```

**该status表明了正在记录的 binlog文件名及文件偏移量（请记住这两个参数，配置slave时需使用）**。其中，

- Binlog_Do_DB和Binlog_Ignore_DB是在配置文件中配置的。


- Master 重启后会修改mysql-bin（文件名序号加1）

如果结果为空，那么检查是否开启了开启二进制日志。

```sql
mysql> show variables like '%log_bin%';
+---------------------------------+-------+
| Variable_name                   | Value |
+---------------------------------+-------+
| log_bin                         | ON    |
| log_bin_trust_function_creators | OFF   |
| sql_log_bin                     | ON    |
+---------------------------------+-------+
3 rows in set (0.00 sec)
```

3）创建mysql数据目录的快照，或者直接同步数据文件夹到从库服务器

```shell
$ cd /data/work/ && tar zcvf /tmp/mysql-snapshot.tgz mysql
```

4）上述步骤执行完毕后，在主库上取消读锁。

```sql
mysql> unlock tables;
```

## 配置从库
1）在从库服务器上安装mysql，并配置从主库拷贝过来的数据文件到从库数据目录

2）配置slave

```shell
server-id       = 52
relay_log       = mysql-relay-bin
# log-slave-updates
# log_bin = s-mysql-bin
read-only
skip-slave-start
# replicate-do-db=db1
# replicate-do-db=db2
# replicate-ignore-db=mysql
```

参数说明：

- relay_log 配置中继日志的文件名，**默认是`${hostname}-relay-bin`**，如果`hostname`改变则会出现问题；
- relay-log-index 保存relay log文件名的文件.
- log-slave-updates **用来配置从库从主库获得的更新是否写入log-bin二进制日志**，这个选项默认是不打开的，但是，如果这个从服务器B是服务器A的从服务器，同时还作为服务器C的主服务器，那么就需要开发这个选项，这样它的从服务器C才能获得它的二进制日志；
- log-bin 配置是否写二进制日志，从库没有必要开启二进制日志,但是在一些情况下则必须设置，如若该从库为其它从库的主库；
- master-connect-retry 设置在和主服务器连接丢失的时候，重试的时间间隔，默认是60秒；
- skip-slave-start 防止从库复制机制随着mysql启动而自动启动。即slave端的mysql服务重启后需手动来启动主从复制（slave start）；
- read-only 用来限制普通用户对从数据库的更新操作，以确保从数据库的安全性；超级用户依然可以对从数据库进行更新操作；
- slave-skip-errors 用来定义复制过程中从服务器可以自动跳过的错误号，当复制过程中遇到定义的错误号，就可以自动跳过，直接执行后面的SQL语句；
- replicate-do-db 配置需同步的数据库,多个DB用逗号分隔
- replicate-ignore-db 配置忽略同步的数据库
- Replicate_Do_Table:设定需要复制的Table
- Replicate_Ignore_Table:设定可以忽略的Table
- Replicate_Wild_Do_Table:功能同Replicate_Do_Table,但可以带通配符来进行设置。
- Replicate_Wild_Ignore_Table:功能同Replicate_Do_Table,功能同Replicate_Ignore_Table,可以带通配符。

3）测试从库是否能和主库相连接
```shell
$ bin/mysql --defaults-file=etc/my.cnf -h mysql_master -u slave -p -P23306
```
若连接成功，则进入下一步，在从库上启动主从数据同步。

## 在从库上启动主从数据同步
1）启动从库 

```shell
$ bin/mysqld_safe  --defaults-file=etc/my.cnf & 
```

2）和主数据库同步

用`change master to`命令中的两个参数指定binlog复制的开始位置，即：`master_log_file`和`master_log_pos`.

```sql
mysql> stop slave;
mysql> RESET SLAVE;
mysql> CHANGE MASTER TO MASTER_HOST='mysql_master', MASTER_PORT=23306, MASTER_USER='slave', MASTER_PASSWORD='OC3ABgWVIEltoU9Y',MASTER_LOG_FILE='mysql-bin.000001', MASTER_LOG_POS=5328;
mysql> start slave;
```

`CHANGE MASTER`的语法如下：

```sql
CHANGE MASTER TO
       MASTER_HOST='<MASTER_HOST>',
       MASTER_USER='<SLAVE_USER>',
       MASTER_PASSWORD='<SLAVE_PASSWORD>',
       MASTER_LOG_FILE='<File>',
       MASTER_LOG_POS=<Position>;
```



3）查看同步状态

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

**`Slave_IO_Running`和`Slave_SQL_Running`均是`yes`表明slave的两个同步线程状态正常**。

## 常见问题
> 1）在slave机器上执行`show slave status\G;`报错

```sql
mysql> show slave status\G;
…
Last_IO_Error: Fatal error: The slave I/O thread stops because master and slave have equal MySQL server UUIDs; these UUIDs must be different for replication to work.
```

问题原因，拷贝整个data目录，把auto.cnf文件也拷贝过来了，里面记录了数据库的uuid，每个库的uuid应该是不一样的。因此，修改该值为其他数据即可。

> 2) 在slave机器上执行`show slave status\G;`报错

```
mysql> show slave status\G;
…
Last_Errno: 1062
Last_Error: Error 'Duplicate entry '%-test-' for key 'PRIMARY'' on query. Default database: 'mysql'. Query: 'INSERT INTO db SELECT * FROM tmp_db WHERE @had_db_table=0;'
```
办法一，分别登录主库和从库的mysql，执行如下命令：

```
# in both nodes
STOP SLAVE;
RESET MASTER;
RESET SLAVE;
# on slave node
start slave;
```

办法二：根据错误提示，判断问题原因是什么，并在从库上进行必要的增删改。

办法三：在从服务器使用SET GLOBAL sql_slave_skip_counter，如下：

```sql
stop slave;
SET GLOBAL sql_slave_skip_counter = 1;
START SLAVE;
```

注：如果有多个错误，可能需要执行多次（提醒：主从服务器数据可能因此不一致，遇到这样的情况可以使用[pt-table-checksum](http://www.percona.com/doc/percona-toolkit/pt-table-checksum.html)和[pt-table-sync](http://www.percona.com/doc/percona-toolkit/pt-table-sync.html)检查并修复从服务器数据）。

> 3) 使用系统自带的mysql，将其配置为从库时出错，Slave_IO_Running显示为connecting, 并有报错Last_IO_Errno: 2003，查看mysql的错误日志没有发现有价值的信息，查看系统日志/var/log/message，发现大堆报错

```
May 18 13:47:17 dcp kernel: type=1400 audit(1463550437.584:105): avc:  denied  { name_connect } for  pid=15433 comm="mysqld" dest=23306 scontext=unconfined_u:system_r:
mysqld_t:s0 tcontext=system_u:object_r:port_t:s0 tclass=tcp_socket
```
该问题原因是`selinux`。把它禁用即可。

禁用`selinux`

- `setenforce 0` 可以临时关闭


- 编辑文件`/etc/sysconfig/selinux`把里边的一行改为`SELINUX=disabled`，则系统重启后是是禁用的。

参考：

- [SELinux and MySQL](https://blogs.oracle.com/jsmyth/entry/selinux_and_mysql?utm_source=tuicool&utm_medium=referral)


# 克隆slave

**当需要增加slave节点时，如果已经有一个Slave连在Master上，则可使用这个Slave创建新的Slave，而不需要离线Master**。
与克隆Master基本相同，主要区别在于如何找到binlog位置。
在备份前停止源Slave的 Save IO 及SQL线程，保证源Slave暂时不会从主库同步数据，否则会产生不一致的备份镜像。
但是如果使用某种在线备份方法，如InnoDB Hot Backup，则不需要在创建备份前停止源Slave。

## 锁定源Slave数据库并查看状态

```sql
--停止Slave
stop slave;
--锁定数据库
flush tables with read lock;
--查看Slave数据库状态
show slave status\G;
```

查看从库状态时，记住这两个参数的值

- `Relay_Master_Log_File`， 如master-bin.000004
- `Exec_Master_Log_Pos`，如2958

## 拷贝数据

拷贝数据到新建slave节点；

## 解锁源slave

```sql
unlock tables;
```

## 在新的slave配置并启动

- 测试与主库的连接

```shell
mysql -u slave -p -h mysql_master -P23306
```

- 配置新的slave

```shell
server-id       = 53
relay_log       = mysql-relay-bin
read-only
skip-slave-start
```

- 启动新的slave数据库

```shell
bin/mysqld_safe  --defaults-file=etc/my.cnf & 
```

- 登录新的slave数据库并配置复制

```sql
CHANGE MASTER TO
	   MASTER_HOST='<MASTER_HOST>',
	   MASTER_PORT=<MASTER_PORT>
       MASTER_USER='<SLAVE_USER>',
       MASTER_PASSWORD='<SLAVE_PASSWORD>',
       MASTER_LOG_FILE='<Relay_Master_Log_File>',
       MASTER_LOG_POS=<Exec_Master_Log_Pos>;
```

- 启动slave复制并查看状态

```sql
start slave;
show slave status\G;
```

如果IO线程和SQL线程都显示Yes，就可以了：

- `Slave_IO_Running`: Yes
- `Slave_SQL_Running`: Yes

# 主从同步的管理

## 状态监控
### 查看主库状态
```sql
mysql> show slave hosts;
+-----------+------+-------+-----------+
| Server_id | Host | Port  | Master_id |
+-----------+------+-------+-----------+
|         2 |      | 23306 |         1 |
+-----------+------+-------+-----------+
```

### 查看从库状态

#### 命令

```sql
mysql> show slave status\G;
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: mysql_master
                  Master_User: slave
                  Master_Port: 23306
                Connect_Retry: 60
              Master_Log_File: mysql-bin.000011
          Read_Master_Log_Pos: 808436349
               Relay_Log_File: mysql-relay-bin.000046
                Relay_Log_Pos: 808436495
        Relay_Master_Log_File: mysql-bin.000011
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
              Replicate_Do_DB: 
          Replicate_Ignore_DB: mysql
           Replicate_Do_Table: 
       Replicate_Ignore_Table: 
      Replicate_Wild_Do_Table: 
  Replicate_Wild_Ignore_Table: 
                   Last_Errno: 0
                   Last_Error: 
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 808436349
              Relay_Log_Space: 808436694
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
1 row in set (0.00 sec)
```

#### 参数

- Slave_IO_State：等待 master 发生事件
- Master_Host：当前的主服务器主机
- Master_User：被用于连接主服务器的当前用户
- Master_Port：当前的主服务器接口
- Connect_Retry：master-connect-retry选项的当前值
- **Master_Log_File：I/O线程当前正在读取的主服务器二进制日志文件的名称**
- **Read_Master_Log_Pos：在当前的主服务器二进制日志中，I/O线程已经读取的位置**
- **Relay_Log_File：SQL线程当前正在读取和执行的中继日志文件的名称**
- **Relay_Log_Pos：在当前的中继日志中，SQL线程已读取和执行的位置**
- **Relay_Master_Log_File：SQL线程正在处理的二进制日志文件的名称**
- Slave_IO_Running：I/O线程是否被启动并成功地连接到主服务器上
- Slave_SQL_Running：SQL线程是否被启动
- Replicate_Do_DB：replicate-do-db选项的当前值
- Replicate_Ignore_DB：replicate-ignore-db选项的当前值
- Replicate_Do_Table：replicate-do-table选项的当前值
- Replicate_Ignore_Table：replicate-ignore-table选项的当前值
- Replicate_Wild_Do_Table：replicate-wild-do-table选项的当前值
- Replicate_Wild_Ignore_Table：replicate-wild-ignore_table选项的当前值
- Last_Errno：最近一次错误码
- Last_Error：最近一次错误内容
- Skip_Counter：最近被使用的用于SQL_SLAVE_SKIP_COUNTER的值
- Exec_Master_Log_Pos：来自主服务器的二进制日志的由SQL线程执行的上一个时间的位置（`Relay_Master_Log_File`）。在主服务器的二进制日志中的(`Relay_Master_Log_File`,`Exec_Master_Log_Pos`)对应于在中继日志中的(`Relay_Log_File`,`Relay_Log_Pos`)
- Relay_Log_Space：所有原有的中继日志结合起来的总大小
- Until_Condition：如果没有指定UNTIL子句，则没有值。如果从属服务器正在读取，直到达到主服务器的二进制日志的给定位置为止，则值为Master。如果从属服务器正在读取，直到达到其中继日志的给定位置为止，则值为Relay
- Until_Log_File：用于指示日志文件名，日志文件名和位置值定义了SQL线程在哪个点中止执行
- Until_Log_Pos：用于指示日志位置值，日志文件名和位置值定义了SQL线程在哪个点中止执行
- Master_SSL_Allowed：如果允许对主服务器进行SSL连接，则值为Yes。如果不允许对主服务器进行SSL连接，则值为No。如果允许SSL连接，但是从属服务器没有让SSL支持被启用，则值为Ignored。
- Master_SSL_CA_File：master-ca选项的当前值
- Master_SSL_CA_Path：master-capath选项的当前值
- Master_SSL_Cert：master-cert选项的当前值
- Master_SSL_Cipher：master-cipher选项的当前值
- Master_SSL_Key：master-key选项的当前值
- Seconds_Behind_Master表示slave上SQL thread与IO thread之间的延迟。

#### 注意

Seconds_Behind_Master表示slave上SQL thread与IO thread之间的延迟。MySQL的复制环境中，slave先从master上将binlog拉取到本地（通过IO thread），然后通过SQL thread将binlog重放，而Seconds_Behind_Master表示本地relaylog中未被执行完的那部分的差值。手册上的定义：

> In essence, this field measures the time difference in seconds between the slave SQL thread and the slave I/O thread. [show-slave-status](https://dev.mysql.com/doc/refman/5.6/en/show-slave-status.html)

- [MySQL slave状态之Seconds_Behind_Master](http://blog.csdn.net/zbszhangbosen/article/details/8494921)

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
## 从库同步启停
1) 停止MYSQL同步

```sql
STOP SLAVE IO_THREAD;    --停止IO进程
STOP SLAVE SQL_THREAD;   --停止SQL进程
STOP SLAVE;              --停止IO和SQL进程
```

2) 启动MYSQL同步

```sql
START SLAVE IO_THREAD;   --启动IO进程
START SLAVE SQL_THREAD;  --启动SQL进程
START SLAVE;             --启动IO和SQL进程
```

3) 重置MYSQL同步

[reset slave](https://dev.mysql.com/doc/refman/5.6/en/reset-slave.html)将使slave 忘记主从复制关系的位置信息。该语句将被用于干净的启动, 它删除master.info文件和relay-log.info 文件以及所有的relay log 文件并重新启用一个新的relaylog文件。
使用`reset slave`之前必须使用`stop slave` 命令将复制线程停止。

```sql
RESET SLAVE;
```

## 故障切换
### slave同步状态检测及主从切换
检测 show slave status 中的 "Seconds_Behind_Master","Slave_IO_Running","Slave_SQL_Running" 三个字段来确定当前主从同步的状态及 Seconds_Behind_Master 主从复制时延。当Seconds_Behind_Master的值超过某一阈值时,读写分离筛选器需过滤掉该Slave机器,防止过时的旧数据。

## 主从复制监测及管理工具

1) pt-heartbeat通过使用时间戳方式在主库上更新特定表，然后在从库上读取被更新的时间戳然后与本地系统时间对比来得出其延迟。

参考

- [5 free handy tools for monitoring and managing MySQL replication](https://www.percona.com/blog/2015/03/09/5-free-handy-tools-for-monitoring-and-managing-mysql-replication/)

## 性能提升
为了提升查询性能,有人创新的设计了一种 MySQL 主从复制模式,主节点为 InnoDB 引擎,读节点为 MyISAM 引擎,经过实践,发现查询性能提升不少。
此外,为了减少主从复制的时延,也建议采用 MySQL 5.6+的版本,用 GTID 同步复制方式减少复制的时延,可以将一个 Database 中的表，根据写频率的不同，分成几个数据库，这样就可以多库并发复制，注意的是，有join关系的表需放在一个库中。

# 其他

## 确保max_binlog_cache_size参数一致

max_binlog_cache_size 表示的是binlog 能够使用的最大cache 内存大小

当我们执行多语句事务的时候 所有session的使用的内存超过max_binlog_cache_size的值时

就会报错：“Multi-statement transaction required more than 'max_binlog_cache_size' bytes ofstorage”

max_binlog_cache_size在主从参数设置一样的情况下，主库执行大事务操作，如主库提示需提高该参数以顺利执行SQL，但DBA只调整了主库的max_binlog_cache_size而忘记调整从库的max_binlog_cache_size，则同样从库会爆出1197错误，导致主从不同步。

个人推荐值为4G，基本已经足够应付大部分场合，但无论是否指定该值，在对大表进行操作时，都需注意上述的警告内容，避免该值设置不合理引起从库无法执行报1197的问题。具体命令如下：

set global max_binlog_cache_size =4294967296;

**该值为动态参数，可以随时利用上述命令进行调整，所以别忘记将该参数加入到my.cnf中以防止重启数据库后失效。**

 [一个参数引起的mysql从库宕机血案](http://suifu.blog.51cto.com/9167728/1859252?b1)

# 参考

- [高性能Mysql主从架构的复制原理及配置详解](http://blog.csdn.net/hguisu/article/details/7325124/)
- [CHANGE MASTER TO Syntax](http://dev.mysql.com/doc/refman/5.5/en/change-master-to.html)
- [how to re-sync the Mysql DB if Master and slave have different database incase of Mysql replication?](http://stackoverflow.com/questions/2366018/how-to-re-sync-the-mysql-db-if-master-and-slave-have-different-database-incase-o)
- [MySQL学习笔记--复制建立新Slave的方法：克隆Master\Slave](http://blog.csdn.net/lichangzai/article/details/50440328)
- [MySQL复制的概述、安装、故障、技巧、工具](http://huoding.com/2011/04/05/59)
- [为什么mysql的binlog-do-db选项是危险的](http://coolnull.com/3145.html)
- [Binary Logging Options and Variables](http://dev.mysql.com/doc/refman/5.7/en/replication-options-binary-log.html)
- [Mycat权威指南v1.6.0](http://www.mycat.org.cn)
