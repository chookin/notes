# install

    brew install redis
# view software info

    $ brew info redis
    redis: stable 3.0.7 (bottled), HEAD
    Persistent key-value database, with built-in net interface
    http://redis.io/
    /usr/local/Cellar/redis/3.0.7 (9 files, 876.3K) *
      Poured from bottle
    From: https://github.com/Homebrew/homebrew/blob/master/Library/Formula/redis.rb
    ==> Options
    --with-jemalloc
        Select jemalloc as memory allocator when building Redis
    --HEAD
        Install HEAD version
    ==> Caveats
    To have launchd start redis at login:
      ln -sfv /usr/local/opt/redis/*.plist ~/Library/LaunchAgents
    Then to load redis now:
      launchctl load ~/Library/LaunchAgents/homebrew.mxcl.redis.plist
    Or, if you don't want/need launchctl, you can just run:
      redis-server /usr/local/etc/redis.conf

# Configuration
key paras
```shell
# By default Redis does not run as a daemon. Use 'yes' if you need it.
# Note that Redis will write a pid file in /var/run/redis.pid when daemonized.
daemonize yes
# Accept connections on the specified port, default is 6379.
# If port 0 is specified Redis will not listen on a TCP socket.
port 6379

# Specify the log file name. Also the empty string can be used to force
# Redis to log on the standard output. Note that if you use standard
# output for logging but daemonize, logs will be sent to /dev/null
logfile /Users/chookin/data/redis/redis-6379.log

# The working directory.
#
# The DB will be written inside this directory, with the filename specified
# above using the 'dbfilename' configuration directive.
#
# The Append Only File will also be created inside this directory.
#
# Note that you must specify a directory here, not a file name.
#dir /usr/local/var/db/redis/
dir /Users/chookin/data/redis/

# set password
requirepass p_r_9_@cmri
```

# 启动

    redis-server redis.conf
# 停止
redis-cli shutdown
# 备份
redis服务关闭后，缓存数据会自动dump到硬盘上，硬盘地址为redis.conf中的配置项dbfilename dump.rdb所设定。
强制备份数据到磁盘，使用如下命令
```shell
redis-cli save
# 指定端口
redis-cli -p 6380 save
```
