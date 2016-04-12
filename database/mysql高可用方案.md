# 背景

## MySQL数据库的主要问题

- 主库单点问题
• 通过业务功能的写入主库通常只能有1个

## MySQL复制的延迟
MySQL主库在事务提交时写binlog

- 单条SQL
    + 执行(执行时间为T)完直接写入binlog
    + 延迟大概为T
- 一个事务(包括N条)
    * 先缓存到cache,全部执行完写入
    * 延迟为NT

## mysql 切换
- master挂了,如何?
    + 选择新的主库
    + 通知应用切换
    + master恢复之后,如何同步
- 着重问题:
    + 故障是存在的
    + MS数据的一致性保证
    + 新主库的选举 / 应用程序感知

## 对应用透明的常用方法

- Master采用虚IP的方式
    * 前提:备库与主库在同一网段
    * 阿里云的RDS、云聊PHPWind [1] – 腾讯的CDB[2]
- DB对外的接口是DNS
    * 优势:备库与主库可以在不同机房
    * 缺点:受限于DNS,若DNS故障,服务不可用
- [MHA](https://code.google.com/p/mysql-master-ha/): 多个从库之间选择一个主库

# MHA
A primary objective of [MHA](https://code.google.com/p/mysql-master-ha/) is <font color="red">automating master failover and slave promotion within short (usually 10-30 seconds) downtime</font>, without suffering from replication consistency problems, without spending money for lots of new servers, without performance penalty, without complexity (easy-to-install), and without changing existing deployments.

MHA also provides a way for scheduled online master switch: <font color="red">changing currently running master to a new master safely, within a few seconds (0.5-2 seconds) of downtime (blocking writes only)</font>.
MHA provides the following functionality, and can be useful in many deployments where requirements such as high availability, data integrity, almost non-stop master maintenance are desired.

- Automated master monitoring and failover

MHA has a functionality to monitor MySQL master in an existing replication environment, detecting master failure, and doing master failover automatically. <font color="red">Even though some of slaves have not received the latest relay log events, MHA automatically identifies differential relay log events from the latest slave, and applies differential events to other slaves. So all slaves can be consistent.</font> MHA normally can do failover in seconds (<b>9-12 seconds to detect master failure, optionally 7-10 seconds to power off the master machine to avoid split brain, a few seconds for applying differential relay logs to the new master, so total downtime is normally 10-30 seconds</b>). In addition, you can define a specific slave as a candidate master (setting priorities) in a configuration file. Since MHA fixes consistencies between slaves, you can promote any slave to a new master and consistency problems (which might cause sudden replication failure) will not happen.

- Interactive (manual) Master Failover

You can also use MHA for just failover, not for monitoring master. You can use MHA for master failover interactively.

- Non-interactive master failover

Non-interactive master failover (not monitoring master, but doing failover automatically) is also supported. This feature is useful especially when you have already used a software that monitors MySQL master. For example, you can use <b>Pacemaker(Heartbeat)</b> for detecting master failure and virtual ip address takeover, and use MHA for master failover and slave promotion.

- Online switching master to a different host

In many cases, it is necessary to migrate an existing master to a different machine (i.e. the current master has H/W problems on RAID controller or RAM, you want to replace with faster machine, etc). This is not a master crash, but scheduled master maintenance is needed to do that. Scheduled master maintenance causes downtime (at least you can not write master) so should be done as quickly as possible. On the other hand, you should block/kill current running sessions very carefully because consistency problems between different masters might happen (i.e "updating master1, updating master 2, committing master1, getting error on committing master 2" will result in data inconsistency). Both fast master switch and graceful blocking writes are required. MHA provides a way to do that. You can switch master gracefully within 0.5-2 seconds of writer block. In many cases 0.5-2 seconds of writer downtime is acceptable and you can switch master even without allocating scheduled maintenance window. This means you can take actions such as upgrading to higher versions, faster machine, etc much more easily.

# Other Solutions and Issues

## Doing everything manually

MySQL Replication is asynchronous or semi-synchronous. When master crashes, it is possible that some of slaves have not received the latest relay log events, which means each slave might be in different state each other. Fixing consistency problems manually is not trivial. But without fixing consistency problems, replication might not be able to start (i.e. duplicate key error). It is not uncommon to take more than one hour to restart replication manually.

## Single master and single slave
If you have one master and only one slave, "some slaves behind the latest slave" situation never happens. When the master crashes, just let applications send all traffics to the new master. So failover is easy.

```
 M(RW)
 |        --(master crash)-->   M(RW), promoted from S
 S(R) 
```

But there are lots of very serious issues. First, you can not scale out read traffics. In many cases you may want to run expensive operations on one of slaves such as backups, analytic queries, batch jobs. These might cause performance problems on the slave server. If you have only one slave and the slave is crashed, the master has to handle all such traffics.

Second issue is availability. If the master is crashed, only one server (new master) remains, so it becomes single point of failure. To create a new slave, you need to take an online backup, restore it on the new hardware, and start slave immediately. But these operations normally takes hours (or even more than one day to fully catch up replication) in total. On some critical applications you may not accept that the database becomes single point of failure for such a long time. And taking an online backup on master increases i/o loads significantly so taking backups during the peak time is dangerous.

Third issue is lack of extensibility. For example, when you want to create a read-only database on a remote data center, you need at least two slaves, one is a slave on the local data center, the other is a slave on the remote data center. You can not build this architecture if you have only one slave.

### Single slave is actually not enough in many cases.

Master, one candidate master, and multiple slaves
Using "one master, one candidate master, and multiple slaves" architecture is also common. Candidate master is a primary target for the new master if the current master crashes. In some cases it is configured as a read-only master: multi-master configuration.

```
      M(RW)-----M2(R)                      M(RW), promoted from M2
       |                                          |
  +----+----+          --(master crash)-->   +-x--+--x-+
 S(R)     S2(R)                             S(?)      S(?)
                                          (From which position should S restart replication?)
```

But this does not always work as a master failover solution. When current master crashes, the rest slaves might not have received all relay log events, so fixing consistency issues between slaves are still needed like other solutions.

What if you can not accept consistency problems but want to start service immediately? Just start the candidate master as a new master, and drop all the rest slaves. After that you can create new slaves by taking an online backup from the new master. But this approach has the same problem as the above "Single master and single slave" approach. The rest slaves can not be used for read scaling or redundancy purposes.

This architecture is pretty widely used, but not many people fully understand the potential problems described above. When the current master crashes, slaves become inconsistent or even you can't start replication if you simply let slaves start replication from the new master. If you need guarantee consistency, the rest slaves can't be used. Both approaches have serious disadvantages.

By the way, "using two masters (one is read only) and each master having at least one slaves (like below)" is also possible.

```
 M(RW)--M2(R)
 |      |
 S(R)   S2(R)
```

At least one slave can continue replication when current master crashes, but actually there are not so many users adopting this architecture. The biggest disadvantage is complexity. Three-tier replication(M->M2->S2) is used in this architecture. But managing three-tier replication is not easy. For example, if the middle server (M2:candidate master) crashes, the third-tier slave(S2) can't continue replication. In many cases you have to setup both M2 and S2 again. It is also important that you need at least four servers in this architecture.

### Pacemaker + DRBD
Using Pacemaker(Heartbeat)+DRBD+MySQL is a very common HA solution. But this solution also has some serious issues.

One issue is cost, especially if you want to run lots of MySQL replication environments. Pacemaker+DRBD is active/standby solution, so you need one passive master server that does not handle any application traffic. The passive server can not be used for read scaling. Typically you need at least four MySQL servers, one active master, one passive master, two slaves (one of the two for reporting etc).

Second issue is downtime. Since Pacemaker+DRBD is active/standby cluster so if the active server crashes, crash recovery happens on the passive server. This might take very long time, especially if you are not using InnoDB Plugin. Even though you use InnoDB Plugin, it is not uncommon to take a few minutes or more to start accepting connections on the standby server. In addition to crash recovery time, warm-up (filling data into buffer pool) takes significant time after the failover, since on the passive server database/filesystem cache is empty. In practice, you need one or more additional slave servers to handle enough read traffics. It is also important that write performance also drops significantly during warm-up time because cache is empty.

Third issue is write performance drops or consistency problems. To make active/passive HA cluster really work, you have to flush transaction logs(binary log and InnoDB log) to disks at every commit. That is, you have to set innodb-flush-log-at-trx-commit=1 and sync-binlog=1. But currently sync-binlog=1 kills write performance because fsync() is serialized in current MySQL(group commit is broken if sync-binlog is 1). In most cases people do not set sync-binlog=1. But if sync-binlog=1 is not set, when the active master crashes, the new master (the previous passive server) might lose some of binary log events that have already been sent to slaves. Suppose the master was crashed and slave A received up to mysqld-bin.000123 position 1500. If binlog data was flushed to disks only up to position 1000, the new master has mysqld-bin.000123 only up to 1000 and creates new binary log mysqld-bin.000124 at start-up. If this happens, slave A can't continue replication because new master doesn’t have mysqld-bin.000123 position 1500.

Fourth issue is complexity. It is actually not trivial to install/configure Pacemaker and DRBD (especially DRBD) for many users. Configuring DRBD often requires re-creating OS partitions in many deployments, which is not easy for many cases. You also need to have enough expertise on DRBD and Linux kernel layer. If you execute a wrong command (i.e. executing drbdadm -- --overwrite-data-of-peer primary on the passive node), it easily breaks live data. It is also important that once disk i/o layer problem happens when using DRBD, fixing the problem is really difficult for most of DBAs.

### MySQL Cluster
MySQL Cluster is really Highly Available solution, but you have to use NDB storage engine. When you use InnoDB (in most cases), you can't take advantages of MySQL Cluster.

### Semi-Synchronous Replication
Semi-Synchronous replication greatly minimizes a risk of "binlog events exist only on the crashed master" situation. This is really helpful to avoid data loss. But Semi-Synchronous replication does not solve all consistency issues. Semi-Synchronous replication guarantees that at least one (not all) slaves receive binlog events from the master at commmit. There are still possibilities that some of slaves have not received all binlog events. Without applying differential relay log events from the latest slave to non-latest slaves, slaves can not be consistent each other.

MHA takes care of these consistency issues, so by using both Semi-Synchronous replication and MHA, both "almost no data loss" and "slaves consistency" can be achieved.

### Global Transaction ID
The purpose of the global transaction id is basically same as what MHA tries to achieve, but it covers more. MHA works with only two tier replication, but global transaction id covers any tier replication environment, so even though second tier slave fails, you can recover third tier slave. Check Google's global transaction id project for details.

Starting from MySQL 5.6, GTID was supported. Oracle's official tool mysqlfailover supports master failover with GTID. Starting from MHA version 0.56, MHA also supports failover based on GTID. MHA automatically detects whether mysqld is running with GTID or not, and if GTID is enabled, MHA does failover with GTID. If not, MHA does traditional failover with relay logs.

# 参考：

- 淘宝MySQL数据库高可用的设计实现-TMHA
- [MHA](https://code.google.com/p/mysql-master-ha/)
