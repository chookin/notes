## myisam 与 innodb 的区别
- innodb支持事务、外键、行级锁，而myisam不支持；myisam只有表级锁；
- innodb适于写多读少，而myisam适于读多写少；
- innodb不支持全文索引，而myisam支持；
- innodb采用日志先行策略，先将操作记录到redo，之后完成在内存中的变更；
- 不要join查询myisam和innodb表；因为，若联合查询，innodb表将会被锁住整张表；对于myisam表，一旦有写操作，myisam表的读操作将被挂起，这也将导致innodb表查询被挂起；

# sql
## mysql
1, mysql datetime、date、time、timestamp区别
mysql数据库用于表示时间的分别是 date、datetime、time、timestamp和year。

- date ：“yyyy-mm-dd”格式表示的日期值，“1000-01-01”到“9999-12-31” 3字节
- time ：“hh:mm:ss”格式表示的时间值，“-838:59:59”到“838:59:59” 3字节
- datetime： “yyyy-mm-dd hh:mm:ss”格式，“1000-01-01 00:00:00” 到“9999-12-31 23:59:59” 8字节
- timestamp： “yyyymmddhhmmss”格式表示的时间戳值，19700101000000 到2037 年的某个时刻 4字节
- year： “yyyy”格式的年份值，1901 到2155 1字节

2，mysql中key 、primary key 、unique key 与index区别

- key 是数据库的物理结构，它包含两层意义和作用，一是约束（偏重于约束和规范数据库的结构完整性），二是索引（辅助查询用的）
- primary key 有两个作用，一是约束作用（constraint），用来规范一个存储主键和唯一性，但同时也在此key上建立了一个unique index；
- index则处于实现层面，比如可以对表个的任意列建立索引，那么当建立索引的列处于SQL语句中的Where条件中时，就可以得到快速的数据定位，从而快速检索；
- index是数据库的物理结构，它只是辅助查询的，它创建时会在另外的表空间（mysql中的innodb表空间）以一个类似目录的结构存储；
- unique index，index中的一种，建立了unique index表示此列数据不可重复；
- 一个表只能有一个primary key，但可以有多个UNIQUE KEY；
- unique key 也有两个作用，一是约束作用（constraint），规范数据的唯一性，但同时也在这个key上建立了一个唯一索引；
- foreign key也有两个作用，一是约束作用（constraint），规范数据的引用完整性，但同时也在这个key上建立了一个index；
- mysql的key是同时具有constraint和index的意义；
- oracle上建立外键，不会自动建立index；

参考：[mysql中key 、primary key 、unique key 与index区别](http://blog.csdn.net/nanamasuda/article/details/52543177)

## 问题
1, where与group by

```sql
 select statday, rgnid, placeholdid, sum(dispv), sum(clkpv) from basic_stat_d group by placeholdid,rgnid where statday = "20170805";
```
该语句执行报错：

```
ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'where statday = "20170805"' at line 9
```

Q: 这个查询语句有什么问题?
A: group需要在后面。

2, join

```sql
SELECT
    *
FROM
    projectinfo
LEFT JOIN projectmediamap ON projectinfo.projectid = projectmediamap.projectid
LEFT JOIN mediainfo ON projectmediamap.mediaid = mediainfo.mediaid
LEFT JOIN mediaplaceholdmap ON mediainfo.mediaid = mediaplaceholdmap.mediaid
LEFT JOIN placeholdinfo ON mediaplaceholdmap.placeholdid = placeholdinfo.id
WHERE
    projectinfo.projectid = 88;
```

Q: 项目id为88的广告位数是9个，这个是查询项目对应广告位的sql，执行的结果竟然546，很多重复。
A: 使用projectmediamap导致不属于该项目的广告位也被join进去了，需要改成如下形式。

```sql
SELECT
    *
FROM
    projectinfo

LEFT JOIN projectplaceholdmap ON projectinfo.projectid = projectplaceholdmap.projectid
LEFT JOIN placeholdinfo ON projectplaceholdmap.placeholdid = placeholdinfo.id
LEFT JOIN mediaplaceholdmap ON mediaplaceholdmap.placeholdid = placeholdinfo.id
LEFT JOIN mediainfo ON mediaplaceholdmap.mediaid = mediainfo.mediaid
WHERE
    projectinfo.projectid = 88;
```
join时需要注意用于匹配的key，
