[TOC]

# rhel6安装mysql
## 安装编译代码需要的包
```sh
yum install -y gcc gcc-c++ cmake bison bison-devel ncurses-devel
```

## 下载MySQL

```sh
# wget https://dev.mysql.com/get/Downloads/MySQL-5.5/mysql-5.5.48.tar.gz --no-check-certificate
wget https://cdn.mysql.com//Downloads/MySQL-5.7/mysql-5.7.20.tar.gz --no-check-certificate
```

## 编译安装

```shell
version=5.7.20
tar xvf mysql-$version*
cd mysql-$version
TARGET_PATH=/home/`whoami`/local/mysql-$version
cmake -DCMAKE_INSTALL_PREFIX=$TARGET_PATH -DMYSQL_DATADIR=$TARGET_PATH/data -DSYSCONFDIR=$TARGET_PATH/etc -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_MEMORY_STORAGE_ENGINE=1 -DWITH_READLINE=1 -DMYSQL_UNIX_ADDR=$TARGET_PATH/var/mysql.sock -DMYSQL_TCP_PORT=23306 -DENABLED_LOCAL_INFILE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DDOWNLOAD_BOOST=1 -DWITH_BOOST=$TARGET_PATH/boost
# 注意，对于5.7.x，需要增加如下选项
# -DDOWNLOAD_BOOST=1 -DWITH_BOOST=$TARGET_PATH/boost

make && make install
ln -fsv /home/`whoami`/local/mysql-$version /home/`whoami`/local/mysql
```

编译的参数可以参考[MySQL Source-Configuration Options](http://dev.mysql.com/doc/refman/5.5/en/source-configuration-options.html)。

注意：若编译报错 `Could NOT find Curses (missing: CURSES_LIBRARY CURSES_INCLUDE_PATH)`，那么需要`yum install bison-devel ncurses-devel`，且再删除刚才编译生成的 CMakeCache.txt 文件，否则会依然编译报错。
## 创建配置文件

```shell
mkdir etc
cp support-files/my-large.cnf etc/my.cnf
```

## 常见问题
（1）invalid conversion from ‘size_socket*’ to ‘socklen_t*’
删除解压后的源文件包，重新解压缩编译安装。

## 参考
- [CentOS 6.4下编译安装MySQL 5.6.14](http://www.cnblogs.com/xiongpq/p/3384681.html)

# 配置详解
edit 'my.cnf', check to use available port.

```shell
# The following options will be passed to all MySQL clients
[client]
#password       = your_password
port            = 23306
socket          = /Users/chookin/data/mysql/var/mysqld.sock
default-character-set   =utf8

# Here follows entries for mysqld_safe
[mysqld_safe]

# The MySQL server
[mysqld]
## 忽略密码，可用于处理密码忘记的情境
#skip-grant-tables

## 决定mysql自动重启时使用那个用户去执行
#user       = mysql

local-infile    = 0
pid-file        = /Users/chookin/data/mysql/var/mysqld.pid
socket          = /Users/chookin/data/mysql/var/mysqld.sock
port            = 23306
basedir         = /usr/local/opt/mysql
datadir         =/Users/chookin/data/mysql
tmpdir          = /tmp
skip-external-locking

##  当绑定到127.0.0.1时，将不能被远程访问
# bind-address        = 127.0.0.1

# key_buffer          = 16M
# 限制server接受的数据包大小，决定了最大能接受的sql语句大小
max_allowed_packet      = 16M
# table_cache           = 64
# thread_concurrency    = 10
thread_stack            = 192K
thread_cache_size       = 8

# 设置时区为东北区，因为mysql的jdbc驱动最新版（6.0+），误将CST（China Standard Time utc+8）解析成CST（Central Standard Tim UTC-6），即美国中部标准时间，所以少14个小时
default-time-zone = '+8:00'

## Query Caching
# query-cache-type = 1

#
# * Query Cache Configuration
#
query_cache_limit       = 1M
query_cache_size        = 16M

# 配置mysql最大连接数
max_connections=3600

collation-server        = utf8_unicode_ci
init-connect            ='SET NAMES utf8'
character-set-server    = utf8
# Default to InnoDB
default-storage-engine=innodb

wait_timeout = 1814400

# Here you can see queries with especially long duration
#log_slow_queries   = /var/log/mysql/mysql-slow.log
#long_query_time = 2
#log-queries-not-using-indexes

# Replication Master Server (default)
# binary logging is required for replication
server-id               = 1
log-bin                 = mysql-bin
expire_logs_days        = 10
max_binlog_size         = 100M
#binlog_do_db       = include_database_name
#binlog_ignore_db   = include_database_name

[mysqldump]
quick
quote-names
```

Notice, full text replacement command of vi(如果包含字符'/'，那么需要转义'\':

```shell
:g/path\/work/s//path\/yourname/g
```

# 使用mysqld_multi部署单机多实例

# 常见问题
1）mysql编译出错
```
-- Could NOT find Curses (missing:  CURSES_LIBRARY CURSES_INCLUDE_PATH)
CMake Error at cmake/readline.cmake:83 (MESSAGE):
  Curses library not found.  Please install appropriate package,
```

解决办法：The error may be from cache file. Delete CMakeCache.txt, then try again. http://stackoverflow.com/questions/8192287/curses-library-not-found

2）mysql编译时，明明指定的路径是/home/work/local/mysql，为什么启动mysql时，却提示没有权限建立/var/lib/mysql?

可能原因：如果安装Linux系统时，安装了系统自带的mysql，则对以后安装mysql产生影响。

解决方案：启动时指定配置文件，例如

```shell
bin/mysqld_safe --defaults-file=etc/my.cnf &
```

3) mysql本地连接报错

```
ERROR 2002 (HY000): Can't connect to local MySQL server through socket '/var/lib/mysql/mysql.sock'
```
问题原因，所连接的数据库为本机数据库，然而mysql命令调用的配置文件不是所连接数据库的。解决办法，指定socket参数，例如：

```
mysql -u admin -p -S /home/zhuyin/local/mysql/var/mysql.sock
```

