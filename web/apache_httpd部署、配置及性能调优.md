# 安装

## 下载

https://httpd.apache.org

```shell
wget http://apache.fayea.com//httpd/httpd-2.4.23.tar.gz
wget http://mirrors.cnnic.cn/apache//apr/apr-1.5.2.tar.gz
wget http://mirrors.cnnic.cn/apache//apr/apr-util-1.5.4.tar.gz
wget https://sourceforge.net/projects/pcre/files/pcre/8.39/pcre-8.39.tar.gz --no-check-certificate
```

## 编译安装

首先编译安装pcre

```shell
# compile and install pcre
cd ..
tar zxvf pcre-*
cd pcre-*
./configure --prefix=/home/`whoami`/local/pcre
make && make install
```
解压缩apache，然后解压缩apr和apr-util并拷贝到httpd的srclib文件夹
```shell
$ ll srclib/
total 32
drwxr-xr-x 28 zhuyin zhuyin 4096 Nov  4 10:54 apr
drwxr-xr-x 20 zhuyin zhuyin 4096 Nov  4 10:54 apr-util
-rw-rw-r--  1 zhuyin zhuyin  397 Nov  4 10:53 Makefile
-rw-r--r--  1 zhuyin zhuyin  121 Feb 11  2005 Makefile.in
```

之后对apache进行编译安装

```shell
make clean
./configure --with-layout=Apache --prefix=/home/`whoami`/local/apache --with-port=8001 --with-mpm=prefork --enable-modules=most --enable-module=so --enable-module=rewrite -with-included-apr --with-pcre=/home/`whoami`/local/pcre
make && make install
```



### 说明

- 在使用./configure 编译的时候，如果不指定某个模块为动态，即没有使用：enable-mods-shared=module或者enable-module=shared 这2个中的一个，那么所有的默认模块为静态。那么何谓静态？其实就是编译的时候所有的模块自己编译进 httpd 这个文件中（我们启动可以使用这个执行文件,如： ./httpd & ），启动的时候这些模块就已经加载进来了，也就是可以使用了， 通常为：`<ifmodule> </ifmodule>` 来配置。所以大家看到的配置都是 `<ifmodule  module.c>`  ，很显然，module.c这个东西已经存在 httpd这个文件中了。
- --with-layout 指定在编译 Apache 之后放置各个部分的位置。通过使用布局，可以在编译之前定义所有位置。布局是在 Apache 源代码根目录中的 config.layout 文件中定义的
- --enable-modules=most将一些不常用的，不在缺省常用模块中的模块编译进来.
- --enable-module 启用一个在默认情况下没有打开的模块，-disable-module 的作用正好相反。
- --enable-so  启动模块动态装卸载
- --enable-ssl 编译ssl模块
- --with-zlib  支持数据包压缩
- --with-pcre  支持正则表达式
- --enable-mpms-shared=all   以共享方式编译的模块
- --with-mpm=(worker|prefork|event) 指明httpd的工作
- --enable-cgi 支持cgi机制（能够让静态web服务器能够解析动态请求的一个协议）
- --enable-mime-magic 
- –enable-mods-shared=most选项：告诉编译器将所有标准模块都动态编译为DSO模块。
- –enable-rewrite选项：支持地址重写功能，使用1.3版本的朋友请将它改为–enable-module=rewrite
- --with-mpm=worker

### 常见问题

1，启动报错	

>  undefined symbol: apr_array_clear

需要下载apr和apr-utils 并解压到./srclib/，然后在编译时指定` --with-included-apr `

2，启动告警

> $ apachectl start
> AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 192.168.110.107. Set the 'ServerName' directive globally to suppress this message

将 apache 的配置文件httpd.conf中的 ServerName 改成可用域名。

3，apache httpd 2.2的配置放到apache httpd 2.4下就出现了这个错误

> apache httpd Either all Options must start with + or -, or no Option may.

出现错误的行内容为：

```
Options FollowSymLinks  -Indexes -MultiViews
```

解决办法：

修改为：

```
Options +FollowSymLinks  -Indexes -MultiViews
```

4，`AH00548: NameVirtualHost has no effect and will be removed in the next release`

去掉 NameVirtualHost 这一行，就行了

5，启动报错`HTTP request sent, awaiting response... 403 Forbidden`

查看apache日志

```
AH01630: client denied by server configuration: /home/zhuyin/www/admonitor/webapp/
```

问题原因是apache的权限规则发生了变化。

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

apache重启继续报错

```
AH01276: Cannot serve directory /home/zhuyin/www/admonitor/webapp/: No matching DirectoryIndex (index.html) found, and server-generated directory index forbidden by Options directive
```

解决办法，在web文档根路径下创建文件index.html

```shell
echo 'hello' > /home/zhuyin/www/admonitor/webapp/index.html
```

6，配置出错`Invalid command 'Require', perhaps misspelled or defined by a module not included in the server configuration`

> The Require directive is supplied by mod_authz_core. If the module has not been compiled into your Apache binary, you will need to add an entry to your configuration file to load it manually. 
>
> 在配置文件中添加该module即可
>
> ```
> LoadModule authz_core_module modules/mod_authz_core.so
> ```

7，配置出错`Invalid command 'CustomLog', perhaps misspelled or defined by a module not included in the server configuration`

引入模块log_config `LoadModule log_config_module modules/mod_log_config.so`

8，启动报错`MaxClients exceeds ServerLimit value…see the ServerLimit directive`

配置`ServerLimit`的值即可。

# 参数配置

## 查看当前加载的module

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



## KeepAlive

KeepAlive enables persistent connections on the web server. This setting should be On unless the server is getting requests from hundreds of IPs at once. High volume and/or load balanced servers should have this setting disabled Off to increase connection throughput.

When using DirectAdmin, this directive can be found in: /etc/httpd/conf/extra/httpd-default.conf

## MaxKeepAliveRequests

This setting limits the number of requests allowed per persistent connection when KeepAlive is on. If it is set to 0, unlimited requests will be allowed. When using DirectAdmin, this directive can be found in: /etc/httpd/conf/extra/httpd-default.conf

It is recommended to keep this value at 100 for virtualized accounts like VPS accounts. On dedicated servers it is recommended that this value be modified to 150.

## KeepAliveTimeout

The number of seconds Apache will wait for another request before closing the connection. Setting this to a high value may cause performance problems in heavily loaded servers. The higher the timeout, the more server processes will be kept occupied waiting on connections with idle clients. When using DirectAdmin, this directive can be found in: /etc/httpd/conf/extra/httpd-default.conf

The default value of 10 seconds is a good value for average server performance. This value should be kept low as the socket will be idle for extended periods otherwise.It is recommended that this value be lowered to 5 on servers under heavy load.

## StartServers

sets the number of child server processes created on startup. As the number of processes is dynamically controlled depending on the load there is usually little reason to adjust this parameter.

This value should mirror what is set in MinSpareServers.

## MinSpareServers

Sets the desired minimum number of idle child server processes. An idle process is one which is not handling a request. If there are fewer spareservers idle then specified by this value, then the parent process creates new children at a maximum rate of 1 per second. Setting this parameter to a large number is almost always a bad idea.

Woktron recommends adjusting the value for this setting to the following:

Virtual Private Server 5
Dedicated server with 1-2GB RAM 10
Dedicated server with 2-4GB RAM 20
Dedicated server with 4+ GB RAM 25

## MaxSpareServers

sets the desired maximum number of idle child server processes. An idle process is one which is not handling a request. If there are more than MaxSpareServers idle, then the parent process will kill off the excess processes.

## ServerLimit

http://httpd.apache.org/docs/current/mod/mpm_common.html#serverlimit

For the worker and Event MPM, this directive is multiplied by ThreadLimit which sets the maximum configured value for MaxRequestWorkers for the lifetime of the Apache httpd process. You must stop and start Apache to change this value, changes for this value are ignored during a restart.

If ServerLimit is set to a value much higher than necessary, extra, unused shared memory will be allocated.

You should only modify this limit if you need to have more than 16 processes running. If you want to handle more requests, try raising ThreadsPerChild first.

ServerLimit 1

## MaxRequestWorkers (Previously MaxClients)

MaxRequestWorkers 400 (default = ServerLimit x ThreadsPerChild) restricts the total number of threads that will be available to serve clients. MaxRequestWorkers was previously called MaxClients before Apache 2.3.13.

The Event default settings allow for 400 total threads to serve requests. If you want to lower or raise this value just multiply ServerLimit by ThreadsPerChild to get the value to use for MaxRequestWorkers

```shell
MaxRequestWorkers 400 (16 x 25 = 400)
ServerLimit 16 (default)
ThreadsPerChild 25 (default)
```

Since MaxRequestWorkers defaults to ServerLimit x ThreadsPerChild you shouldn't have to specify this value. You might want to do so just to make it clear what the max value is without having to do math.

## MaxConnectionsPerChild

MaxConnectionsPerChild sets the limit on the number of connections that an individual child server process will handle. After MaxConnectionsPerChild connections, the child process will die. If MaxConnectionsPerChild is 0, then the process will never expire.

Setting MaxConnectionsPerChild to a non-zero value limits the amount of memory that process can consume by (accidental) memory leakage. 

## Timeout

The Timeout setting is the number of seconds before data "sends" or "receives" (to or from the client) time out. Having this set to a high number forces site visitors to "wait in line" which adds extra load to the server. Lowering the ‘Timeout’ value too much will cause a long running script to terminate earlier than expected.

A reasonable value is 100 for Virtual Private Servers, or heavily loaded dedicated servers. For Dedicated Servers under normal load the default value of 300 is sufficient.



# 启停

## 启动

```shell
apachectl -k start
```

## 停止

```shell
apachectl -k stop
```

# 其他

## Multi-Processing Module (MPM) 

In practice, MPMs extend the modular functionality of Apache by allowing you to decide how to configure the web server to bind to network ports on the machine, accept requests from clients, and use children processes (and threads, alternatively) to handle such requests.

Beginning with version 2.4, Apache offers three different MPMs to choose from, depending on your needs:

- The prefork MPM uses multiple child processes without threading. Each process handles one connection at a time without creating separate threads for each. Without going into too much detail, we can say that you will want to use this MPM only when debugging an application that uses, or if your application needs to deal with, non-thread-safe modules like mod_php.
- The worker MPM uses several threads per child processes, where each thread handles one connection at a time. This is a good choice for high-traffic servers as it allows more concurrent connections to be handled with less RAM than in the previous case.
- Finally, the event MPM is the default MPM in most Apache installations for versions 2.4 and above. It is similar to the worker MPM in that it also creates multiple threads per child process but with an advantage: it causes KeepAlive or idle connections (while they remain in that state) to be handled by a single thread, thus freeing up memory that can be allocated to other threads. This MPM is not suitable for use with non-thread-safe modules like mod_php, for which a replacement such a PHP-FPM must be used instead.

To check the MPM used by your Apache installation, you can do:

```shell
$ httpd -v
Server version: Apache/2.4.23 (Unix)
Server built:   Nov  4 2016 10:55:03
[zhuyin@lab07 tmp]$ httpd -V
Server version: Apache/2.4.23 (Unix)
Server built:   Nov  4 2016 10:55:03
Server's Module Magic Number: 20120211:61
Server loaded:  APR 1.5.2, APR-UTIL 1.5.4
Compiled using: APR 1.5.2, APR-UTIL 1.5.4
Architecture:   64-bit
Server MPM:     event
  threaded:     yes (fixed thread count)
    forked:     yes (variable process count)
Server compiled with....
 -D APR_HAS_SENDFILE
 ...
```

查看当前安装的mpm

```shell
$ httpd -l
Compiled in modules:
  core.c
  mod_so.c
  http_core.c
  event.c
```



prefork的配置示例

```
<IfModule prefork.c>
ServerLimit 6000
MaxClients 6000
StartServers 1000
MinSpareServers 40
MaxSpareServers 80
MaxRequestsPerChild 4000
</IfModule>
```

基于prefork的用户会话处理方式：

    StartServers：默认开启等待用户连接的进程数
    MinSpareServers：最少等待用户连接的空闲进程数
    MaxSpareServers：最多等待用户连接的空闲进程，超过则杀死多余空闲进程
    ServerLimit：限制最大用户请求会话连接数
    MaxClients：最大响应用户会话的进程数，一般与ServerLimit相等
    MaxRequestsPerChild：一个进程生存期间能够处理的会话数，超过则关闭此进程

基于worker.c的用户会话处理方式：
        StarServers：默认开启的等待用户连接的进程数
        MaxClients：能够同时处理的用户请求会话连接
        MinSpareThreads：最小空闲线程数
        MaxSpareThreads：最大空闲线程数
        ThreadsPerChild：每个进程下的线程数
        MaxRequestsPerChild：每个进程生存期间能够处理的最大会话数，0为不限制

event的配置

````
<IfModule mpm_event_module>
StartServers 3
MinSpareThreads 75
MaxSpareThreads 250
ThreadsPerChild 25
MaxRequestWorkers 400
MaxConnectionsPerChild 0
</IfModule>
````



# 参考

- [Apache的静态编译与动态编译详解](http://www.ha97.com/2612.html)
- [5 Tips to Boost the Performance of Your Apache Web Server](http://www.tecmint.com/apache-performance-tuning/)
- http://httpd.apache.org/docs/current/mod/index.html
-  [httpd配置文件详解（上）](http://princepar.blog.51cto.com/1448665/1665008)
- http://www.woktron.com/secure/knowledgebase/133/How-to-optimize-Apache-performance.html
- https://wiki.mikejung.biz/Apache