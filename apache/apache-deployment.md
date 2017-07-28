# 编译安装

以编译安装httpd-2.4.26为例。

## 安装基础组件

```sh
# to fix error: expat.h: No such file or directory
yum install expat-devel
```

### 安装pcre

```sh
# wget https://ftp.pcre.org/pub/pcre/pcre2-10.23.tar.bz2 --no-check-certificate
wget https://ftp.pcre.org/pub/pcre/pcre-8.40.tar.bz2 --no-check-certificate
tar zxvf pcre-*
cd pcre-*

./configure --enable-utf8 --prefix=/home/`whoami`/local/pcre
make && make install
```
### 安装apr和apr-util

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
另外，可以解压缩apr和apr-util并移动到httpd的srclib文件夹，在编译时指定选项`-with-included-apr `，此时不需要上面的编译和安装，编译apache时也不需要`--with-apr=${TARGET_PATH}/apr --with-apr-util=$TARGET_PATH/apr-util`。

```shell
$ ll srclib/
total 32
drwxr-xr-x 28 zhuyin zhuyin 4096 Nov  4 10:54 apr
drwxr-xr-x 20 zhuyin zhuyin 4096 Nov  4 10:54 apr-util
-rw-rw-r--  1 zhuyin zhuyin  397 Nov  4 10:53 Makefile
-rw-r--r--  1 zhuyin zhuyin  121 Feb 11  2005 Makefile.in
```
## 安装apache

### 编译脚本

```sh
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

### 说明

- --with-layout 指定在编译 Apache 之后放置各个部分的位置。通过使用布局，可以在编译之前定义所有位置。布局是在 Apache 源代码根目录中的 config.layout 文件中定义的
- --enable-modules=most将一些不常用的，不在缺省常用模块中的模块编译进来.
- --enable-module 启用一个在默认情况下没有打开的模块，-disable-module 的作用正好相反。
- --enable-so  启动模块动态装卸载
- --enable-ssl 编译ssl模块
- --with-zlib  支持数据包压缩
- --with-pcre  支持正则表达式
- --enable-cgi 支持cgi机制（能够让静态web服务器能够解析动态请求的一个协议）
- --enable-mime-magic
- –enable-mods-shared=most选项：告诉编译器将所有标准模块都动态编译为DSO模块。
- –enable-rewrite选项：支持地址重写功能，使用1.3版本的朋友请将它改为–enable-module=rewrite

### mpm模式

apache2.4.10起，有3种稳定的MPM（Multi-Processing Module，多进程处理模块）模式。它们分别是prefork，worker和event。

编译的时候，可以通过configure的参数来指定：

```sh
--with-mpm=prefork|worker|event
```
也可以编译为三种都支持，通过修改配置来更换

```sh
--enable-mpms-shared=all
```
在httpd.conf中修改Apache的多处理模式MPM可以通过（modules文件夹下，会自动编译出三个MPM的so）：

```sh
#LoadModule mpm_prefork_module modules/mod_mpm_prefork.so
LoadModule mpm_worker_module modules/mod_mpm_worker.so
#LoadModule mpm_event_module modules/mod_mpm_event.so
```

### 安装后查看

#### 查看当前加载的module

包括两部分：

1. 已编译在apache中的模块
2. apach的配置文件(httpd.conf)的LoadModule部分

```shell
$ apachectl -t -D DUMP_MODULES
Loaded Modules:
 core_module (static)
 so_module (static)
 http_module (static)
 mpm_event_module (static)
 authz_core_module (shared)
 log_config_module (shared)
 unixd_module (shared)
 rewrite_module (shared)
```
#### 查看当前安装的mpm

```shell
$ httpd -l
Compiled in modules:
  core.c
  mod_so.c
  http_core.c
  event.c
```
#### 查看编译信息

```
$ httpd -V
Server version: Apache/2.4.26 (Unix)
Server built:   Jul 20 2017 15:09:40
Server's Module Magic Number: 20120211:68
Server loaded:  APR 1.5.2, APR-UTIL 1.5.4
Compiled using: APR 1.5.2, APR-UTIL 1.5.4
Architecture:   64-bit
Server MPM:     event
  threaded:     yes (fixed thread count)
    forked:     yes (variable process count)
Server compiled with....
 -D APR_HAS_SENDFILE
 -D APR_HAS_MMAP
 -D APR_HAVE_IPV6 (IPv4-mapped addresses enabled)
 -D APR_USE_SYSVSEM_SERIALIZE
 -D APR_USE_PTHREAD_SERIALIZE
 -D SINGLE_LISTEN_UNSERIALIZED_ACCEPT
 -D APR_HAS_OTHER_CHILD
 -D AP_HAVE_RELIABLE_PIPED_LOGS
 -D DYNAMIC_MODULE_LIMIT=256
 -D HTTPD_ROOT="/home/zhuyin/local/apache-2.4.26"
 -D SUEXEC_BIN="/home/zhuyin/local/apache-2.4.26/bin/suexec"
 -D DEFAULT_PIDLOG="logs/httpd.pid"
 -D DEFAULT_SCOREBOARD="logs/apache_runtime_status"
 -D DEFAULT_ERRORLOG="logs/error_log"
 -D AP_TYPES_CONFIG_FILE="conf/mime.types"
 -D SERVER_CONFIG_FILE="conf/httpd.conf"
```

# 配置

apache的错误日志，默认配置是`ErrorLog "logs/error_log"`，但是具体virtualhost可具有自己的日志文件。

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

# 操作

## 配置文件检查

```shell
httpd -t
```

## 启动

```shell
apachectl -k start
```

## 停止

```shell
apachectl -k stop

# 杀死当前用户的所有apache进程，用于当pid丢失时
pkill -u zhuyin httpd
```
# 常见问题

## 启动报错

>  undefined symbol: apr_array_clear

编译apache时，没有添加apr.

## 启动告警

> AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 192.168.110.107. Set the 'ServerName' directive globally to suppress this message

将 apache 的配置文件httpd.conf中的 ServerName 改成可用域名或IP。

## Options must start with +

apache httpd 2.2的配置放到apache httpd 2.4下就出现了这个错误

> apache httpd Either all Options must start with + or -, or no Option may.

出现错误的行内容为：

```
Options FollowSymLinks -Indexes -MultiViews
```

解决办法：为选项附加`+`

```
Options +FollowSymLinks  -Indexes -MultiViews
```

## NameVirtualHost

`AH00548: NameVirtualHost has no effect and will be removed in the next release`

去掉 NameVirtualHost 这一行，就行了

## 403 Forbidden

启动报错`HTTP request sent, awaiting response... 403 Forbidden`

查看apache日志

```
AH01630: client denied by server configuration: /home/zhuyin/www/admonitor/webapp/
```

权限问题。请监测默认的网页资源是否放开了读权限。
例如，apache以`Daemon`用户运行，而默认资源文件`index.html`没有放开读权限。

```
-rw-r-----  1 work work    6 May 26 18:16 index.html
```
放开权限，`chmod 644 index.html`
若非该种情况，可能是`Selinux`的问题，或者是apache的权限规则发生了变化。

> The new directive is Require:
>
> 2.2 configuration:
>
> ```
> Order allow,deny
> Allow from all
> ```
>
> 2.4 configuration:
>
> ```shell
> Require all granted
> ```
>
> Also don't forget to restart the apache server after these changes

## No matching DirectoryIndex

apache重启继续报错

```
AH01276: Cannot serve directory /home/zhuyin/www/admonitor/webapp/: No matching DirectoryIndex (index.html) found, and server-generated directory index forbidden by Options directive
```

解决办法，在web文档根路径下创建文件index.html

```shell
echo 'hello' > /home/zhuyin/www/admonitor/webapp/index.html
```

## 忽略文件扩展名

apache的url rewrite规则不能正常工作。访问http://117.136.183.146:21008/sv/77/325/9999，报错”找不到http://117.136.183.146:21008/sv.gif/77/325/9999“，其中，在DocumentRoot下存在`sv.gif`文件。

问题原因：multiviews选项与rewrite规则冲突。 multiviews，允许访问页面时不需要文件的扩展名。

## Invalid command 'Require'

配置出错`Invalid command 'Require', perhaps misspelled or defined by a module not included in the server configuration`

> The Require directive is supplied by mod_authz_core. If the module has not been compiled into your Apache binary, you will need to add an entry to your configuration file to load it manually.
>
> 在配置文件中添加该module即可
>
> ```
> LoadModule authz_core_module modules/mod_authz_core.so
> ```

## Invalid command 'CustomLog'

配置出错`Invalid command 'CustomLog', perhaps misspelled or defined by a module not included in the server configuration`

引入模块log_config `LoadModule log_config_module modules/mod_log_config.so`

## exceeds ServerLimit

启动报错`MaxClients exceeds ServerLimit value…see the ServerLimit directive`

配置`ServerLimit`的值即可。

## awaiting response

访问卡住，如下示例。

```
$ wget localhost:8001
--2017-05-26 18:22:06--  http://localhost:8001/
Resolving localhost... ::1, 127.0.0.1
Connecting to localhost|::1|:8001... connected.
HTTP request sent, awaiting response...
```

问题原因：业务逻辑存在问题。

## 参考

- [Apache的静态编译与动态编译详解](http://www.ha97.com/2612.html)
- [httpd配置文件详解（上）](http://princepar.blog.51cto.com/1448665/1665008)
- [模块索引](http://httpd.apache.org/docs/current/mod/index.html)
- https://wiki.mikejung.biz/Apache
- [Apache的三种MPM模式比较：prefork，worker，event](http://blog.jobbole.com/91920/)
