# Redis使用笔记

# Redis简介

Redis是一个开源的使用ANSI C语言编写、支持网络、可基于内存亦可持久化的日志型、Key-Value数据库，并提供多种语言的API。从2010年3月15日起，Redis的开发工作由VMware主持。

## 数据模型

作为Key-value型数据库，Redis提供了键（Key）和键值（Value）的映射关系。但是，除了常规的数值或字符串，Redis的键值还可以是：

- Lists （列表）
- Sets （集合）
- Sorted sets （有序集合）
- Hashes （哈希表）

键值的数据类型决定了该键值支持的操作。Redis支持诸如列表、集合或有序集合的交集、并集、差集等高级原子操作；同时，如果键值的类型是普通数字，Redis则提供自增等原子操作。

## 持久化

通常，Redis将数据存储于内存中，或被配置为使用虚拟内存。通过两种方式可以实现数据持久化：使用快照的方式，将内存中的数据不断写入磁盘；或使用类似MySQL的日志方式，记录每次更新的日志。前者性能较高，但是可能会引起一定程度的数据丢失；后者相反。

## 主从同步

 Redis支持将数据同步到多台从库上，这种特性对提高读取性能非常有益。

## 性能

相比需要依赖磁盘记录每个更新的数据库，基于内存的特性无疑给Redis带来了非常优秀的性能。读写操作之间没有显著的性能差异，如果Redis将数据只存储于内存中。


# 安装部署

## 在linux上安装

### 下载安装包

下载redis安装包，解压并编译。

```shell
wget http://download.redis.io/releases/redis-2.8.17.tar.gz
tar zxvf redis-2.8.17.tar.gz
cd redis-2.8.17
make
```

执行完后，会在当前目录中的src目录中生成相应的执行文件，如：
	redis-benchmark redis-check-aof redis-check-dump redis-cli redis-server mkreleasehdr.sh
### 安装

```
In order to install Redis binaries into /usr/local/bin just use:
% make install
You can use "make PREFIX=/some/other/directory install" if you wish to use a different destination.
```

注意：需要手动拷贝redis.confi文件

### 常见问题

安装redis，make后，make test报错。

```shell
$ make test
cd src && make test
make[1]: Entering directory '/home/zhuyin/softwares/redis-2.8.19/src'
You need tcl 8.5 or newer in order to run theRedis test
make[1]: * [test] Error 1
make[1]: Leaving directory '/home/zhuyin/softwares/redis-2.8.19/src'
make: * [test] Error 2
```

解决办法，安装tcl。

```shell
yum install -y tcl
```

或者：按照官网[tcl.html](http://www.linuxfromscratch.org/blfs/view/cvs/general/tcl.html)上的安装。

## 在mac上安装

### brew install
```shell
brew install redis
```

### view software info

```
$ brew info redis
redis: stable 3.0.7 (bottled), HEAD
Persistent key-value database, with built-in net interface
http://redis.io/
/usr/local/Cellar/redis/3.0.7 (9 files, 876.3K) *
Poured from bottle
From: https://github.com/Homebrew/homebrew/blob/master/Library/Formula/redis.rb
==> Options
--with-jemalloc
Select jemalloc as memory allocator when building Redis
--HEAD
Install HEAD version
==> Caveats
To have launchd start redis at login:
ln -sfv /usr/local/opt/redis/*.plist ~/Library/LaunchAgents
Then to load redis now:
launchctl load ~/Library/LaunchAgents/homebrew.mxcl.redis.plist
Or, if you don't want/need launchctl, you can just run:
redis-server /usr/local/etc/redis.conf
```

## 配置

redis的配置参数说明如下。一般只需配置`daemonize`,`port`,`dir`，`dbfilename`即可。

### 配置参数说明

```shell
daemonize yes  #---默认值no，该参数用于定制redis服务是否以守护模式运行。---
pidfile /usr/local/webserver/redis/run/redis.pid  #默认值/var/run/redis.pid，指定redis服务的进程号文件路径，以守护模式运行时需要配置本参数；
port 6379   #默认值6379，指定redis服务的端口
# bind 127.0.0.1  #绑定ip，默认是本机所有网络设备；
timeout 0   #客户端空闲n秒后断开连接；默认是 0 表示不断开。
loglevel notice  ###设置服务端的日志级别，有下列几种选择：
    debug：记录详细信息，用于开发或调试；
    verbose：提供很多有用的信息，但是又不像debug那么详尽，默认就是这一选项；
    notice：适度提醒，多用于产品环境；
    warning：仅显示重要的警告信息；
logfile stdout   ##指定日志的输出路径，默认值stdout，表示输出到屏幕，守护模式时则输出到/dev/null；日志文件存储在参数dir所指定的路径下。
如果要输出日志到syslog中，可以启动syslog-enabled yes，默认该选项值为no。
# syslog-enabled no
databases 16   ###指定数据库的数量，默认为16个，默认使用的数据库是DB 0。
----以下为快照相关的设置:------
#   save <seconds> <changes>  ##指定多长时间刷新快照至磁盘，这个选项有两个属性值，只有当两个属性值均满足时才会触发；可以设置多种级别，例如默认的参数文件中就设置了：
save 900 1 # 每900秒(15分钟)至少一次键值变更时被触发；
save 300 10 #每300秒(5分钟)至少10次键值变更时被触发；
save 60 10000 #每60秒至少10000次键值变更时被触发；
save 900 1
save 300 10
save 60 10000
rdbcompression yes  ##默认值yes，当dump数据库时使用LZF压缩字符串对象，如果CPU资源比较紧张，可以设置为no，选择不压缩；
rdbchecksum yes
# The filename where to dump the DB  数据库文件名
dbfilename dump.rdb  ##默认值dump.rdb，dump到文件系统中的文件名
dir /usr/local/webserver/redis/db  ##默认值./，即当前目录，dump出的数据文件的存储路径；
----以下为复制相关的设置，复制默认是不启用的，因此在默认的参数文件下列表参数均被注释----
# slaveof <masterip> <masterport>  ##指定主端ip和端口，用于创建一个镜像服务
# masterauth <master-password>  ##如果master配置了密码的话，此处也需做设置；
slave-serve-stale-data yes  ##默认值yes。当slave丢失与master端的连接，或者复制仍在处理，那么slave会有下列两种表现：
当本参数值为yes时，slave为继续响应客户端请求，尽管数据已不同步甚至没有数据(出现在初次同步的情况下)；
当本参数值为no时，slave会返回"SYNC with master in progreee"的错误信息；
slave-read-only yes  ##默认从Redis是只读模式
# repl-ping-slave-period 10  ###默认值10，指定slave定期ping master的周期；
# repl-timeout 60  ##默认值60，指定超时时间。注意本参数包括批量传输数据和ping响应的时间。
------以下为安全相关的设置------
# requirepass foobared  ###指定一个密码，客户端连接时也需要通过密码才能成功连接；
# rename-command CONFIG b840fc02d524045429941cc15f59e41cb7be6c52  ###重定义命令，例如将CONFIG命令更名为一个很复杂的名字：
# rename-command CONFIG ""  取消这个命令；
-----以下为资源限制方面的设置------
# maxclients 10000  ##指定客户端的最大并发连接数，默认是没有限制，直到redis无法创建新的进程为止，设置该参数值为0也表示不限制，如果该参数指定了值，当并发连接达到指定值时，redis会关闭所有新连接，并返回'max number of clients reached'的错误信息；
# maxmemory <bytes>  ###设置redis最大可使用内存。当达到最大内存后，redis会尝试按照设置的回收策略删除键值。如果无法删除键值，或者保留策略设置为不清除，那么redis就会向发出内存的请求返回错误信息。当把redis做为一级LRU的缓存时本参数较为有用。

# maxmemory-policy volatile-lru  ###默认值volatile-lru，指定清除策略，有下列几种方法：
    volatile-lru -> remove the key with an expire set using an LRU algorithm
    allkeys-lru -> remove any key accordingly to the LRU algorithm
    volatile-random -> remove a random key with an expire set
    allkeys->random -> remove a random key, any key
    volatile-ttl -> remove the key with the nearest expire time (minor TTL)
noeviction -> don't expire at all, just return an error on write operations

# maxmemory-samples 3    ###默认值3，LRU和最小TTL策略并非严谨的策略，而是大约估算的方式，因此可以选择取样值以便检查。
-----以下为APPEND的配置----
# ONLY模式的设置，默认情况下redis采用异步方式dump数据到磁盘上，极端情况下这可能会导致丢失部分数据(比如服务器突然宕机)，如果数据比较重要，不希望丢失，可以启用直写的模式，这种模式下redis会将所有接收到的写操作同步到appendonly.aof文件中，该文件会在redis服务启动时在内存中重建所有数据。注意这种模式对性能影响非常之大。
appendonly no  ##默认值no，指定是否启用直写模式；
# appendfilename appendonly.aof  ###直写模式的默认文件名appendonly.aof
appendfsync：调用fsync()方式让操作系统写数据到磁盘上，数据同步方式，有下列几种模式：
    always：每次都调用，比如安全，但速度最慢；
    everysec：每秒同步，这也是默认方式；
    no：不调用fsync，由操作系统决定何时同步，比如快的模式；
    no-appendfsync-on-rewrite：默认值no。当AOF fsync策略设置为always或everysec，后台保存进程会执行大量的I/O操作。某些linux配置下redis可能会阻塞过多的fsync()调用。
    auto-aof-rewrite-percentage：默认值100
    auto-aof-rewrite-min-size：默认值64mb
# appendfsync always
appendfsync everysec
# appendfsync no
-----以下为高级配置相关的设置----
hash-max-zipmap-entries：默认值512，当某个map的元素个数达到最大值，但是其中最大元素的长度没有达到设定阀值时，其HASH的编码采用一种特殊的方式(更有效利用内存)。本参数与下面的参数组合使用来设置这两项阀值。设置元素个数；
hash-max-zipmap-value：默认值64，设置map中元素的值的最大长度；这两个
list-max-ziplist-entries：默认值512，与hash类似，满足条件的list数组也会采用特殊的方式以节省空间。
list-max-ziplist-value：默认值64
set-max-intset-entries：默认值512，当set类型中的数据都是数值类型，并且set中整型元素的数量不超过指定值时，使用特殊的编码方式。
zset-max-ziplist-entries：默认值128，与hash和list类似。
zset-max-ziplist-value：默认值64
activerehashing：默认值yes，用来控制是否自动重建hash。Active rehashing每100微秒使用1微秒cpu时间排序，以重组R
```

### 安全性

为redis设置密码：设置客户端连接后进行任何其他指定前需要实用的密码。

警告：因为redis速度非常快，所以在一台较好的服务器下，一个外部用户可以在一秒钟进行150k次的密码尝试，这意味着你需要指定非常非常强大的密码来防止暴力破解。一般需把redis部署在内网。

只需要在redis的配置文件redis.conf中开启requirepass就可以了，比如设置我的访问密码是mypassword，然后重启redis。

```
requirepass mypassword
```

当设置了密码，在操作时需要进行授权，有两种方式：

(1) 登录客户端时用`-a`指定密码

```shell
redis-cli -a mypassword
```

(2) 在redis-cli的shell中用auth命令进行授权

```shell
127.0.0.1:6379> auth test
(error) ERR invalid password
127.0.0.1:6379> auth mypassword
OK
```

### 参考

- [NoSQL之Redis高级实用命令详解--安全和主从复制](http://blog.csdn.net/liutingxu1/article/details/17116107)

# 基本操作

## 启动

```shell
redis-server redis.conf
```
## 停止

```shell
redis-cli shutdown
```

redis服务关闭后，缓存数据会自动dump到硬盘上，硬盘地址为redis.conf中的配置项dbfilename所设定。

## 备份

redis服务关闭后，缓存数据会自动dump到硬盘上，硬盘地址为redis.conf中的配置项dbfilename dump.rdb所设定。
强制备份数据到磁盘，使用如下命令
```shell
redis-cli save
# 指定端口
redis-cli -p 6380 save
```

## 查询

```shell
# 查看所有keys
redis-cli --raw KEYS "*"
# 查看名字以”pw”开头的keys
redis-cli --raw KEYS "pw*
```

说明：如果不加--raw，汉字会以16进制串显示，例如:pd-c-music.migu/\xe6\xb3\xb0\xe8\xaf\xad

## 删除

```shell
# 删除所有以“pd-c-music.migu”开头的keys，需要-d选项指定分隔符为换行符（xargs默认是以空格为分隔符）
redis-cli KEYS "pd-c-music.migu*" | xargs -d \\n redis-cli DEL
redis-cli KEYS "pd-c-youku*" | xargs -d \\n redis-cli DEL
redis-cli KEYS "youku*" | xargs -d \\n redis-cli DEL
# 删除当前数据库中的所有Key
127.0.0.1:6379> flushdb
# 删除所有数据库中的key
127.0.0.1:6379> flushall
```


