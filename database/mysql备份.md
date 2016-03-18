# 使用AutoMySQLBackup备份mysql数据库
## Description
[AutoMySQLBackup](http://sourceforge.net/projects/automysqlbackup/) with a basic configuration will create Daily, Weekly and Monthly backups of one or more of your MySQL databases from one or more of your MySQL servers.

Other Features include:
- Email notification of backups （会有email通知）
- Backup Compression and Encryption （使用压缩和加密）
- Configurable backup rotation （保存的备份文件时间）
- Incremental database backups （增量型备份）

## 配置
我们要用到的是automysqlbackup.conf文件：

文件里有一些基本的配置信息，比如连接mysql server的用户名、密码、IP地址神马的。
```shell
# Username to access the MySQL server e.g. dbuser
CONFIG_mysql_dump_username='root'

# Password to access the MySQL server e.g. password
CONFIG_mysql_dump_password='1234'

# Host name (or IP address) of MySQL server e.g localhost
CONFIG_mysql_dump_host='localhost'

# Set the port for the mysql connection
CONFIG_mysql_dump_port=3306
```

继续，有个重要的配置，就是backup存放的地方咯！
```shell
# Backup directory location e.g /backups
CONFIG_backup_dir='/var/backup/db'
```

往下看，还有你要配置的database的名称，当然可以精确到表名，也可以只指定到database的名称。或者干脆直接留空，不过留空的话会默认备份所有的数据库……这样磁盘可能会爆炸吧……

```shell
# Databases to backup

# List of databases for Daily/Weekly Backup e.g. ( 'DB1' 'DB2' 'DB3' ... )
# set to (), i.e. empty, if you want to backup all databases
CONFIG_db_names=()
# You can use
#declare -a MDBNAMES=( "${DBNAMES[@]}" 'added entry1' 'added entry2' ... )
# INSTEAD to copy the contents of $DBNAMES and add further entries (optional).

# List of databases for Monthly Backups.
# set to (), i.e. empty, if you want to backup all databases
CONFIG_db_month_names=()

# List of DBNAMES to EXLUCDE if DBNAMES is empty, i.e. ().
CONFIG_db_exclude=( 'information_schema' 'wiqun' )
```

另外，还有配置weekly、monthly、daily之类的时间间隔的设置

```shell
# Rotation Settings

# Which day do you want monthly backups? (01 to 31)
# If the chosen day is greater than the last day of the month, it will be done
# on the last day of the month.
# Set to 0 to disable monthly backups.
CONFIG_do_monthly="22"

# Which day do you want weekly backups? (1 to 7 where 1 is Monday)
# Set to 0 to disable weekly backups.
CONFIG_do_weekly="7"

# Set rotation of daily backups. VALUE*24hours
# If you want to keep only today's backups, you could choose 1, i.e. everything older than 24hours will be removed.
CONFIG_rotation_daily=7

# Set rotation for weekly backups. VALUE*24hours
CONFIG_rotation_weekly=35

# Set rotation for monthly backups. VALUE*24hours
CONFIG_rotation_monthly=150
```
前两个都比较好理解，就是每个月或者每一周的什么时候进行自动备份，如果不想使用每周备份或者每月备份的话，相应的地方设置0即可。那么后面的rotation又是什么意思呢？其实就是日志保存的期限啦。

比如说CONFIG_rotation_weekly=35的意思就是说按周存储的备份最多保留35天。

再继续，可以配置发送邮件的一些配置，比如邮件地址啦、还有附件的内容啦。

```shell
# What would you like to be mailed to you?
# - log   : send only log file
# - files : send log file and sql files as attachments (see docs)
# - stdout : will simply output the log to the screen if run manually.
# - quiet : Only send logs if an error occurs to the MAILADDR.
CONFIG_mailcontent='files'

# Set the maximum allowed email size in k. (4000 = approx 5MB email [see docs])
CONFIG_mail_maxattsize=4000

# Allow packing of files with tar and splitting it in pieces of CONFIG_mail_maxattsize.
CONFIG_mail_splitandtar='yes'

# Use uuencode instead of mutt. WARNING: Not all email clients work well with uuencoded attachments.
#CONFIG_mail_use_uuencoded_attachments='no'

# Email Address to send mail to? (user@domain.com)
CONFIG_mail_address='elarwei@gmail.com'
```

## 启动
```shell
sh automysqlbackup automysqlbackup.conf
```

## 参考
- [CentOS下使用Automysqlbackup工具自动备份MySQL](http://www.cnblogs.com/elaron/archive/2013/03/22/2975887.html)
