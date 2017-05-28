[TOC]

# MySQL丢数据情境

(2016-07, created by [Zhu Yin](mailto:zhuyin@chinamobile.com))

---

# 问题

当我们提交一个事务，数据库要么告诉我们事务提交成功了，要么告诉我们提交失败。

数据库为了效率等原因，数据只保存在内存中，没有真正的写入到磁盘上去。如果数据库响应为“提交成功”，但是由于数据库挂掉、操作系统、数据库主机等任何问题导致这次“提交成功”的事务对数据库的修改没有生效，那么我们认为这个事务的数据丢失了。

# InnoDB丢数据的机理

## InnoDB事务基本原理

InnoDB的事务提交需要写入undo log，redo log，以及真正的数据页。InnoDB跟Oracle非常类似，使用日志先行的策略，将数据的变更在内存中完成，并且将事务记录成redo，转换为顺序IO高效的提交事务。这里日志先行，也就是说，日志记录到数据库以后，对应的事务就可以返回给用户，表示事务完成。但是实际上，这个数据可能还只在内存中修改完成，并没有刷到磁盘上去，俗称“还没有落地”。内存是易失的，如果在数据“落地”之前，机器挂了，那么这部分数据就丢失了。而数据库怎么保证这些数据还是能够找回来呢？否则，用户提交了一个事务，数据库响应请求并回应为事务“提交成功”，数据库重启以后，这部分修改数据的却回到了事务提交之前的状态。

InnoDB利用redo来保证数据一致性的。如果你有从数据库新建一直到数据库挂掉的所有redo，那么你可以将数据完完整整的重新build出来。但是这样的话，速度肯定很慢。所以一般每隔一段时间，数据库会做一个checkpoint的操作，做checkpoint的目的就是为了让该时刻之前的所有数据都”落地”。这样的话，数据库挂了，内存中的数据丢了，不用从最原始的位置开始恢复，而只需要从最新的checkpoint来恢复。将已经提交的所有事务变更到具体的数据块中，将那些未提交的事务回滚掉。

## InnoDB redo日志

**事务的redo日志是否刷到磁盘是事务数据是否丢失的关键**。InnoDB**为了保证日志刷写的高效，使用了内存的log buffer**，另外，由于InnoDB大部分情况下使用的是文件系统，而**linux文件系统本身也是有buffer的**，不是直接使用物理块设备，这样的话就有两种丢失日志的可能性：

1. 日志保存在log_buffer中，服务挂了，对应的事务数据就丢失了；
2. 日志从log buffer刷到了linux文件系统的buffer，机器挂掉了，对应的事务数据就丢失了。

当然，文件系统的缓存刷新到硬件设备，还有可能被raid卡的缓存，甚至是磁盘本身的缓存保留，而不是真正的写到磁盘介质上去了，不过这在MySQL的控制之外了，在此不做讨论。

## innodb_flush_log_at_trx_commit

有一个参数用于设置这两个缓存的刷新：[innodb_flush_log_at_trx_commit](http://dev.mysql.com/doc/refman/5.5/en/innodb-parameters.html#sysvar_innodb_flush_log_at_trx_commit) 。`innodb_flush_log_at_trx_commit`有0、1、2三个取值，分别代表不同的redo log落地策略。

- 默认，innodb_flush_log_at_trx_commit=1，表示在每次事务提交的时候，都把log buffer刷到文件系统中去，并且调用文件系统的“flush”操作将缓存刷新到磁盘上去。这样的话，数据库对IO的要求就非常高了，如果底层的硬件提供的IOPS比较差，那么MySQL数据库的并发很快就会由于硬件IO的问题而无法提升。
- innodb_flush_log_at_trx_commit=0时，每隔一秒把log buffer刷到文件系统中去，并且调用文件系统的“flush”操作将缓存刷新到磁盘上去。这样的话，就减少了离散写、IOPS，提高性能，但是可能丢失1秒的事务数据。
- innodb_flush_log_at_trx_commit=2时，在每次事务提交的时候会把log buffer刷到文件系统中去，但是每隔一秒调用文件系统的“flush”操作将缓存刷新到磁盘上去。如果只是MySQL数据库挂掉了，由于文件系统没有问题，那么对应的事务数据并没有丢失。只有在数据库所在主机崩溃的情况下，数据库可能丢失1秒的事务数据。这样的好处就是，减少了事务数据丢失的概率，而对底层硬件的IO要求也没有那么高(log buffer写到文件系统中，一般只是从log buffer的内存转移到文件系统的内存缓存中，对底层IO没有压力)。MySQL 5.6.6以后，这个“1秒”的刷新还可以用innodb_flush_log_at_timeout 来控制。

为了提高效率，保证并发，牺牲一定的数据一致性，`innodb_flush_log_at_trx_commit`可以设置为0和2。在大部分应用环境中，应用对数据的一致性要求并没有那么高，所以很多MySQL DBA会设置`innodb_flush_log_at_trx_commit=2`，这样的话，数据库就存在丢失最多1秒的事务数据的风险。

下面简要记录`innodb_flush_log_at_trx_commit`不同取值下的效果：

```
0 每秒 write filesystem & flush disk
1 默认值，每次commit都 write filesystem & flush disk
2 每次commit都 write filesystem，然后根据innodb_flush_log_at_timeout（默认为1s）时间 flush disk
```

# MyISAM丢数据的机理

MyISAM存储引擎在生产中用的不多。MyISAM不支持事务，且没有data cache，所有DML操作只写到OS cache中，flush disk操作均由OS来完成，因此如果服务器宕机，则这部分数据肯定会丢失。

# 主从复制 binlog

## MySQL复制原理简介

MySQL复制原理如下：**MySQL主库在事务提交时写binlog，并通过`sync_binlog`参数来控制binlog刷新到磁盘“落地”**；而备库通过IO线程从主库拉取binlog，并记录到本地的relay log中，再由本地的SQL线程将relay log中的数据应用到本地数据库中。

异步的方式下，几个线程都是独立的，相互不依赖。

而在半同步的情况下，主库的事务提交需要保证至少有一个备库的IO线程已经拉到了数据，这样保证了至少有一个备库有最新的事务数据，避免了数据丢失。这里称为半同步，是因为主库并不要求SQL线程已经执行完成了这个事务。

半同步在MySQL 5.5才开始提供，并且可能引起并发和效率的一系列问题，比如只有一个备库，备库挂掉了，那么主库在事务提交10秒(rpl_semi_sync_master_timeout控制)后，才会继续，之后变成传统的异步方式。所以目前在生产环境下使用半同步的比较少。

**在异步方式下，保证数据不丢失就是如何保证主库的binlog不丢失**。尽快将binlog落地，这样就算数据库挂掉了，我们还可以通过binlog来将丢失的部分数据手工同步到从库。

## sync_binlog

类似于`innodb_flush_log_at_trx_commit`，MySQL使用`sync_binlog`参数来控制数据库binlog刷写到磁盘。虽然binlog也有binlog cache，但是MySQL并没有控制binlog cache同步到文件系统缓存。所以我们这里不涉及binlog cache。

- 默认`sync_binlog=0`，表示MySQL不控制binlog的刷新，由文件系统自己控制它的缓存刷新；
- 如果`sync_binlog>0`，表示每sync_binlog次事务提交，MySQL调用文件系统的刷新操作将缓存刷下去；
- **最安全的就是`sync_binlog=1`了，表示每次事务提交，MySQL都会把binlog刷写到磁盘**。这样的话，在数据库所在服务器崩溃的情况下，系统才有可能丢失1个事务的数据。

binlog是顺序IO，若设置`sync_binlog=1`，多个事务同时提交，将对MySQL的IO性能影响较大。所以很多MySQL DBA设置的sync_binlog并不是最安全的1，而是100或者是0。这样牺牲一定的一致性，可以获得更高的并发和性能。

> If the value of this variable is greater than 0, the MySQL server synchronizes its binary log to disk (using fdatasync()) after every [sync_binlog](http://dev.mysql.com/doc/refman/5.5/en/replication-options-binary-log.html#sysvar_sync_binlog) writes to the binary log. **The default value of sync_binlog is 0**, which does no synchronizing to disk—in this case, the server relies on the operating system to flush the binary log's contents from time to time as for any other file. A value of 1 is the safest choice because in the event of a crash you lose at most one statement or transaction from the binary log.

# 主从复制和InnoDB协同

redo log和 binlog这两种log都影响数据丢失，但是它们分别在InnoDB和MySQL server层维护。由于一个事务可能使用两种事务引擎，所以MySQL用两段式事务提交来协调事务提交。

## 内部XA事务原理
MySQL的存储引擎与MySQL服务层之间，或者存储引擎与存储引擎之间的分布式事务，称之为内部XA事务。最为常见的内部XA事务存在与binlog与InnoDB存储引擎之间。在事务提交时，先写二进制日志binlog，再写InnoDB存储引起的redo日志。对于这个操作要求必须是原子的，即需要保证两者同时写入，内部XA事务机制就是保证两者的同时写入。

## innodb_support_xa

[innodb_support_xa](http://dev.mysql.com/doc/refman/5.5/en/innodb-parameters.html#sysvar_innodb_support_xa)可以开关InnoDB的XA两段式事务提交。默认情况下，`innodb_support_xa=true`，支持XA两段式事务提交。此时MySQL首先要求innodb prepare，对应的redolog 将写入log buffer；如果有其他的引擎，其他引擎也需要做事务提交的prepare，然后MySQL server将binlog将写入；并通知各事务引擎真正commit；InnoDB将commit标志写入，完成真正的提交，响应应用程序为提交成功。这个过程中任何出错将导致事务回滚，响应应用程序为提交失败。也就是说，在这种情况下，基本不会出错。

但是由于xa两段式事务提交导致多余flush等操作，性能影响会达到10%，所有为了提高性能，有些DBA会设置innodb_support_xa=false。这样的话，redolog和binlog将无法同步，可能存在事务在主库提交，但是没有记录到binlog的情况。这样也有可能造成事务数据的丢失。

> innodb_support_xa Enables InnoDB support for two-phase commit in XA transactions, causing an extra disk flush for transaction preparation. **This setting is the default**. The XA mechanism is used internally and is essential for any server that has its binary log turned on and is accepting changes to its data from more than one thread. If you turn it off, transactions can be written to the binary log in a different order from the one in which the live database is committing them. This can produce different data when the binary log is replayed in disaster recovery or on a replication slave. Do not turn it off on a replication master server unless you have an unusual setup where only one thread is able to change data.
>
> For a server that is accepting data changes from only one thread, it is safe and recommended to turn off this option to improve performance for InnoDB tables. For example, you can turn it off on replication slaves where only the replication SQL thread is changing data.
>
> You can also turn off this option if you do not need it for safe binary logging or replication, and you also do not use an external XA transaction manager.

# 主从集群丢数据的情景

## master库写redo、binlog不实时而发生丢数据的场景

上面我们介绍了MySQL的内部XA事务流程，但是这个流程并不是天衣无缝的，redo的ib_logfile与binlog日志如果被设置非实时flush，就有可能存在丢数据的情况。

1. redo的trx_prepare未写入，但binlog写入，造成从库数据量比主库多。
2. redo的trx_prepare与commit都写入了，但是binlog未写入，造成从库数据量比主库少。

<font color="red">从目前来看，只能牺牲性能去换取数据的安全性，必须要设置redo和binlog为实时刷盘，如果对性能要求很高，则考虑使用SSD.</font>

> For durability and consistency in a replication setup that uses InnoDB with transactions:
>
> - If binary logging is enabled, set sync_binlog=1. According to the MySQL Documentation on [sync_binlog](http://dev.mysql.com/doc/refman/5.5/en/replication-options-binary-log.html#sysvar_sync_binlog): A value of 1 is the safest choice because in the event of a crash you lose at most one statement or transaction from the binary log. However, it is also the slowest choice (unless the disk has a battery-backed cache, which makes synchronization very fast).
> - Always set innodb_flush_log_at_trx_commit=1.

## slave库写relay log不实时丢数据的场景
master正常，但是slave出现异常的情况下宕机，这个时候会出现什么样的情况呢？如果数据丢失，slave的SQL线程还会重新应用吗？这个我们需要先了解SQL线程的机制。

slave读取master的binlog日志后，需要落地3个文件：relay log、relay log info、master info：

    relay log：即读取过来的master的binlog，内容与格式与master的binlog一致
    relay log info：记录SQL Thread应用的relay log的位置、文件号等信息
    master info：记录IO Thread读取master的binlog的位置、文件号、延迟等信息
因此，**如果这3个文件没有及时落地，则从库主机crash后可能会发生数据的不一致**。

在MySQL 5.6.2之前，slave记录的master信息以及slave应用binlog的信息存放在文件中，默认是`master.info`与`relay-log.info`。在5.6.2版本之后，允许记录到table中，参数设置如下：

    master_info_repository    = TABLE 
    master_info_repository = TABLE 
对应的表分别为`mysql.slave_master_info`与`mysql.slave_relay_log_info`，且这两个表均为innodb引擎表。

master info与relay info有3个参数控制刷新：

1）[sync_relay_log](https://dev.mysql.com/doc/refman/5.6/en/replication-options-slave.html#sysvar_sync_relay_log)：为0则表示不刷新，交由OS的cache控制；为大于0，则每`sync_relay_log`次事件会刷新relay log到磁盘。

> Prior to MySQL 5.6.6, 0 was the default for this variable. In MySQL 5.6. and later, the default is 10000.
>
> A value of 1 is the safest choice because in the event of a crash you lose at most one event from the relay log. However, it is also the slowest choice (unless the disk has a battery-backed cache, which makes synchronization very fast).

2）[sync_master_info](https://dev.mysql.com/doc/refman/5.6/en/replication-options-slave.html#sysvar_sync_master_info)：若`master_info_repository`为FILE，当设置为0则表示不刷新，交由OS的cache控制；当设置为大于0，则每`sync_master_info`次事件刷写master.info。若`master_info_repository`为TABLE，当设置为0，则表不做任何更新，设置为1，则每次事件会更新表；

> The default value for sync_master_info is 10000 as of MySQL 5.6.6, 0 before that.

3）[sync_relay_log_info](https://dev.mysql.com/doc/refman/5.6/en/replication-options-slave.html#sysvar_sync_relay_log_info)：若`master_info_repository`为FILE，当设置为0则表示不刷新，交由OS的cache控制；当设置为大于0，则每`sync_master_info`次事件刷写 relay-log.info；若`relay_log_info_repository`为TABLE，且为InnoDB引擎，则每次事务都会更新表。

> The default value for sync_relay_log_info is 10000 as of MySQL 5.6.6, 0 before that.

slave最不易丢数的参数设置如下：

```shell
# 每执行完一个SQL/事务，SLAVE进程更新relay-log.info后，就需要刷到DISK；
sync_relay_log            = 1
sync_master_info          = 1
sync_relay_log_info       = 1

# mysql 5.6.2及之后
master_info_repository    = TABLE
master_info_repository    = TABLE
```

不过上述设置，将导致调用fsync()/fdatasync()随着master事务的增加而增加，且若slave的binlog和redo也实时刷新的话，会带来很严重的IO性能瓶颈。

## master宕机后无法及时恢复造成的数据丢失
当master出现故障后，binlog未及时传到slave，或者各个slave收到的binlog不一致。且master无法在第一时间恢复，这个时候怎么办？
如果master不切换，则整个数据库只能只读，影响应用的运行。
如果将别的slave提升为新的master，那么原master未来得及传到slave的binlog的数据则会丢失，并且还涉及到下面2个问题。

1）各个slave之间接收到的binlog不一致，如果强制拉起一个slave，则slave之间数据会不一致。

2）原master恢复正常后，由于新的master日志丢弃了部分原master的binlog日志，这些多出来的binlog日志怎么处理，重新搭建环境？

对于上面出现的问题，一种方法是确保binlog传到从库，或者说保证主库的binlog有多个拷贝。第二种方法就是允许数据丢失，制定一定的策略，保证最小化丢失数据。

1）确保binlog全部传到从库
方案一：使用semi sync（半同步）方式，事务提交后，必须要传到slave，事务才能算结束。对性能影响很大，依赖网络适合小tps系统。
方案二：双写binlog，通过DBDR OS层的文件系统复制到备机，或者使用共享盘保存binlog日志。
方案三：在数据层做文章，比如保证数据库写成功后，再异步队列的方式写一份，部分业务可以借助设计和数据流解决。

2）保证数据最小化丢失
上面的方案设计及架构比较复杂，如果能容忍数据的丢失，可以考虑使用淘宝的TMHA复制管理工具。
当master宕机后，TMHA会选择一个binlog接收最大的slave作为master。当原master宕机恢复后，通过binlog的逆向应用，把原master上多执行的事务回退掉。

# 总结

为了保证主从集群的可靠性，建议主库设置如下参数：

```shell
sync_binlog                     = 1
innodb_flush_log_at_trx_commit  = 1
innodb_support_xa               = true
```

# 参考

-  [MySQL丢数据及主从数据不一致的场景](http://blog.itpub.net/25704976/viewspace-1318714/)
-  [MYSQL数据丢失讨论](http://hatemysql.com/?p=395)
-  [InnoDB Startup Options and System Variables](https://dev.mysql.com/doc/refman/5.6/en/innodb-parameters.html#sysvar_innodb_max_dirty_pages_pct_lwm)
-  [浅析innodb_support_xa与innodb_flush_log_at_trx_commit](http://blog.csdn.net/zbszhangbosen/article/details/9132833)
-  [MySQL 5.5 replication-options-slave](https://dev.mysql.com/doc/refman/5.5/en/replication-options-slave.html)
