[TOC]
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
查看目前处理的列表
show processlist;
查看存储过程有哪些
show procedure status\G;

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

mysql> show variables like '%storage_engine%';
+------------------------+--------+
| Variable_name          | Value  |
+------------------------+--------+
| default_storage_engine | InnoDB |
| storage_engine         | InnoDB |
+------------------------+--------+
2 rows in set (0.00 sec)

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

    load data infile '/home/mark/data_update.sql' replace into table test FIELDS TERMINATED BY ',' (id,name) 
    

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

# Notice

* Tinyint,占用1字节的存储空间,取值范围是：带符号的范围是-128到127.
* Int range:[-2^31,2^31-1] [-2147483648,2147483647], so using bigint for phone number.
* The length of a string's md5 output is 32.
* TIMESTAMP values are converted from the current time zone to UTC for storage, and converted back from UTC to the current time zone for retrieval. (This occurs only for the TIMESTAMP data type, not for other types such as DATETIME.) More notably:If you store a TIMESTAMP value, and then change the time zone and retrieve the value, the retrieved value is different from the value you stored.
* Timestamps in MySQL generally used to track changes to records, and are often updated every time the record is changed. If you want to store a specific value you should use a datetime field.
* BIGINT[(M)] [UNSIGNED] [ZEROFILL] 大整数。带符号的范围是-9223372036854775808到9223372036854775807。无符号的范围是0到18446744073709551615。M指示最大显示宽度。最大有效显示宽度是255。显示宽度与存储大小或类型包含的值的范围无关

# 常见问题
