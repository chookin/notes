# mac系统

## 采用brew安装

    brew install mysql # brew方式安装后的软件路径是/usr/local/opt/mysql/，数据文件夹是/usr/local/var/mysql
添加修改mysql配置

    mysqld --help --verbose | more (查看帮助, 按空格下翻)
你会看到开始的这一行(表示配置文件默认读取顺序)

    Default options are read from the following files in the given order:
    /etc/my.cnf /etc/mysql/my.cnf /usr/local/etc/my.cnf ~/.my.cnf
通常这些位置是没有配置文件的, 所以要自己建一个

    # 用这个可以找到样例.cnf
    ls $(brew --prefix mysql)/support-files/my-*
    # 拷贝到第一个默认读取目录
    cp /usr/local/opt/mysql/support-files/my-default.cnf /etc/my.cnf
    # 此后按需修改my.cnf

操作
可用使用mysql的脚本启停,也可借助brew

    mysql.service start
    brew services start mysql
    brew services stop mysql
## Configuration
edit 'my.cnf', check to use available port.

```shell
# The following options will be passed to all MySQL clients
[client]
#password       = your_password
port            = 23306
socket          = /Users/chookin/data/mysql/var/mysqld.sock
default-character-set   =utf8

# Here follows entries for some specific programs
[mysqld_safe]
socket          = /Users/chookin/data/mysql/var/mysqld.sock
nice            = 0

# The MySQL server
[mysqld]
port            = 23306
socket          = /Users/chookin/data/mysql/var/mysql.sock
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
