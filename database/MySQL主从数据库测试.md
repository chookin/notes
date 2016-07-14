# MySQL主从数据库性能测试

(2016-06-13 11:37:29, created by [Zhu Yin](mailto:zhuyin@chinamobile.com))

# 功能测试

## 读写分离测试

测试标记为readOnly的请求走从库，而没有标记的走主库。

## 故障切换测试

测试一个从库宕掉后，程序读写正常。

# 数据库性能测试

## 性能测试指标

关键指标

- CPU: %wait, %user, %sys
- 内存


CRUD的不同级别记录量的用时。

- QPS(每秒Query量)

```
QPS = Questions(or Queries) / seconds
mysql > show /*50000 global */ status like 'Question';
```

- TPS(每秒事务量)

```
TPS = (Com_commit + Com_rollback) / seconds
mysql > show status like 'Com_commit';
mysql > show status like 'Com_rollback';
```

- key Buffer 命中率

```
key_buffer_read_hits = (1-key_reads / key_read_requests) * 100%
key_buffer_write_hits = (1-key_writes / key_write_requests) * 100%
mysql> show status like 'Key%';
```

- InnoDB Buffer命中率

```
innodb_buffer_read_hits = (1 - innodb_buffer_pool_reads / innodb_buffer_pool_read_requests) * 100%
mysql> show status like 'innodb_buffer_pool_read%';
```

- Query Cache命中率

```
Query_cache_hits = (Qcahce_hits / (Qcache_hits + Qcache_inserts )) * 100%;
mysql> show status like 'Qcache%';
```

- Table Cache状态量

```
mysql> show status like 'open%';
```

- Thread Cache 命中率

```
Thread_cache_hits = (1 - Threads_created / connections ) * 100%
mysql> show status like 'Thread%';
mysql> show status like 'Connections';
```

- 锁定状态

```
mysql> show status like '%lock%';
```

- 复制延时量

```
mysql > show slave status
```

- Tmp Table 状况(临时表状况)

```
mysql > show status like 'Create_tmp%';
```

- Binlog Cache 使用状况

```
mysql > show status like 'Binlog_cache%';
```

- Innodb_log_waits 量

```
mysql > show status like 'innodb_log_waits';
```

## 性能测试工具

比较常用的MySQL基准压力hi测试工具有 [tpcc-mysql](https://github.com/Percona-Lab/tpcc-mysql)、[sysbench](https://github.com/akopytov/sysbench)、[mysqlslap](http://dev.mysql.com/doc/refman/5.6/en/mysqlslap.html) 等几个。本次性能测试选用sysbench.

## 绘图工具
gnuplot



## 关于压力测试的其他几个方面

1、如何避免压测时受到缓存的影响

【老叶建议】有2点建议

1. 填充测试数据比物理内存还要大，至少超过 [innodb_buffer_pool_size](http://dev.mysql.com/doc/refman/5.6/en/innodb-parameters.html#sysvar_innodb_buffer_pool_size) 值，不能将数据全部装载到内存中，除非你的本意就想测试全内存状态下的MySQL性能。
2. 每轮测试完成后，都重启mysqld实例，并且用下面的方法删除系统cache，释放swap（如果用到了swap的话），甚至可以重启整个OS。

```shell
[root@imysql.com]# sync  -- 将脏数据刷新到磁盘
[root@imysql.com]# echo 3 > /proc/sys/vm/drop_caches  -- 清除OS Cache
[root@imysql.com]# swapoff -a && swapon -a
```

2、如何尽可能体现线上业务真实特点

【老叶建议】有2点建议

1. 其实上面已经说过了，就是自行开发测试工具或者利用 [tcpcopy](https://github.com/session-replay-tools/tcpcopy)（或类似交换机的mirror功能） 将线上实际用户请求导向测试环境，进行仿真模拟测试。
2. 利用 [http_load](http://acme.com/software/http_load/) 或 [siege](https://github.com/JoeDog/siege) 工具模拟真实的用户请求URL进行压力测试，这方面我不是太专业，可以请教企业内部的压力测试同事。

3、压测结果如何解读

【老叶建议】压测结果除了tps/TpmC指标外，还应该关注压测期间的系统负载数据，尤其是 iops、iowait、svctm、%util、每秒I/O字节数(I/O吞吐)、事务响应时间(tpcc-mysql/sysbench 打印的测试记录中均有)。另外，如果I/O设备能提供设备级 IOPS、读写延时 数据的话，也应该一并关注。

假如两次测试的tps/TpmC结果一样的话，那么谁的 事务响应时间、iowait、svctm、%util、读写延时 更低，就表示那个测试模式有更高的性能提升空间。

4、这里需要注意的几点，一个不管怎么oltp的应用多少会存在热点数据，所以除非测试特殊性否则尽量不用uniform这种非热点数据模式，热点数据比例就需要你自己定。另线程数也不宜太大除非压力测试，一般100以内。初始化数据方式最好随机--rand-init=on。表的数量这个参数感觉意义不大，因为测试过程中每个表的结构一模一样。

5、真实测试场景中，数据表建议不低于10个，单表数据量不低于500万行，当然了，要视服务器硬件配置而定。如果是配备了SSD或者PCIE SSD这种高IOPS设备的话，则建议单表数据量最少不低于1亿行。

# 附录

## sysbench使用说明

sysbench是一个开源的、模块化的、跨平台的多线程性能测试工具，sysbench支持以下几种测试模式：

1. CPU运算性能
2. 磁盘IO性能
3. 调度程序性能
4. 内存分配及传输速度
5. POSIX线程性能
6. 数据库性能(OLTP基准测试)

目前sysbench主要支持 mysql,drizzle,pgsql,oracle 等几种数据库。

### 安装

从github下载源码进行编译安装。

```shell
git clone https://github.com/akopytov/sysbench
cd sysbench
./autogen.sh
./configure --with-mysql-includes=/home/`whoami`/local/mysql/include --with-mysql-libs=/home/`whoami`/local/mysql/lib  --prefix=/home/`whoami`/local/sysbench
make
make install
```

对于版本0.5，需要拷贝oltp测试脚本到安装目录。

```shell
cp -r sysbench/tests/tests /home/`whoami`/local/sysbench/
```

添加到用户环境变量

```shell
export SYSBENCH_PATH=$HOME/local/sysbench
export PATH=$SYSBENCH_PATH/bin:$PATH
```

### 使用

The general syntax for SysBench is as follows:

      sysbench [common-options] --test=name [test-options] command
Below is a brief description of available commands and their purpose:

- prepare: performs preparative actions for those tests which need them, e.g. creating the necessary files on disk for the fileio test, or filling the test database for OLTP tests.


- run: runs the actual test specified with the --test option.


- cleanup: removes temporary data after the test run in those tests which create one.


- help: displays usage information for a test specified with the --test option.

### 参数说明

sysbench oltp测试创建的表名称为`sbtest+序号`。

```shell
--test：指定测试模式对应的lua文件，这个装好sysbench就有且这是0.5新增，0.4只需直接--test=oltp即可。  
--db-driver：指定驱动，默认为Mysql
--oltp-secondary：测试表将使用二级索引KEY xid (ID) 替代 PRIMARY KEY (ID)，innodb引擎内部为每个表 创建唯一6字节的主键索引 
--oltp-auto-inc：设置id列为auto-incremental，值为on或off，默认为on
--oltp-dist-type：指定随机取样类型，默认为special，允许的值：uniform、gauss、special
--oltp-dist-pct：记录读取百分比
--oltp-dist-res：分配的概率
--oltp-read-only：执行仅仅SELECT测试，默认off
--oltp-skip-trx=[on|off]：省略begin/commit语句。默认是off
--oltp-tables-count的数量应该是--num-threads的倍数，指定测试过程中表的个数，0.5新增，0.4整个测试过程只有一个表。
--oltp-table-size：指定表的大小，如果指定1000，那么它会往表里初始化1000条数据  
--max-time=8000：这个命令跑多长时间，单位秒，需要设置--max-request为0，与之相反的是指定请求数--max-requests  
--max-requests：指定请求数。
--max-time 如果使用，需要设置--max-request为0，单位秒
--myisam-max-rows：指定Myisam表的MAX_ROWS选项
--mysql-db=test1  指定在哪个数据库创建测试表，默认为sbtest库，需要提前创建好
--mysql-host=$host --mysql-port=$port  --mysql-user=test --mysql-password=test 这几个表示被测试的MySQL实例信息，因为需要连数据库 
--mysql-table-engine：指定存储引擎，如myisam，innodb，heap，ndbcluster，bdb，maria，falcon，pbxt
--num-threads：测试过程中并发线程数，看测试要求来定并发压力，每个线程将选择一个随机的表。  
--rand-init=on：是否随机初始化数据，如果不随机化那么初始好的数据每行内容除了主键不同外其他完全相同。  
--rand-type=special：数据分布模式，special表示存在热点数据，uniform表示非热点数据模式，还有其他几个选项。  
--rand-spec-pct=5：这个与上面那个选项相关，热点数据的百分比，我们公司的一个应用测试出来是4.9%的热点数据。  
--report-interval=10：每隔多久打印一次统计信息，单位秒，0.5新增
```

### oltp测试

oltp 基准测试模拟了一个简单的事物处理系统的工作负载。oltp测试需要经历prepare,run,cleanup三个阶段。prepare是一个准备过程，比如测oltp需要load数据到表里，run是真正的测试过程，cleanup是清除过程，比如run完了之后会需要清理一些测试过程中遗留下来的东西等等。

基本步骤：

1）创建测试数据库

2）prepare && run && cleanup

```shell
sysbench --test=${OLTP_LUA} --oltp-table-size=${OLTP_TABLE_SIZE} --oltp-table-count=${OLTP_TABLE_COUNT} --mysql-user=${OLTP_DB_USER} --mysql-password=${OLTP_DB_PASSWORD} --mysql-host=${OLTP_DB_HOST} --mysql-port=${OLTP_DB_PORT} --mysql-socket=${OLTP_DB_SOCKET} --mysql-db=${OLTP_DB} --mysql-table-engine=${OLTP_DB_ENGINE} --rand-init=on  --rand-type=special --rand-spec-pct=5 --report-interval=10 --max-time=${MAX_TIME} --max-requests=${MAX_REQUEST} \
[prepare|run|cleanup]
```

注意最后一行，一项测试开始前需要用prepare来准备好表和数据，run执行真正的压测，cleanup用来清除数据和表。

3）删除测试数据库

prepare, run, cleanup这三个语句的参数可以是用一模一样的，只是最后的sysbench command不同。但是很多参数对具体某个命令是不起作用的，比如在prepare的时候--max-time（这个命令运行多长时间）不起作用，因为它最终一定要把准备工作做好。

### 运行日志解释

```
Running the test with following options:
Number of threads: 1
Report intermediate results every 10 second(s)
Initializing random number generator from timer.

Random number generator seed is 0 and will be ignored

Initializing worker threads...

Threads started!

[  10s] threads: 1, tps: 130.69, reads: 1829.75, writes: 522.76, response time: 13.19ms (95%), errors: 0.00, reconnects:  0.00
[  20s] threads: 1, tps: 124.80, reads: 1748.10, writes: 499.20, response time: 15.37ms (95%), errors: 0.00, reconnects:  0.00
[  30s] threads: 1, tps: 114.00, reads: 1595.39, writes: 456.00, response time: 10.74ms (95%), errors: 0.00, reconnects:  0.00
[  40s] threads: 1, tps: 118.90, reads: 1665.30, writes: 475.60, response time: 12.26ms (95%), errors: 0.00, reconnects:  0.00
[  50s] threads: 1, tps: 130.80, reads: 1831.49, writes: 523.20, response time: 8.87ms (95%), errors: 0.00, reconnects:  0.00
[  60s] threads: 1, tps: 138.30, reads: 1934.80, writes: 553.20, response time: 10.13ms (95%), errors: 0.00, reconnects:  0.00
[  70s] threads: 1, tps: 131.90, reads: 1847.79, writes: 527.60, response time: 8.59ms (95%), errors: 0.00, reconnects:  0.00
```

说明：

> tps表示10s内的平均事务数，reads/s表示select语句在10s内平均的执行数量，writes/s表示update、insert、delete语句在10s内平均的执行数量，response time表示95%语句的平均响应时间

```shell
OLTP test statistics: 
    queries performed:
        read:                            19057346 #总select语句数量
        write:                           5444956  #总update、insert、delete语句数量
        other:                           2722478  #为commit、unlock tables以及其他mutex的数量
        total:                           27224780 # 全部总数
    transactions:                        1361239 (2268.17 per sec.) #每秒事务数(TPS)
    deadlocks:                           0      (0.00 per sec.) #发生死锁总数
    read/write requests:                 24502302 (40827.01 per sec.) #读写总数(每秒读写次数)
    other operations:                    2722478 (4536.33 per sec.) # 其他操作总数(每秒其他操作次数)
    
General statistics:
    total time:                          600.1494s #总执行时间，如果使用了 max-request参数，可以关注下这个结果
    total number of events:              1361239 #共发生多少事务数
    total time taken by event execution: 307190.3628s
    response time: #响应时长统计
         min:                                  7.13ms
         avg:                                225.67ms
         max:                               1471.84ms  #最大响应时间
         approx.  95 percentile:             440.34ms  #95%的语句的平均响应时间

Threads fairness:
    events (avg/stddev):           2658.6699/50.08
    execution time (avg/stddev):   599.9812/0.29
```

说明

> transactions代表测试结果的评判标准是`transactions`(tps, 每秒事务数)，可以对数据库进行调优后，再使用sysbench对OLTP进行测试，看看TPS是不是会有所提高。



### 优缺点

sysbench支持的测试对象较多，提供可调参数也较多，但是它有一个巨大的缺陷---表结构太简单：

```sql
CREATE TABLE `sbtest1` (  
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,  
  `k` int(10) unsigned NOT NULL DEFAULT '0',  
  `c` char(120) NOT NULL DEFAULT '',  
  `pad` char(60) NOT NULL DEFAULT '',  
  PRIMARY KEY (`id`),  
  KEY `k_1` (`k`)  
) ENGINE=InnoDB AUTO_INCREMENT=300000001 DEFAULT CHARSET=utf8 MAX_ROWS=1000000 | 
```

仅仅三个字段，所以很多时候它并不能模拟实际线上的一些应用。但是它还是有很多用处的。第一，利用它做对比测试还不错，因为两个东西都用它测至少测试标准是一样的。第二，测产品稳定性、抗压性，假如你做了一个存储引擎，或是对MySQL打了补丁，那么利用sysbench跑上几天甚至几星期看是否会挂掉。



### 常见问题

1) 无法加载`libmysqlclient.so.18`

> ./sysbench: error while loading shared libraries: libmysqlclient.so.18: cannot open shared object file: No such file or directory

**A:** 添加mysql的lib路径到系统lib查找路径中。

```shell
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/`whoami`/local/mysql/lib
```

2)无法加载oltp

> PANIC: unprotected error in call to Lua API (cannot open oltp: No such file or directory)

**A**是因为0.5版本改为使用 lua脚本，需要调整为指向oltp.lua的文件。

> The OLTP test in sysbench 0.5 was rewritten in Lua. So the command to run it in 0.5 would be:
>
> `sysbench --test=/path/to/oltp.lua --oltp-table-size=10000 --mysql-db=test --mysql-user=root prepare`
>
> The oltp.lua script can be found in sysbench/tests/db in the source root directory.

# 参考

- [老叶倡议：MySQL压力测试基准值](http://imysql.com/2015/07/28/mysql-benchmark-reference.shtml)
- [sysbench安装、使用、结果解读](http://imysql.com/2014/10/17/sysbench-full-user-manual.shtml)
- [sysbench 0.5 oltp测试笔记](http://my.oschina.net/anthonyyau/blog/290030)
- [MySQL 性能比较测试：MySQL 5.6 GA -vs- MySQL 5.5](http://www.oschina.net/translate/mysql-performance-compare-between-5-6-and-5-5?p=1#comments)
- [使用sysbench对mysql压力测试](http://seanlook.com/2016/03/28/mysql-sysbench/)
