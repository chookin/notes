## myisam 与 innodb 的区别
- innodb支持事务、外键、行级锁，而myisam不支持；myisam只有表级锁；
- innodb适于写多读少，而myisam适于读多写少；
- innodb不支持全文索引，而myisam支持；
- innodb采用日志先行策略，先将操作记录到redo，之后完成在内存中的变更；
- 不要join查询myisam和innodb表；因为，若联合查询，innodb表将会被锁住整张表；对于myisam表，一旦有写操作，myisam表的读操作将被挂起，这也将导致innodb表查询被挂起；

