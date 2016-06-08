[TOC]

# rhel6安装mysql
## 安装编译代码需要的包

    yum install -y gcc gcc-c++ cmake bison bison-devel ncurses-devel
## 下载MySQL
    wget https://dev.mysql.com/get/Downloads/MySQL-5.5/mysql-5.5.48.tar.gz --no-check-certificate
## 编译安装

```shell
cmake -DCMAKE_INSTALL_PREFIX=/home/`whoami`/local/mysql -DMYSQL_DATADIR=/home/`whoami`/local/mysql/data -DSYSCONFDIR=/home/`whoami`/local/mysql/etc -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_MEMORY_STORAGE_ENGINE=1 -DWITH_READLINE=1 -DMYSQL_UNIX_ADDR=/home/`whoami`/local/mysql/var/mysql.sock -DMYSQL_TCP_PORT=3306 -DENABLED_LOCAL_INFILE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci
make && make install
```

编译的参数可以参考[MySQL Source-Configuration Options](http://dev.mysql.com/doc/refman/5.5/en/source-configuration-options.html)。

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

# mac安装mysql

## 采用brew安装

    brew install mysql # brew方式安装后的软件路径是/usr/local/opt/mysql/，数据文件夹是/usr/local/var/mysql
添加修改mysql配置

    mysqld --help --verbose | more (查看帮助, 按空格下翻)
你会看到开始的这一行(表示配置文件默认读取顺序)

    Default options are read from the following files in the given order:
    /etc/my.cnf /etc/mysql/my.cnf /usr/local/etc/my.cnf ~/.my.cnf
通常这些位置是没有配置文件的, 所以要自己建一个

```shell
# 用这个可以找到样例.cnf
ls $(brew --prefix mysql)/support-files/my-*
# 拷贝到第一个默认读取目录
cp /usr/local/opt/mysql/support-files/my-default.cnf /etc/my.cnf
# 此后按需修改my.cnf
```

## mysql启停
可用使用mysql的脚本启停,也可借助brew

    mysql.server start
    brew services start mysql
    brew services stop mysql

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

local-infile    = 0
pid-file        = /Users/chookin/data/mysql/var/mysqld.pid
socket          = /Users/chookin/data/mysql/var/mysqld.sock
port            = 23306
basedir         = /usr/local/opt/mysql
datadir         =/Users/chookin/data/mysql
tmpdir          = /tmp
skip-external-locking
max_allowed_packet      = 16M
thread_stack            = 192K
thread_cache_size       = 8
query_cache_limit       = 1M
query_cache_size        = 16M
expire_logs_days        = 10
max_binlog_size         = 100M

collation-server        = utf8_unicode_ci
init-connect            ='SET NAMES utf8'
character-set-server    = utf8
wait_timeout = 1814400

# Replication Master Server (default)
# binary logging is required for replication
server-id       = 1
log-bin         = mysql-bin

[mysqldump]
quick
quote-names
max_allowed_packet      = 16M
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
```
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

