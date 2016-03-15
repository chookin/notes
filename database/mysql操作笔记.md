# init database

    scripts/mysql_install_db --defaults-file=etc/my.cnf
or

    mysqld --initialize

# start mysql
start mysql, ensure the port is usable.

    bin/mysqld_safe  --defaults-file=etc/my.cnf &
    # if mac
    mysql.server start

# reset the root password

    bin/mysqladmin --defaults-file=etc/my.cnf -u root -p password

# stop mysql

    bin/mysqladmin --defaults-file=etc/my.cnf -uroot -p shutdown

# 登录
```shell
mysql --defaults-file=local/mysql/etc/my.cnf -u root -p -h {host_name} -P {port}
```
# grant privileges

    bin/mysql --defaults-file=etc/my.cnf -u root -p
    mysql> select user, host, password from mysql.user;
    mysql> create database if not exists `snapshot` default character set utf8;
    mysql> grant all on snapshot.* to 'snap'@'localhost' identified by 'snap_cm';
    mysql> flush privileges;

# 编码

    mysql> show variables like 'character%';
    mysql> CREATE DATABASE yourdbname DEFAULT CHARSET utf8 COLLATE utf8_general_ci;

# 导出

    # 导出整个库
    mysqldump -u root TE_DSP > te_dsp.sql
    # 导出数据库的表结构，不含数据
    mysqldump -u root -d TE_DSP_STAT > te_dsp.sql
    # 导出库中的部分表
    mysqldump  -u root -p darwin_lab20 t_flow t_project t_flowComp t_udc > darwin.sql

# 导入

    mysql -u someuser -p targetdatabase < mydatabase.sql
    # 或者，登录mysql后，执行source 命令，此时注意需要先创建目标数据库并执行use命令切换数据库
    create targetdatabase;
    use targetdatabase;
    source te_dsp.sql;
## 使用LOAD DATA INFILE快速导入数据
LOAD DATA INFILE 语句以非常高的速度从一个文本文件中读取记录行并插入到一个表中，该方式比直接的insert的效率要高，按照官方的说法是要比insert语句快上20倍。

    LOAD DATA [LOW_PRIORITY | CONCURRENT] [LOCAL] INFILE 'file_name.txt' [REPLACE | IGNORE] INTO TABLE tbl_name [FIELDS [TERMINATED BY '\t'] [[OPTIONALLY] ENCLOSED BY ''] [ESCAPED BY '\\' ] ] [LINES TERMINATED BY '\n'] [IGNORE number LINES] [(col_name,...)]

- LOCAL 如果 LOCAL 关键词被指定，文件从客户端主机读取。如果 LOCAL 没有被指定，文件必须位于服务器上。只有当你没有以 --local-infile=0 选项启动mysqld，或你没有禁止你的客户端程序支持 LOCAL的情况下，LOCAL 才会工作
- 如果你对一个 MyISAM 表指定关键词 CONCURRENT，那么当 LOAD DATA正在执行时，其它的线程仍可以从表中检索数据。
- REPLACE 和 IGNORE 关键词控制对与现有的记录在唯一键值上重复的记录的处理。如果你指定 REPLACE，新的记录行将替换有相同唯一键值的现有记录行。如果你指定 IGNORE，将跳过与现有的记录行在唯一键值上重复的输入记录行。如果你没有指定任何一个选项，当重复键值出现时，将会发生一个错误，文本文件的剩余部分也将被忽略。

示例：

    load data infile '/home/mark/data_update.sql' replace into table test FIELDS TERMINATED BY ',' (id,name) 

# Notice

* Tinyint,占用1字节的存储空间,取值范围是：带符号的范围是-128到127.
* Int range:[-2^31,2^31-1] [-2147483648,2147483647], so using bigint for phone number.
* The length of a string's md5 output is 32.
* TIMESTAMP values are converted from the current time zone to UTC for storage, and converted back from UTC to the current time zone for retrieval. (This occurs only for the TIMESTAMP data type, not for other types such as DATETIME.) More notably:If you store a TIMESTAMP value, and then change the time zone and retrieve the value, the retrieved value is different from the value you stored.
* Timestamps in MySQL generally used to track changes to records, and are often updated every time the record is changed. If you want to store a specific value you should use a datetime field.
* BIGINT[(M)] [UNSIGNED] [ZEROFILL] 大整数。带符号的范围是-9223372036854775808到9223372036854775807。无符号的范围是0到18446744073709551615。M指示最大显示宽度。最大有效显示宽度是255。显示宽度与存储大小或类型包含的值的范围无关
