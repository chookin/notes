MongoDB是一个高性能，开源，无模式的文档型数据库，是当前NoSql数据库中比较热门的一种。它在许多场景下可用于替代传统的关系型数据库或键/值存储方式。Mongo使用C++开发。Mongo的官方网站地址是：http://www.mongodb.org。

# 部署

下载压缩包 https://www.mongodb.com/download-center?jmp=nav#community

使用`wget`下载报错，因此，使用`curl`

```sh
wget https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel62-3.4.5.tgz --no-check-certificate
--2017-06-14 10:23:25--  https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel62-3.4.5.tgz
Resolving fastdl.mongodb.org... 54.230.181.135, 54.230.181.11, 54.230.181.103, ...
Connecting to fastdl.mongodb.org|54.230.181.135|:443... connected.
OpenSSL: error:14077410:SSL routines:SSL23_GET_SERVER_HELLO:sslv3 alert handshake failure
Unable to establish SSL connection.

curl -O https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel62-3.4.5.tgz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 95.8M  100 95.8M    0     0  6416k      0  0:00:15  0:00:15 --:--:-- 11.1M
```

解压缩压缩包到指定路径。

# 启动服务

```shell
mongod --config /usr/local/etc/mongod.conf &
```
或者

```shell
data_dir="/data/zhuyin/mongo"
mkdir -p $data_dir/data
mkdir -p $data_dir/logs
mongod --dbpath=$data_dir/data/ --logpath=$data_dir/logs/mongod.log --logappend &
```

# 关闭Mongod
killall mongod 或者是 kill [pid]

# 使用自带客户端连接
```
bin/mongo
```

# 可视化工具
MongoDb的可视化管理工具有很多，这里有个列表http://docs.mongodb.org/ecosystem/tools/administration-interfaces

```shell
$ brew install Caskroom/cask/robomongo
```

# 查看命令help

```shell
$ ./bin/mongod --help
** NOTE: when using MongoDB 32 bit, you are limited to about 2 gigabytes of data**
see http://blog.mongodb.org/post/137788967/32-bit-limitations
for more Allowed options: General options:
-h [ --help ]            show this usage information
--version                show version information
-f [ --config ] arg       configuration file specifying additional options
--port arg                specify port number （default is 27017）
--bind_ip arg             local ip address to bind listener.如果配置为'127.0.0.1 '将只能接收本地连接；将bind_ip改成0.0.0.0就能支持远程访问了（或者直接将bind_ip注释掉）
- all local ips                             bound by default
-v [ --verbose ]          be more verbose (include multiple times for more                             verbosity e.g. -vvvvv)
--dbpath arg (=/data/db/) directory for datafiles    指定数据存放目录
--quiet                   quieter output   静默模式
--logpath arg             file to send all output to instead of stdout   指定日志存放目录
--logappend               appnd to logpath instead of over-writing 指定日志是以追加还是以覆盖的方式写入日志文件
--fork                    fork server process   以创建子进程的方式运行
--cpu                     periodically show cpu and iowait utilization 周期性的显示cpu和io的使用情况
--noauth                  run without security 无认证模式运行
--auth                    run with security 认证模式运行
--objcheck                inspect client data for validity on receipt 检查客户端输入数据的有效性检查
--quota                   enable db quota management   开始数据库配额的管理
--quotaFiles arg          number of files allower per db, requires --quota   规定每个数据库允许的文件数
--appsrvpath arg          root directory for the babble app server
--nocursors               diagnostic/debugging option 调试诊断选项
--nohints                 ignore query hints 忽略查询命中率
--nohttpinterface         disable http interface 关闭http接口，默认是28017
--noscripting             disable scripting engine 关闭脚本引擎
--noprealloc              disable data file preallocation 关闭数据库文件大小预分配
--smallfiles              use a smaller default file size 使用较小的默认文件大小
--nssize arg (=16)        .ns file size (in MB) for new databases 新数据库ns文件的默认大小
--diaglog arg             0=off 1=W 2=R 3=both 7=W+some reads 提供的方式，是只读，只写，还是读写都行，还是主要写+部分的读模式
--sysinfo                 print some diagnostic system information 打印系统诊断信息
--upgrade                 upgrade db if needed 如果需要就更新数据库
--repair                  run repair on all dbs 修复所有的数据库
--notablescan             do not allow table scans 不运行表扫描
--syncdelay arg (=60)     seconds between disk syncs (0 for never) 系统同步刷新磁盘的时间，默认是60s Replication options:
--master              master mode 主复制模式
--slave               slave mode 从复制模式
--source arg          when slave: specify master as <server:port> 当为从时，指定主的地址和端口
--only arg            when slave: specify a single database to replicate 当为从时，指定需要从主复制的单一库
--pairwith arg        address of server to pair with
--arbiter arg         address of arbiter server 仲裁服务器，在主主中和pair中用到
--autoresync          automatically resync if slave data is stale 自动同步从的数据
--slavedelay arg      specify delay (in seconds) to be used when applying master ops to slave 指从复制检测的间隔
--oplogSize arg       size limit (in MB) for op log 指定操作日志的大小
--opIdMem arg         size limit (in bytes) for in memory storage of op ids指定存储操作日志的内存大小
Sharding options:
--configsvr           declare this is a config db of a cluster 指定shard中的配置服务器
--shardsvr            declare this is a shard db of a cluster 指定shard服务器
```
