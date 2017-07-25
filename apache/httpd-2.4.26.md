# 编译安装
```sh
wget http://mirrors.hust.edu.cn/apache//apr/apr-1.5.2.tar.bz2
tar xvf apr-*
# wget http://mirrors.hust.edu.cn/apache//apr/apr-1.6.2.tar.bz2
./configure   --prefix=/home/`whoami`/local/apr
make && make install
```

```sh
wget http://mirrors.hust.edu.cn/apache//apr/apr-util-1.5.4.tar.bz2
tar xvf apr-util-*
# wget http://mirrors.hust.edu.cn/apache//apr/apr-util-1.6.0.tar.bz2
./configure --prefix=/home/`whoami`/local/apr-util --with-apr=/home/`whoami`/local/apr
make && make install
```

Q1: `error: expat.h: No such file or directory`
A: `yum install expat-devel`

```sh
# wget https://ftp.pcre.org/pub/pcre/pcre2-10.23.tar.bz2 --no-check-certificate
wget https://ftp.pcre.org/pub/pcre/pcre-8.40.tar.bz2 --no-check-certificate
./configure --enable-utf8 --prefix=/home/`whoami`/local/pcre
make && make install
```

```sh
version="2.4.25"
version="2.4.26"

wget http://archive.apache.org/dist/httpd/httpd-$version.tar.bz2
tar xvf httpd-$version.tar.bz2
cd httpd-$version
username=`whoami`
TARGET_PATH="/home/${username}/local"
make clean
./configure --with-layout=Apache --prefix=${TARGET_PATH}/apache-$version --with-apr=${TARGET_PATH}/apr --with-apr-util=$TARGET_PATH/apr-util --with-pcre=$TARGET_PATH/pcre --with-port=80 --enable-modules=most --enable-module=so --enable-dav --enable-module=rewrite --enable-ssl --enable-mime-magic --enable-mpms-shared=all
make && make install
```

# 基础配置

```sh
LoadModule rewrite_module modules/mod_rewrite.so

Listen 21008
<VirtualHost *:21008>
    DocumentRoot "/home/zhuyin/www/admonitor/webapp"
    ServerName admonitor.cm-analysis.com
    KeepAlive On
    RewriteEngine on
    CustomLog "|/home/zhuyin/local/apache/bin/rotatelogs -l /home/zhuyin/local/apache/logs/%Y%m%d%H-admonitor.log 3600" combined
    ErrorLog "|/home/zhuyin/local/apache/bin/rotatelogs -l /home/zhuyin/local/apache/logs/%Y%m%d-admonitor-error.log 86400"
    ServerSignature Off
    SetEnv APPLICATION_ENV "production"
    <IFMODULE mod_rewrite.c>
      RewriteEngine on
      RewriteRule ^(.*)$ /sv.gif [L]
    </IFMODULE>

    <Directory "/home/zhuyin/www/admonitor/webapp">
        Options +FollowSymLinks  -Indexes -MultiViews
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>

Include conf/extra/httpd-mpm.conf

User zhuyin
Group zhuyin

ServerName localhost

<IfModule log_config_module>
    #
    # The following directives define some format nicknames for use with
    # a CustomLog directive (see below).
    #
    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %D" combined
    LogFormat "%h %l %u %t \"%r\" %>s %b" common

    <IfModule logio_module>
      # You need to enable mod_logio.c to use %I and %O
      LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %O %D" combinedio
    </IfModule>

    #
    # The location and format of the access logfile (Common Logfile Format).
    # If you do not define any access logfiles within a <VirtualHost>
    # container, they will be logged here.  Contrariwise, if you *do*
    # define per-<VirtualHost> access logfiles, transactions will be
    # logged therein and *not* in this file.
    #
    CustomLog "logs/access_log" common

    #
    # If you prefer a logfile with access, agent, and referer information
    # (Combined Logfile Format) you can use the following directive.
    #
    #CustomLog "logs/access_log" combined
</IfModule>
```

> AH00548: NameVirtualHost has no effect and will be removed in the next release
>
> AH00558: httpd: Could not reliably determine the server's fully qualified domain name..Set the 'ServerName' directive globally to suppress this message

# 性能测试

## event

### 配置

```sh
LoadModule mpm_event_module modules/mod_mpm_event.so

<IfModule mpm_event_module>
    StartServers          30
    ServerLimit           500
    ThreadLimit             100
    MinSpareThreads         40
    MaxSpareThreads        100
    ThreadsPerChild        100
    MaxRequestWorkers      4000
    MaxConnectionsPerChild  1000
</IfModule>
```

再次配置

```sh
<IfModule mpm_event_module>
    StartServers           50
    ServerLimit            200
    MinSpareThreads        1500
    MaxSpareThreads        10000
    ThreadsPerChild        25
    ThreadLimit            50
    MaxRequestWorkers      5000
    MaxConnectionsPerChild  10000
</IfModule>
```



### 并发3000

```
ab -n 60000 -c 3000 localhost:21008/sv
```



# next
