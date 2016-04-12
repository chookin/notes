# 配置文件

- schema.xml 配置抽象数据源、配置数据库节点、配置数据包切分
- server.xml 配置mycat的权限管理

# 访问
## 登录

    $ mysql --protocol=tcp -u test -p -P 8066
    Enter password:
    Welcome to the MySQL monitor.  Commands end with ; or \g.
    Your MySQL connection id is 6
    Server version: 5.6.29-mycat-1.5-GA-20160201172658 MyCat Server (OpenCloundDB)

    Copyright (c) 2000, 2016, Oracle and/or its affiliates. All rights reserved.

    Oracle is a registered trademark of Oracle Corporation and/or its
    affiliates. Other names may be trademarks of their respective
    owners.

    Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

    mysql> show databases;
    +----------+
    | DATABASE |
    +----------+
    | TESTDB   |
    +----------+
    1 row in set (0.00 sec)

    mysql> use TESTDB;
    Reading table information for completion of table and column names
    You can turn off this feature to get a quicker startup with -A

    Database changed
    mysql> show tables;
    +------------------+
    | Tables in TESTDB |
    +------------------+
    | travelrecord     |
    +------------------+
    1 row in set (0.00 sec)

看来mycat对数据源进行了汇总，统一为一个逻辑库，且所有的数据表必须在schema.xml文件中配置。

## 表创建测试
 
 ```sql
mysql> create table travelrecord (id int not null primary key,name varchar(100),sharding_id int not null);
Query OK, 0 rows affected (0.01 sec)

mysql> explain create table travelrecord (id int not null primary key,name varchar(100),sharding_id int not null);
+-----------+----------------------------------------------------------------------------------------------------+
| DATA_NODE | SQL                                                                                                |
+-----------+----------------------------------------------------------------------------------------------------+
| dn1       | create table travelrecord (id int not null primary key,name varchar(100),sharding_id int not null) |
+-----------+----------------------------------------------------------------------------------------------------+
1 row in set (0.02 sec)
 ```

 注意：所创建的表必须在schema.xml中预先配置好，否则创建失败。

