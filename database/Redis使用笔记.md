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
version=2.8.17
version=3.2.9
wget http://download.redis.io/releases/redis-$version.tar.gz
tar zxvf redis-$version.tar.gz
cd redis-$version
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

```sh
make PREFIX=$HOME/local/redis install
cp redis.conf $HOME/local/redis/
```

注意：需要手动拷贝redis.conf文件

### 脚本

```sh
# start-redis.sh
bin/redis-server redis.conf
```

```sh
# stop-redis.sh
 ps -u `whoami` xu |grep redis | grep -v grep | awk '{print $2}' | xargs kill -9
```

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

```
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
logfile stdout   ##指定日志的输出路径，默认值stdout，表示输出到屏幕，守护模式时则输出到/dev/null；日志文件存储 在参数dir所指定的路径下。
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

```sh
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

```
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

# redis-list

在Redis中，List类型是按照插入顺序排序的字符串链表。和数据结构中的普通链表一样，我们可以在其头部(left)和尾部(right)添加新的元素。在插入时，如果该键并不存在，Redis将为该键创建一个新的链表。与此相反，如果链表中所有的元素均被移除，那么该键也将会被从数据库中删除。List中可以包含的最大元素数量是4294967295。
 从元素插入和删除的效率视角来看，如果我们是在链表的两头插入或删除元素，这将会是非常高效的操作，即使链表中已经存储了百万条记录，该操作也可以在常量时间内完成。然而需要说明的是，如果元素插入或删除操作是作用于链表中间，那将会是非常低效的。

## 命令

| **命令原型**                                 | **时间复杂度** | **命令描述**                                 | **返回值**                                  |
| ---------------------------------------- | --------- | ---------------------------------------- | ---------------------------------------- |
| **LPUSH**key value [value ...]           | O(1)      | 在指定Key所关联的List Value的头部插入参数中给出的所有Values。如果该Key不存在，该命令将在插入之前创建一个与该Key关联的空链表，之后再将数据从链表的头部插入。如果该键的Value不是链表类型，该命令将返回相关的错误信息。 | 插入后链表中元素的数量。                             |
| **LPUSHX** key value                     | O(1)      | 仅有当参数中指定的Key存在时，该命令才会在其所关联的List Value的头部插入参数中给出的Value，否则将不会有任何操作发生。 | 插入后链表中元素的数量。                             |
| **LRANGE** key start stop                | O(S+N)    | 时间复杂度中的S为start参数表示的偏移量，N表示元素的数量。该命令的参数start和end都是0-based。即0表示链表头部(leftmost)的第一个元素。其中start的值也可以为负值，-1将表示链表中的最后一个元素，即尾部元素，-2表示倒数第二个并以此类推。该命令在获取元素时，start和end位置上的元素也会被取出。如果start的值大于链表中元素的数量，空链表将会被返回。如果end的值大于元素的数量，该命令则获取从start(包括start)开始，链表中剩余的所有元素。 | 返回指定范围内元素的列表。                            |
| **LPOP**key                              | O(1)      | 返回并弹出指定Key关联的链表中的第一个元素，即头部元素，。如果该Key不存，返回nil。 | 链表头部的元素。                                 |
| **LLEN**key                              | O(1)      | 返回指定Key关联的链表中元素的数量，如果该Key不存在，则返回0。如果与该Key关联的Value的类型不是链表，则返回相关的错误信息。 | 链表中元素的数量。                                |
| **LREM**key count value                  | O(N)      | 时间复杂度中N表示链表中元素的数量。在指定Key关联的链表中，删除前count个值等于value的元素。如果count大于0，从头向尾遍历并删除，如果count小于0，则从尾向头遍历并删除。如果count等于0，则删除链表中所有等于value的元素。如果指定的Key不存在，则直接返回0。 | 返回被删除的元素数量。                              |
| **LSET**key index value                  | O(N)      | 时间复杂度中N表示链表中元素的数量。但是设定头部或尾部的元素时，其时间复杂度为O(1)。设定链表中指定位置的值为新值，其中0表示第一个元素，即头部元素，-1表示尾部元素。如果索引值Index超出了链表中元素的数量范围，该命令将返回相关的错误信息。 |                                          |
| **LINDEX** key index                     | O(N)      | 时间复杂度中N表示在找到该元素时需要遍历的元素数量。对于头部或尾部元素，其时间复杂度为O(1)。该命令将返回链表中指定位置(index)的元素，index是0-based，表示头部元素，如果index为-1，表示尾部元素。如果与该Key关联的不是链表，该命令将返回相关的错误信息。 | 返回请求的元素，如果index超出范围，则返回nil。              |
| **LTRIM**key start stop                  | O(N)      | N表示被删除的元素数量。该命令将仅保留指定范围内的元素，从而保证链接中的元素数量相对恒定。start和stop参数都是0-based，0表示头部元素。和其他命令一样，start和stop也可以为负值，-1表示尾部元素。如果start大于链表的尾部，或start大于stop，该命令不错报错，而是返回一个空的链表，与此同时该Key也将被删除。如果stop大于元素的数量，则保留从start开始剩余的所有元素。 |                                          |
| **LINSERT** key BEFORE\|AFTER pivot value | O(N)      | 时间复杂度中N表示在找到该元素pivot之前需要遍历的元素数量。这样意味着如果pivot位于链表的头部或尾部时，该命令的时间复杂度为O(1)。该命令的功能是在pivot元素的前面或后面插入参数中的元素value。如果Key不存在，该命令将不执行任何操作。如果与Key关联的Value类型不是链表，相关的错误信息将被返回。 | 成功插入后链表中元素的数量，如果没有找到pivot，返回-1，如果key不存在，返回0。 |
| **RPUSH** key value [value ...]          | O(1)      | 在指定Key所关联的List Value的尾部插入参数中给出的所有Values。如果该Key不存在，该命令将在插入之前创建一个与该Key关联的空链表，之后再将数据从链表的尾部插入。如果该键的Value不是链表类型，该命令将返回相关的错误信息。 | 插入后链表中元素的数量。                             |
| **RPUSHX** key value                     | O(1)      | 仅有当参数中指定的Key存在时，该命令才会在其所关联的List Value的尾部插入参数中给出的Value，否则将不会有任何操作发生。 | 插入后链表中元素的数量。                             |
| **RPOP**key                              | O(1)      | 返回并弹出指定Key关联的链表中的最后一个元素，即尾部元素，。如果该Key不存，返回nil。 | 链表尾部的元素。                                 |
| **RPOPLPUSH**source destination          | O(1)      | 原子性的从与source键关联的链表尾部弹出一个元素，同时再将弹出的元素插入到与destination键关联的链表的头部。如果source键不存在，该命令将返回nil，同时不再做任何其它的操作了。如果source和destination是同一个键，则相当于原子性的将其关联链表中的尾部元素移到该链表的头部。 | 返回弹出和插入的元素。                              |

## 示例

```js
// 删除队列
127.0.0.1:6379> DEL test1
(integer) 0
// 键并不存在，该命令会创建该键及与其关联的List，之后在将参数中的values从左到右依次插入。
// 创建键为`test`的队列，并依次插入元素
// 返回插入后链表中元素的数量
127.0.0.1:6379> lpush test a b c d e f
(integer) 6
// 再插入一个元素
127.0.0.1:6379> lpush test g
(integer) 7
// 获取0-based偏移量0到1的元素
127.0.0.1:6379> LRANGE test 0 1
1) "g"
2) "f"
// 获取链表头部的元素
127.0.0.1:6379> LRANGE test 0 0
1) "g"
// 获取链表头部到尾部的所有元素，-1表示链表的最后一个元素
127.0.0.1:6379> LRANGE test 0 -1
1) "g"
2) "f"
3) "e"
4) "d"
5) "c"
6) "b"
7) "a"
// 返回并弹出链表头部元素
127.0.0.1:6379> LPOP test
"g"
// 返回链表元素数量
127.0.0.1:6379> LLEN test
(integer) 6
// 添加元素到链表尾部
127.0.0.1:6379> RPUSH test z
(integer) 7
// 在链表尾部获取2个元素
// -2表示链表的倒数第二个元素
127.0.0.1:6379> LRANGE test -2 -1
1) "a"
2) "z"
// 在链表尾部获取100个元素，因超出范围的下标值不会引起错误，因此，实际返回的是min(abs(-100), len)个元素
127.0.0.1:6379> LRANGE test -100 -1
1) "f"
2) "e"
3) "d"
4) "c"
5) "b"
6) "a"
7) "z"
// 删除链表尾部的5个元素
127.0.0.1:6379> LTRIM test 0 -5
OK
127.0.0.1:6379> LRANGE test 0 -1
1) "f"
2) "e"
3) "d"
```



## 参考

- [[Redis学习手册(List数据类型)](http://www.cnblogs.com/stephen-liu74/archive/2012/03/16/2351859.html)](http://www.cnblogs.com/stephen-liu74/archive/2012/02/14/2351859.html)

# php-redis

## 长连接
pconnect函数声明

其中time_out表示客户端闲置多少秒后，就断开连接。函数连接成功返回true，失败返回false：

    pconnect(host, port, time_out, persistent_id, retry_interval)
        host: string. can be a host, or the path to a unix domain socket
        port: int, optional
        timeout: float, value in seconds (optional, default is 0 meaning unlimited)
        persistent_id: string. identity for the requested persistent connection
        retry_interval: int, value in milliseconds (optional)

下面的例子详细介绍了pconnect连接的重用情况。

    $redis->pconnect('127.0.0.1', 6379);
    $redis->pconnect('127.0.0.1'); // 默认端口6379,跟上面的例子使用相同的连接。
    $redis->pconnect('127.0.0.1', 6379, 2.5); // 设置了2.5秒的过期时间。将是不同于上面的新连接
    $redis->pconnect('127.0.0.1', 6379, 2.5, 'x'); //设置了持久连接的id，将是不同于上面的新连接
    $redis->pconnect('/tmp/redis.sock'); // unix domain socket - would be another connection than the four before.

- [PHP中使用Redis长连接笔记](http://blog.csdn.net/whynottrythis/article/details/71156688)

# python-redis

## 安装redis module

```sh
pip install redis
```





