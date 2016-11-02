[TOC]

# mysql启停

```shell
# 初始化数据库
scripts/mysql_install_db --defaults-file=etc/my.cnf

# 启动，需确保相应的端口和socket没有被占用
bin/mysqld_safe  --defaults-file=etc/my.cnf &

# 初始化root密码，需要mysql已启动
bin/mysqladmin --defaults-file=etc/my.cnf -u root password
# 修改root密码
bin/mysqladmin --defaults-file=etc/my.cnf -u root -p password 

# 停止mysql
bin/mysqladmin --defaults-file=etc/my.cnf -uroot -p shutdown

# 访问mysql
bin/mysql --defaults-file=etc/my.cnf -u root -p
```

选用mysqld_safe启动的好处。
1、mysqld_safe增加了一些安全特性，例如当出现错误时重启服务器并向错误日志文件写入运行时间信息。
2、如果有的选项是mysqld_safe 启动时特有的，那么可以终端指定，如果在配置文件中指定需要放在[mysqld_safe]组里面，放在其他组不能被正确解析。
3、mysqld_safe启动能够指定内核文件大小`ulimit -c $core_file_size`以及打开的文件的数量`ulimit -n $size`。
4、MySQL程序首先检查环境变量，然后检查配置文件，最后检查终端的选项，说明终端指定选项优先级最高。

# 权限

## 登录

```shell
mysql --defaults-file=local/mysql/etc/my.cnf -u root -p -h {host_name} -P {port}

# 当使用-A参数时，就不预读数据库信息
mysql --defaults-file=local/mysql/etc/my.cnf -u root -p -h {host_name} -P {port} {database} -A
```

## 创建用户及授权

```sql
mysql> select user, host, password from mysql.user;
mysql> create database if not exists `snapshot` default character set utf8;
mysql> grant all on snapshot.* to 'snap'@'localhost' identified by 'snap_cm';
mysql> flush privileges;
```

## 查看权限
```sql
mysql> show grants for slave@lab51;
+------------------------------------------------------------------------------+
| Grants for slave@lab51                                                       |
+------------------------------------------------------------------------------+
| GRANT REPLICATION SLAVE ON *.* TO 'slave'@'lab51' IDENTIFIED BY PASSWORD '*6DC19EACC9C42A3CD9FC667F1B606F12423CAB84' |
+------------------------------------------------------------------------------+
1 row in set (0.00 sec)
```

## 忘记密码
在my.cnf 里面的[mysqld]下面加上一行：
```
skip-grant-tables
```
然后重启mysql服务，并执行
```
mysql> update mysql.user set password = password ( 'new-password' ) WHERE user = 'root';
```
随后，再把刚添加的“skip-grant-tables”给注释掉，最后重启msql，OK！

问题：
```sql
mysql> select user, host, password from mysql.user;
ERROR 1054 (42S22): Unknown column 'password' in 'field list'
```
原来是mysql5.7数据库下已经没有password这个字段了，password字段改成了authentication_string

# mysql 操作
```sql
<!-- 创建数据库 -->
create database if not exists db_name;
<!-- 查看数据库 -->
show databases;
<!-- 选用数据库 -->
use db_name;
<!-- 删除数据库 -->
drop database if exist db_name;
查看数据库表
show tables;
删除数据表
drop table if exists db_name;

CREATE TABLE table_name (column_name column_type);
```

## 数据库状态

```sql
-- 查看目前处理的列表
show processlist;
-- 杀死连接
kill process_id;

-- 查看存储过程有哪些
show procedure status\G;

-- 清空缓存
reset query cache;

-- 查看死锁信息，执行如下命令，在打印出来的信息中找到“LATEST DETECTED DEADLOCK”一节内容，分析其中的内容，我们就可以知道最近导致死锁的事务有哪些
show engine innodb status\G;
```

## 数据表操作
```sql
查看表信息
desc table_name;
查看表的创建
show create table table_name;
```

# 编码
```sql
show variables like 'character%';
CREATE DATABASE yourdbname DEFAULT CHARSET utf8 COLLATE utf8_general_ci;
```

# binlog
## 登录到mysql查看binlog
- 获取binlog文件列表

```sql
mysql> show binary logs;
+---------------------+-----------+
| Log_name            | File_size |
+---------------------+-----------+
| 50-mysql-bin.000001 |       107 |
+---------------------+-----------+
```

- 查看第一个binlog文件的内容

```sql

mysql> show binlog events;
+---------------------+-----+-------------+-----------+-------------+---------------------------------------+
| Log_name            | Pos | Event_type  | Server_id | End_log_pos | Info                                  |
+---------------------+-----+-------------+-----------+-------------+---------------------------------------+
| 50-mysql-bin.000001 |   4 | Format_desc |         2 |         107 | Server ver: 5.5.48-log, Binlog ver: 4 |
+---------------------+-----+-------------+-----------+-------------+---------------------------------------+
```

- 查看指定binlog文件的内容
```
show binlog events in 'mysql-bin.000002';
```

- 查看当前正在写入的binlog文件

```
show master status\G
```

## 用 mysqlbinlog 查看
采用mysqlbinlog 查看mysql的binlog文件.

```shell
mysqlbinlog --no-defaults mysql-bin.000001 |less
```

## 常见问题
1）mysqlbinlog查看日志的时候碰到了一个问题， 
错误提示如下：
/usr/local/mysql/bin/mysqlbinlog: unknown variable 'default-character-set=utf8' 

产生这个问题的原因是因为我在my.cnf中的client选项组中添加了
default-character-set=utf8

解决办法：使用`--no-defaults`

# 存储引擎
InnoDB和MyISAM是许多人在使用MySQL时最常用的两个表类型，这两个表类型各有优劣，视具体应用而定。基本的差别为：

- MyISAM不支持事务，而InnoDB支持。InnoDB的AUTOCOMMIT默认是打开的，即每条SQL语句会默认被封装成一个事务，自动提交，这样会影响速度，所以最好是把多条SQL语句显示放在begin和commit之间，组成一个事务去提交。
- InnoDB支持数据行锁定，MyISAM不支持行锁定，只支持锁定整个表。即MyISAM同一个表上的读锁和写锁是互斥的，MyISAM并发读写时如果等待队列中既有读请求又有写请求，默认写请求的优先级高，即使读请求先到，所以MyISAM不适合于有大量查询和修改并存的情况，那样查询进程会长时间阻塞。因为MyISAM是锁表，所以某项读操作比较耗时会使其他写进程饿死。
- InnoDB支持外键，MyISAM不支持。
- InnoDB的主键范围更大，最大是MyISAM的2倍。
- InnoDB不支持全文索引，而MyISAM支持。
- InnoDB is mush slow on LOAD Data INFILE
- 不要联合查询innodb 表和myisam表 [Joining InnoDB tables with MyISAM tables](http://stackoverflow.com/questions/5475283/joining-innodb-tables-with-myisam-tables)

```sql
mysql> show variables like '%storage_engine%';
+------------------------+--------+
| Variable_name          | Value  |
+------------------------+--------+
| default_storage_engine | InnoDB |
| storage_engine         | InnoDB |
+------------------------+--------+
2 rows in set (0.00 sec)
```

# 导出
```shell
# 导出整个库
mysqldump -u root TE_DSP > te_dsp.sql
# 导出数据库的表结构，不含数据
mysqldump -u root -d TE_DSP_STAT > te_dsp.sql
# 导出库中的部分表
mysqldump  -u root -p darwin_lab20 t_flow t_project t_flowComp t_udc > darwin.sql

# export to csv
mysql> select nodeid, nodename from treenode  where treepath like '12276%' into outfile '/tmp/treenode.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n';
```

# 导入

```shell
mysql -u someuser -p targetdatabase < mydatabase.sql

# 或者，登录mysql后，执行source 命令，此时注意需要先创建目标数据库并执行use命令切换数据库
create targetdatabase;
use targetdatabase;
source te_dsp.sql;
```

## 使用LOAD DATA INFILE快速导入数据
LOAD DATA INFILE 语句以非常高的速度从一个文本文件中读取记录行并插入到一个表中，该方式比直接的insert的效率要高，按照官方的说法是要比insert语句快上20倍。

```sql
LOAD DATA [LOW_PRIORITY | CONCURRENT] [LOCAL] INFILE 'file_name.txt' [REPLACE | IGNORE] INTO TABLE tbl_name [FIELDS [TERMINATED BY '\t'] [[OPTIONALLY] ENCLOSED BY ''] [ESCAPED BY '\\' ] ] [LINES TERMINATED BY '\n'] [IGNORE number LINES] [(col_name,...)]
```

- LOCAL 如果 LOCAL 关键词被指定，文件从客户端主机读取。如果 LOCAL 没有被指定，文件必须位于服务器上。只有当你没有以 --local-infile=0 选项启动mysqld，或你没有禁止你的客户端程序支持 LOCAL的情况下，LOCAL 才会工作
- 如果你对一个 MyISAM 表指定关键词 CONCURRENT，那么当 LOAD DATA正在执行时，其它的线程仍可以从表中检索数据。
- REPLACE 和 IGNORE 关键词控制对与现有的记录在唯一键值上重复的记录的处理。如果你指定 REPLACE，新的记录行将替换有相同唯一键值的现有记录行。如果你指定 IGNORE，将跳过与现有的记录行在唯一键值上重复的输入记录行。如果你没有指定任何一个选项，当重复键值出现时，将会发生一个错误，文本文件的剩余部分也将被忽略。

示例：

    load data infile '/home/mark/data_update.txt' replace into table test FIELDS TERMINATED BY ',' (id,name) 
​    

# shell访问mysql并执行命令
```shell
#!/bin/sh
db_user=taglib_user
db_passwd=tag_lib*user
db_port=1128
db_host=localhost
db_dbname=TE_DSP
mysql_bin_dir=/home/work/local/mysql/bin


${mysql_bin_dir}/mysql -u${db_user} -p${db_passwd} -P${db_port} -h${db_host} -D${db_dbname} -e "show tables;"
```

# 性能剖析
分析SQL执行带来的开销是优化SQL的重要手段。在MySQL数据库中，可以通过配置profiling参数来启用SQL剖析。该参数可以在全局和session级别来设置。对于全局级别则作用于整个MySQL实例，而session级别紧影响当前session。该参数开启后，后续执行的SQL语句都将记录其资源开销，诸如IO，上下文切换，CPU，Memory等等。根据这些开销进一步分析当前SQL瓶颈从而进行优化与调整。

## 查看mysql参数配置

```sql
mysql> show global variables like '%max%';
+-----------------------------------------+----------------------+
| Variable_name                           | Value                |
+-----------------------------------------+----------------------+
| ft_max_word_len                         | 84                   |
| group_concat_max_len                    | 1024                 |
| innodb_file_format_max                  | Antelope             |
| innodb_max_dirty_pages_pct              | 75                   |
| innodb_max_purge_lag                    | 0                    |
| max_allowed_packet                      | 1048576              |
| max_binlog_cache_size                   | 18446744073709547520 |
| max_binlog_size                         | 1073741824           |
| max_binlog_stmt_cache_size              | 18446744073709547520 |
| max_connect_errors                      | 10                   |
| max_connections                         | 151                  |
| max_delayed_threads                     | 20                   |
| max_error_count                         | 64                   |
| max_heap_table_size                     | 16777216             |
| max_insert_delayed_threads              | 20                   |
| max_join_size                           | 18446744073709551615 |
| max_length_for_sort_data                | 1024                 |
| max_long_data_size                      | 1048576              |
| max_prepared_stmt_count                 | 16382                |
| max_relay_log_size                      | 0                    |
| max_seeks_for_key                       | 18446744073709551615 |
| max_sort_length                         | 1024                 |
| max_sp_recursion_depth                  | 0                    |
| max_tmp_tables                          | 32                   |
| max_user_connections                    | 0                    |
| max_write_lock_count                    | 18446744073709551615 |
| myisam_max_sort_file_size               | 9223372036853727232  |
| performance_schema_max_cond_classes     | 80                   |
| performance_schema_max_cond_instances   | 1000                 |
| performance_schema_max_file_classes     | 50                   |
| performance_schema_max_file_handles     | 32768                |
| performance_schema_max_file_instances   | 10000                |
| performance_schema_max_mutex_classes    | 200                  |
| performance_schema_max_mutex_instances  | 1000000              |
| performance_schema_max_rwlock_classes   | 30                   |
| performance_schema_max_rwlock_instances | 1000000              |
| performance_schema_max_table_handles    | 100000               |
| performance_schema_max_table_instances  | 50000                |
| performance_schema_max_thread_classes   | 50                   |
| performance_schema_max_thread_instances | 1000                 |
| slave_max_allowed_packet                | 1073741824           |
| sql_max_join_size                       | 18446744073709551615 |
+-----------------------------------------+----------------------+
42 rows in set (0.00 sec)
```

## 有关profile的描述

```sql
-- 当前版本
mysql> show variables like 'version';
+---------------+------------+
| Variable_name | Value      |
+---------------+------------+
| version       | 5.5.48-log |
+---------------+------------+
-- 查看profiling系统变量
mysql> show variables like '%profil%';
+------------------------+-------+
| Variable_name          | Value |
+------------------------+-------+
| have_profiling         | YES   |
| profiling              | OFF   |
| profiling_history_size | 15    |
+------------------------+-------+
-- 获取profile的帮助
mysql> help profile;
Name: 'SHOW PROFILE'
Description:
Syntax:
SHOW PROFILE [type [, type] ... ]
    [FOR QUERY n]
    [LIMIT row_count [OFFSET offset]]
 
type:
    ALL                --显示所有的开销信息
  | BLOCK IO           --显示块IO相关开销
  | CONTEXT SWITCHES   --上下文切换相关开销
  | CPU                --显示CPU相关开销信息
  | IPC                --显示发送和接收相关开销信息
  | MEMORY             --显示内存相关开销信息
  | PAGE FAULTS        --显示页面错误相关开销信息
  | SOURCE             --显示和Source_function，Source_file，Source_line相关的开销信息
  | SWAPS              --显示交换次数相关开销的信息 
```

## 开启porfiling

```sql
-- 开启session级的profiling
mysql> set profiling=1;
-- 验证修改后的结果
mysql> show variables like '%profil%';
+------------------------+-------+
| Variable_name          | Value |
+------------------------+-------+
| have_profiling         | YES   |
| profiling              | ON    |
| profiling_history_size | 15    |
+------------------------+-------+
--停止profile,可以设置profiling参数，或者在session退出之后,profiling会被自动关闭  
mysql> set profiling=off;  
```

## 获取SQL语句的开销信息

```sql
--发布SQL查询
mysql> select count(*) from treenode; 
-- 可以直接使用show profile来查看上一题sql语句的开销信息
mysql> show profile; 
+--------------------------------+----------+
| Status                         | Duration |
+--------------------------------+----------+
| starting                       | 0.000010 |
| Waiting for query cache lock   | 0.000003 |
| checking query cache for query | 0.000029 |
| checking permissions           | 0.000006 |
| Opening tables                 | 0.000017 |
| System lock                    | 0.000009 |
| Waiting for query cache lock   | 0.000028 |
| init                           | 0.000006 |
| optimizing                     | 0.000004 |
| executing                      | 0.000003 |
| end                            | 0.000002 |
| query end                      | 0.000002 |
| closing tables                 | 0.000006 |
| freeing items                  | 0.000002 |
| Waiting for query cache lock   | 0.000001 |
| freeing items                  | 0.000005 |
| Waiting for query cache lock   | 0.000001 |
| freeing items                  | 0.000001 |
| storing result in query cache  | 0.000001 |
| logging slow query             | 0.000001 |
| cleaning up                    | 0.000001 |
+--------------------------------+----------+
--查看当前session所有已产生的profile
mysql> show profiles;
+----------+------------+--------------------------------+
| Query_ID | Duration   | Query                          |
+----------+------------+--------------------------------+
|        1 | 0.00028400 | show variables like '%profil%' |
|        2 | 0.00010325 | SELECT DATABASE()              |
|        3 | 0.00013600 | select count(*) from treenode  |
+----------+------------+--------------------------------+
--获取指定查询的开销  
mysql> show profile for query 2;
--查看特定部分的开销，如下为CPU部分的开销  
mysql show profile cpu for query 2 ; 
--同时查看不同资源开销  
mysql> show profile block io,cpu for query 2;
--查看是否有报警
mysql> show warnings;
```

# Notice

* Tinyint,占用1字节的存储空间,取值范围是：带符号的范围是-128到127.
* Int range:[-2^31,2^31-1] [-2147483648,2147483647], so using bigint for phone number.
* The length of a string's md5 output is 32.
* TIMESTAMP values are converted from the current time zone to UTC for storage, and converted back from UTC to the current time zone for retrieval. (This occurs only for the TIMESTAMP data type, not for other types such as DATETIME.) More notably:If you store a TIMESTAMP value, and then change the time zone and retrieve the value, the retrieved value is different from the value you stored.
* Timestamps in MySQL generally used to track changes to records, and are often updated every time the record is changed. If you want to store a specific value you should use a datetime field.
* BIGINT[(M)] [UNSIGNED] [ZEROFILL] 大整数。带符号的范围是-9223372036854775808到9223372036854775807。无符号的范围是0到18446744073709551615。M指示最大显示宽度。最大有效显示宽度是255。显示宽度与存储大小或类型包含的值的范围无关

# 常见问题

- 错误日志中could not be resolved: Temporary failure in name resolution处理办法

配置问中添加
```
--skip-host-cache
--skip-name-resolve
```

- com.mysql.jdbc.exceptions.jdbc4.MySQLNonTransientConnectionException: Data source rejected establishment of connection,  message from server: "Too many connections"

查看MySQL的当前最大连接数

```sql
select VARIABLE_VALUE from information_schema.GLOBAL_VARIABLES where VARIABLE_NAME='MAX_CONNECTIONS'; 
```

要彻底解决问题还是要修改my.cnf配置文件，这里使用VI来修改，输入命令：vi /usr/my.cnf 回车；打开文件后按“i”键进入编辑状态；
在“[mysqld]”下面添加如下配置，之后重启mysql

```
max_connections=3600
```



# 参考
- [MySQL SQL剖析(SQL profile)](http://blog.csdn.net/leshami/article/details/39988527)
