# innodb
InnoDB支持事务，同Oracle类似，事务提交需要写redo、undo。采用日志先行的策略，将数据的变更在内存中完成，并且将事务记录成redo，顺序的写入redo日志中，即表示该事务已经完成，就可以返回给客户已提交的信息。但是实际上被更改的数据还在内存中，并没有刷新到磁盘，即还没有落地，当达到一定的条件，会触发checkpoint，将内存中的数据（page）合并写入到磁盘，这样就减少了离散写、IOPS，提高性能。
在这个过程中，如果服务器宕机了，内存中的数据丢失，当重启后，会通过redo日志进行recovery重做。确保不会丢失数据。因此只要redo能够实时的写入到磁盘，InnoDB就不会丢数据。

## 参数
innodb_flush_log_at_trx_commit

    0 每秒 write cache & flush disk
    1 每次commit都 write cache & flush disk
    2 每次commit都 write cache，然后根据innodb_flush_log_at_timeout（默认为1s）时间 flush disk
从这三个配置来看，显然innodb_flush_log_at_trx_commit=1最为安全，因为每次commit都保证redo写入了disk。但是这种方式性能对DML性能来说比较低，在我们的测试中发现，如果设置为2，DML性能要比设置为1高10倍左右。

参考：

- [InnoDB Startup Options and System Variables](https://dev.mysql.com/doc/refman/5.6/en/innodb-parameters.html#sysvar_innodb_max_dirty_pages_pct_lwm)

# MyISAM丢数据
MyISAM存储引擎在我们的生产中用的并不多，但是系统的数据字典表元数据等都是存储在MyISAM引擎下。
MyISAM不支持事务，且没有data cache，所有DML操作只写到OS cache中，flush disk操作均由OS来完成，因此如果服务器宕机，则这部分数据肯定会丢失。

# 主从复制不一致
MySQL主库在事务提交时写binlog，并通过sync_binlog参数来控制binlog刷新到磁盘“落地”，而备库通过IO线程从主库读取binlog，并记录到本地的relay log中，由本地的SQL线程再将relay log的数据应用到本地数据库.

## binlog刷新机制
master写binlog与innodb引擎写redo类似，也有参数控制：sync_binlog

    = 0 表示MySQL不控制binlog的刷新，由文件系统自己控制它的缓存的刷新
    > 0 表示每sync_binlog次事务提交，MySQL调用文件系统的刷新操作将缓存刷下去
其中最安全的就是=1，表示每次事务提交，MySQL都会把binlog缓存刷下去，这样在掉电等情况下，系统才有可能丢失1个事务的数据。当sync_binlog设置为1，对系统的IO消耗也是非常大的。

## 内部XA事务原理
MySQL的存储引擎与MySQL服务层之间，或者存储引擎与存储引擎之间的分布式事务，称之为内部XA事务。最为常见的内部XA事务存在与binlog与InnoDB存储引擎之间。在事务提交时，先写二进制日志，再写InnoDB存储引起的redo日志。对于这个操作要求必须是原子的，即需要保证两者同时写入，内部XA事务机制就是保证两者的同时写入。

## master库写redo、binlog不实时而发生丢数据的场景
上面我们介绍了MySQL的内部XA事务流程，但是这个流程并不是天衣无缝的，redo的ib_logfile与binlog日志如果被设置非实时flush，就有可能存在丢数据的情况。

1. redo的trx_prepare未写入，但binlog写入，造成从库数据量比主库多。
2. redo的trx_prepare与commit都写入了，但是binlog未写入，造成从库数据量比主库少。

<font color="red">从目前来看，只能牺牲性能去换取数据的安全性，必须要设置redo和binlog为实时刷盘，如果对性能要求很高，则考虑使用SSD.</font>

For durability and consistency in a replication setup that uses InnoDB with transactions:

- If binary logging is enabled, set sync_binlog=1. According to the MySQL Documentation on [sync_binlog](http://dev.mysql.com/doc/refman/5.5/en/replication-options-binary-log.html#sysvar_sync_binlog): A value of 1 is the safest choice because in the event of a crash you lose at most one statement or transaction from the binary log. However, it is also the slowest choice (unless the disk has a battery-backed cache, which makes synchronization very fast).
- Always set innodb_flush_log_at_trx_commit=1.

## slave库写redo、binlog不实时丢数据的场景
master正常，但是slave出现异常的情况下宕机，这个时候会出现什么样的情况呢？如果数据丢失，slave的SQL线程还会重新应用吗？这个我们需要先了解SQL线程的机制。

slave读取master的binlog日志后，需要落地3个文件：relay log、relay log info、master info：

    relay log：即读取过来的master的binlog，内容与格式与master的binlog一致
    relay log info：记录SQL Thread应用的relay log的位置、文件号等信息
    master info：记录IO Thread读取master的binlog的位置、文件号、延迟等信息
因此如果当这3个文件如果不及时落地，则主机crash后会导致数据的不一致。

在MySQL 5.6.2之前，slave记录的master信息以及slave应用binlog的信息存放在文件中，即master.info与relay-log.info。在5.6.2版本之后，允许记录到table中，参数设置如下：

    master-info-repository  = TABLE 
    relay-log-info-repository = TABLE 
对应的表分别为mysql.slave_master_info与mysql.slave_relay_log_info，且这两个表均为innodb引擎表。

master info与relay info还有3个参数控制刷新：

    sync_relay_log：默认为10000，即每10000次sync_relay_log事件会刷新到磁盘。为0则表示不刷新，交由OS的cache控制。
    sync_master_info:若master-info-repository为FILE，当设置为0，则每次sync_master_info事件都会刷新到磁盘，默认为10000次刷新到磁盘；若master-info-repository为TABLE，当设置为0，则表不做任何更新，设置为1，则每次事件会更新表 #默认为10000
    sync_relay_log_info：若relay_log_info_repository为FILE，当设置为0，交由OS刷新磁盘，默认为10000次刷新到磁盘；若relay_log_info_repository为TABLE，且为INNODB存储，则无论为任何值，则都每次evnet都会更新表。

建议参数设置如下：

    sync_relay_log = 1
    sync_master_info = 1
    sync_relay_log_info = 1
    master-info-repository  = TABLE
    relay-log-info-repository = TABLE

当这样设置，导致调用fsync()/fdatasync()随着master的事务的增加而增加，且若slave的binlog和redo也实时刷新的话，会带来很严重的IO性能瓶颈。

## master宕机后无法及时恢复造成的数据丢失
当master出现故障后，binlog未及时传到slave，或者各个slave收到的binlog不一致。且master无法在第一时间恢复，这个时候怎么办？
如果master不切换，则整个数据库只能只读，影响应用的运行。
如果将别的slave提升为新的master，那么原master未来得及传到slave的binlog的数据则会丢失，并且还涉及到下面2个问题。

    1.各个slave之间接收到的binlog不一致，如果强制拉起一个slave，则slave之间数据会不一致。
    2.原master恢复正常后，由于新的master日志丢弃了部分原master的binlog日志，这些多出来的binlog日志怎么处理，重新搭建环境？

对于上面出现的问题，一种方法是确保binlog传到从库，或者说保证主库的binlog有多个拷贝。第二种方法就是允许数据丢失，制定一定的策略，保证最小化丢失数据。

1.确保binlog全部传到从库
方案一：使用semi sync（半同步）方式，事务提交后，必须要传到slave，事务才能算结束。对性能影响很大，依赖网络适合小tps系统。
方案二：双写binlog，通过DBDR OS层的文件系统复制到备机，或者使用共享盘保存binlog日志。
方案三：在数据层做文章，比如保证数据库写成功后，再异步队列的方式写一份，部分业务可以借助设计和数据流解决。

2.保证数据最小化丢失
上面的方案设计及架构比较复杂，如果能容忍数据的丢失，可以考虑使用淘宝的TMHA复制管理工具。
当master宕机后，TMHA会选择一个binlog接收最大的slave作为master。当原master宕机恢复后，通过binlog的逆向应用，把原master上多执行的事务回退掉。

参考

-  [MySQL丢数据及主从数据不一致的场景](http://blog.itpub.net/25704976/viewspace-1318714/)
