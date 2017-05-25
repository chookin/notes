## mysql

### 采用brew安装

```shell
brew install mysql # brew方式安装后的软件路径是/usr/local/opt/mysql/，数据文件夹是/usr/local/var/mysql
```

### 配置文件 my.cnf

```shell
mysqld --help --verbose | more # (查看帮助, 按空格下翻)
```

你会看到开始的这一行(表示配置文件默认读取顺序)

```
Default options are read from the following files in the given order:
/etc/my.cnf /etc/mysql/my.cnf /usr/local/etc/my.cnf ~/.my.cnf
```

通常这些位置是没有配置文件的, 所以要自己建一个

```shell
# 用这个可以找到样例.cnf
ls $(brew --prefix mysql)/support-files/my-*
# 拷贝到第一个默认读取目录
cp /usr/local/opt/mysql/support-files/my-default.cnf /etc/my.cnf
# 此后按需修改my.cnf
```

### mysql启停

可用使用mysql的脚本启停

```shell
$ mysql.server -h
Usage: mysql.server  {start|stop|restart|reload|force-reload|status}  [ MySQL server options ]

mysql.server start
```

也可借助brew

```shell
brew services start mysql
brew services stop mysql
```

### 常见问题
1，mysql无法终止，shutdown后又自动启动；
在`~/Library/LaunchAgents/`存在脚本 `homebrew.mxcl.mysql.plist`

该脚本导致`--datadir`在`/etc/my.cnf`中配置无效，真是无语的设计😑
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>KeepAlive</key>
  <true/>
  <key>Label</key>
  <string>homebrew.mxcl.mysql</string>
  <key>ProgramArguments</key>
  <array>
    <string>/usr/local/opt/mysql/bin/mysqld_safe</string>
    <string>--bind-address=127.0.0.1</string>
    <string>--datadir=/usr/local/var/mysql</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>WorkingDirectory</key>
  <string>/usr/local/var/mysql</string>
</dict>
</plist>
```

### 参考

- [在 Mac 下用 Homebrew 安装 MySQL](http://blog.neten.de/posts/2014/01/27/install-mysql-using-homebrew/)

## memcached

### 安装

```shell
$ brew search memcache
homebrew/php/php53-memcache         homebrew/php/php55-memcache         homebrew/php/php70-memcached        memcacheq
homebrew/php/php53-memcached        homebrew/php/php55-memcached        libmemcached
homebrew/php/php54-memcache         homebrew/php/php56-memcache         memcache-top
homebrew/php/php54-memcached        homebrew/php/php56-memcached        memcached ✔
$ brew install memcached

$ brew info memcached
memcached: stable 1.4.24 (bottled)
High performance, distributed memory object caching system
https://memcached.org/
Conflicts with: mysql-cluster
/usr/local/Cellar/memcached/1.4.24 (12 files, 162.3K) *
  Poured from bottle on 2016-03-04 at 14:15:07
From: https://github.com/Homebrew/homebrew-core/blob/master/Formula/memcached.rb
==> Dependencies
Required: libevent ✔
==> Options
--with-sasl
	Enable SASL support -- disables ASCII protocol!
--with-sasl-pwdb
	Enable SASL with memcached's own plain text password db support -- disables ASCII protocol!
==> Caveats
To have launchd start memcached now and restart at login:
  brew services start memcached
Or, if you don't want/need a background service you can just run:
  /usr/local/opt/memcached/bin/memcached
```

### 启动

```
cd /usr/local/opt/memcached && nohup bin/memcached -m 2048 -c 8192 -p 11211 >/dev/null 2>> logs/memcached11211.log &
```

## mongodb

### 安装

```
brew install mongodb
```
### 查看安装信息

```
$ brew info mongo
==> Options
--with-boost
    Compile using installed boost, not the version shipped with mongodb
--with-openssl
    Build with openssl support
--with-sasl
    Compile with SASL support
==> Caveats
To have launchd start mongodb at login:
  ln -sfv /usr/local/opt/mongodb/*.plist ~/Library/LaunchAgents
Then to load mongodb now:
  launchctl load ~/Library/LaunchAgents/homebrew.mxcl.mongodb.plist
Or, if you don't want/need launchctl, you can just run:
  mongod --config /usr/local/etc/mongod.conf &
```

### 启动

```shell
mongod --config /usr/local/etc/mongod.conf &
```



### 问题

（1） “WARNING: soft rlimits too low” in MongoDB with Mac OS X

Amongodd this to the /etc/launchd.conf file:
`launchctl limit maxfiles 1024 1024`

Now reboot to make changes effective.
