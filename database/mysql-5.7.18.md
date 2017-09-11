
```sh
wget https://cdn.mysql.com//Downloads/MySQL-5.7/mysql-5.7.18.tar.gz
version=5.7.18
TARGET_PATH=/home/`whoami`/local/mysql-$version
cmake -DCMAKE_INSTALL_PREFIX=$TARGET_PATH -DMYSQL_DATADIR=$TARGET_PATH/data -DSYSCONFDIR=$TARGET_PATH/etc -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_MEMORY_STORAGE_ENGINE=1 -DWITH_READLINE=1 -DMYSQL_UNIX_ADDR=$TARGET_PATH/var/mysql.sock -DMYSQL_TCP_PORT=23306 -DENABLED_LOCAL_INFILE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci
```

```
➜  mysql bin/mysqld --initialize
2017-08-16T09:54:22.345793Z 0 [Warning] TIMESTAMP with implicit DEFAULT value is deprecated. Please use --explicit_defaults_for_timestamp server option (see documentation for more details).
2017-08-16T09:54:22.354228Z 0 [Warning] One can only use the --user switch if running as root

2017-08-16T09:54:22.513301Z 0 [Warning] InnoDB: New log files created, LSN=45790
2017-08-16T09:54:22.534879Z 0 [Warning] InnoDB: Creating foreign key constraint system tables.
2017-08-16T09:54:22.589364Z 0 [Warning] No existing UUID has been found, so we assume that this is the first time that this server has been started. Generating a new UUID: e14808ad-8268-11e7-a4df-1418773c3649.
2017-08-16T09:54:22.589643Z 0 [Warning] Gtid table is not ready to be used. Table 'mysql.gtid_executed' cannot be opened.
2017-08-16T09:54:22.590323Z 1 [Note] A temporary password is generated for root@localhost: w#>3tofKjIuo
```

```sh
bin/mysqld_safe  --defaults-file=etc/my.cnf &
```

使用root用户及初始密码登录mysql，登录成功后，重置root密码

```sql
ALTER USER 'root'@'localhost' IDENTIFIED BY 'root';
grant all on *.* to 'root'@'127.0.0.1' identified by 'root';

```



```sh
wget http://cn2.php.net/distributions/php-7.1.6.tar.xz
tar xvf php-7.1.6.tar.xz
cd php-7.1.6
version="7.1.6"
TARGET_PATH=/home/`whoami`/local/php-$version
```

常见问题：

> Uncaught PDOException: SQLSTATE[HY000] [2002] No such file or directory in webapp/system/database/drivers/pdo/pdo_driver.php:1     14

检查php.ini的配置，配置`mysqli.default_socket`
