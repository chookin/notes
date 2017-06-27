s# 简介
## 功能
memcache是一个高性能的分布式的内存对象缓存系统，通过在内存里维护一个统一的巨大的hash表，它能够用来存储各种格式的数据，包括图像、视频、文件以及数据库检索的结果等。Memcache是danga.com的一个项目，最早是为 LiveJournal 服务的，最初为了加速 LiveJournal 访问速度而开发的，后来被很多大型的网站采用。目前全世界不少人使用这个缓存项目来构建自己大负载的网站，来分担数据库的压力。起初作者编写它可能是为了提高动态网页应用，为了减轻数据库检索的压力，来做的这个缓存系统。它的缓存是一种分布式的，也就是可以允许不同主机上的多个用户同时访问这个缓存系统， 这种方法不仅解决了共享内存只能是单机的弊端，同时也解决了数据库检索的压力，最大的优点是提高了访问获取数据的速度。
# 程序部署
下载最新的memcached程序到本地

    wget http://www.memcached.org/files/memcached-1.4.5.tar.gz
完成后，解压并准备编译安装。

    ./configure --prefix=/home/`whoami`/local/memcached/
    make && make install
安装成功后，在—prefix指定目录下会有memcached相关程序

<strong>常见问题</strong>

    checking for libevent directory... configure: error: libevent is required.  You can get it from http://www.monkey.org/~provos/libevent/
      If it's already installed, specify its path using --with-libevent=/dir/
解决办法，安装libevent

    yum install -y libevent libevent-devel

# 程序启动
## 启动命令
指定监听端口，启动memcached实例：

```shell
nohup bin/memcached -m 2048 -c 8192 -p 11211 >/dev/null 2>> logs/memcached11211.log &

nohup bin/memcached -m 2048 -c 8192 -p 11211 1>>logs/memcached11211.log 2>&1 &
```

## 参数说明
参数说明如下

    -p 监听的TCP端口号，默认是11211
    -l 监听的地址, 默认是本机
    -d 选项是启动一个守护进程
    -d start 启动memcached服务
    -d restart 重起memcached服务
    -d stop|shutdown 关闭正在运行的memcached服务
    -d install 安装memcached服务
    -d uninstall 卸载memcached服务
    -u 以的身份运行 (仅在以root运行的时候有效)
    -U 指定监听的UDP端口号，默认是11211
    -m 最大内存使用，单位是Megabytes，默认64MB
    -M 内存耗尽时返回错误，而不是删除项
    -c 最大同时连接数，默认是1024
    -f 块大小增长因子，默认是1.25-n 最小分配空间，key+value+flags默认是48
    -h 显示帮助
    -t 指定线程数，默认是4个
    -P 是设置Memcached的pid文件
# 编译memcache.so
安装php的memcache扩展
有两个版本一个是[memcache](http://pecl.php.net/package/memcache)，另一个是基于[libmemcached](http://pecl.php.net/package/memcached)的memcached版本；
网上查的资料是说前一个是原生的，后一个比前一个功能更强大。比较推荐使用基于libmemcahced 库的memcached扩展。支持memcache提供的CAS操作，稳定性和效率也更好。
这里我使用基于libmemcached 库的memcached扩展，安装步骤如下：
## 安装libmemcached

    wget https://launchpad.net/libmemcached/1.0/1.0.18/+download/libmemcached-1.0.18.tar.gz
    tar zxvf libmemcached-1.0.18.tar.gz
    cd libmemcached-1.0.18
    myname=`whoami`
    ./configure --prefix=/home/$myname/local/libmemcached
    make
    make install
## 安装php的memcached插件

    wget http://pecl.php.net/get/memcached-2.2.0.tgz
    tar zxvf  memcached-2.2.0.tgz
    cd memcached-2.2.0
    phpize
    myname=`whoami`
    ./configure --with-libmemcached-dir=/home/$myname/local/libmemcached --disable-memcached-sasl
    make
    make install
# 使用说明
## 连接到 memcached
如果memcached是以默认端口11211启动，那么

    $ telnet localhost 11211
    Trying 127.0.0.1...
    Connected to localhost.localdomain (127.0.0.1).
    Escape character is '^]'
## 基本客户机命令
在连接到memcached后，可以执行如下五种基本 memcached 操作命令：

    set
    add
    replace
    get
    delete
前三个命令是用于操作存储在 memcached 中的键值对，且都使用下面的语法：

    command <key> <flags> <expiration time> <bytes> <value>

- key 用于查找缓存值
- flags 可以包括键值对的整型参数，客户机使用它存储关于键值对的额外信息
- expiration time 在缓存中保存键值对的时间长度（以秒为单位，0 表示永远）
- bytes 在缓存中存储的字节点
- value 存储的值（始终位于第二行）


### set
set 命令用于向缓存添加新的键值对。如果键已经存在，则之前的值将被替换。
示例：

    set userId 0 0 5
    12345
    STORED
如果使用 set 命令正确设定了键值对，服务器将使用单词 STORED 进行响应。本示例向缓存中添加了一个键值对，其键为 userId，其值为 12345，并将过期时间设置为 0。
### add
仅当缓存中不存在键时，add 命令才会向缓存中添加一个键值对。如果缓存中已经存在键，则之前的值将仍然保持相同，并且您将获得响应 NOT_STORED。
下面是使用 add 命令的标准交互：

    set userId 0 0 5
    12345
    STORED

    add userId 0 0 5
    55555
    NOT_STORED

    add companyId 0 0 3
    564
    STORED
### replace
仅当键已经存在时，replace 命令才会替换缓存中的键。如果缓存中不存在键，那么您将从 memcached 服务器接受到一条 NOT_STORED 响应。
下面是使用 replace 命令的标准交互：

    replace accountId 0 0 5
    67890
    NOT_STORED

    set accountId 0 0 5
    67890
    STORED

    replace accountId 0 0 5
    55555
    STORED
### get
get 命令用于检索与之前添加的键值对相关的值。使用一个键来调用 get，如果这个键存在于缓存中，则返回相应的值。如果不存在，则不返回任何内容。
下面是使用 get 命令的典型交互：

    set userId 0 0 5
    12345
    STORED

    get userId
    VALUE userId 0 5
    12345
    END

    get bob
    END
### delete
delete 命令用于删除 memcached 中的任何现有值。您将使用一个键调用 delete，如果该键存在于缓存中，则删除该值。如果不存在，则返回一条 NOT_FOUND 消息。
下面是使用 delete 命令的客户机服务器交互：

    set userId 0 0 5
    98765
    STORED

    delete bob
    NOT_FOUND

    delete userId
    DELETED

    get userId
    END
## 缓存管理命令
#### stats
执行 stats 命令显示了关于当前 memcached 实例的信息。

    stats
    STAT pid 17827
    STAT uptime 5944
    STAT time 1416393186
    STAT version 1.4.5 # 版本号
    STAT pointer_size 64
    STAT rusage_user 0.001999
    STAT rusage_system 0.009998
    STAT curr_connections 10
    STAT total_connections 14
    STAT connection_structures 11
    STAT cmd_get 3
    STAT cmd_set 5
    STAT cmd_flush 0
    STAT get_hits 2
    STAT get_misses 1
    STAT delete_misses 0
    STAT delete_hits 0
    STAT incr_misses 0
    STAT incr_hits 0
    STAT decr_misses 0
    STAT decr_hits 0
    STAT cas_misses 0
    STAT cas_hits 0
    STAT cas_badval 0
    STAT auth_cmds 0
    STAT auth_errors 0
    STAT bytes_read 393
    STAT bytes_written 1147
    STAT limit_maxbytes 2147483648
    STAT accepting_conns 1
    STAT listen_disabled_num 0
    STAT threads 4
    STAT conn_yields 0
    STAT bytes 76
    STAT curr_items 1
    STAT total_items 4
    STAT evictions 0
    STAT reclaimed 0
    END

### flush_all
flush_all 用于清理缓存中的所有名称/值对，将所有的items标记为expired。
## 退出telnet连接

    quit
参考：
- http://www.cnblogs.com/czh-liyu/archive/2010/04/27/1722084.html
- http://blog.csdn.net/hguisu/article/details/7353793

## php访问
```php
<?php
$memcache = new Memcache; //创建一个memcache对象
$memcache->connect('localhost', 11211) or die ("Could not connect"); //连接Memcached服务器
$memcache->set('key', 'test'); //设置一个变量到内存中，名称是key 值是test
$get_value = $memcache->get('key'); //从内存中取出key的值
echo $get_value;
?>
```

# 常见问题
（1）failed to set rlimit for open files. Try running as root or requesting smaller maxconns value.
解决办法：编辑文件/etc/security/limits.conf,为memcached用户设置最多可以打开的文件数目（当前memcached的用户为work）。

```shell
$ sudo vi /etc/security/limits.conf

#"soft" for enforcing the soft limits
#"hard" for enforcing hard limits
# "nofile" max open file
# *********************************************************************
# * Note soft limit must be >= MAXCONN value (defined in /etc/sysconfig/memcached *
# *********************************************************************
# Username type    item           value
work       soft    nofile         65536
work       hard    nofile         65536
```

文件修改后，__重新打开shell__,执行命令`ulimit -a`，可发现配置已生效。

参考：http://www.cyberciti.biz/faq/linux-unix-rhel-centos-memcache-failedto-setrlimit/
（2）启动报错
error while loading shared libraries: libevent-2.0.so.5
或者
checking for libevent directory... configure: error: libevent is required.
解决办法，编译安装libevent-2.0.21-stable.tar.gz。

    ./configure && make && make install
然后，

    ln -fs /usr/local/lib/libevent-2.0.so.5 /usr/lib64/libevent-2.0.so.5
或者指定路径安装，然后memcached也指定路径安装。

    ./configure --prefix=/home/mtag/local/memcached --with-libevent=/home/mtag/local/libevent

