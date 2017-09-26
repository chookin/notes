## Multi-Processing Module (MPM)

In practice, MPMs extend the modular functionality of Apache by allowing you to decide how to configure the web server to bind to network ports on the machine, accept requests from clients, and use children processes (and threads, alternatively) to handle such requests.

Beginning with version 2.4, Apache offers three different MPMs to choose from, depending on your needs:

- The prefork MPM uses multiple child processes without threading. Each process handles one connection at a time without creating separate threads for each. Without going into too much detail, we can say that you will want to use this MPM only when debugging an application that uses, or if your application needs to deal with, non-thread-safe modules like mod_php.
- The worker MPM uses several threads per child processes, where each thread handles one connection at a time. This is a good choice for high-traffic servers as it allows more concurrent connections to be handled with less RAM than in the previous case.
- Finally, the event MPM is the default MPM in most Apache installations for versions 2.4 and above. It is similar to the worker MPM in that it also creates multiple threads per child process but with an advantage: it causes KeepAlive or idle connections (while they remain in that state) to be handled by a single thread, thus freeing up memory that can be allocated to other threads. This MPM is not suitable for use with non-thread-safe modules like mod_php, for which a replacement such a PHP-FPM must be used instead.

To check the MPM used by your Apache installation, you can do:

```
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

或者

```sh
$ apachectl -M
Loaded Modules:
 core_module (static)
 authn_file_module (static)
 authn_dbm_module (static)
 ...
 mpm_prefork_module (shared)
 php7_module (shared)
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
    MaxRequestsPerChild：一个进程生存期间能够处理的会话数，超过则关闭此进程，目的是为了避免内存泄漏

基于worker.c的用户会话处理方式：

    StarServers：默认开启的等待用户连接的进程数
    MaxClients：能够同时处理的用户请求会话连接
    MinSpareThreads：最小空闲线程数
    MaxSpareThreads：最大空闲线程数
    ThreadsPerChild：每个进程下的线程数
    MaxRequestsPerChild：每个进程生存期间能够处理的最大会话数，0为不限制

event的配置

```
<IfModule mpm_event_module>
StartServers 3
MinSpareThreads 75
MaxSpareThreads 250
ThreadsPerChild 25
MaxRequestWorkers 400
MaxConnectionsPerChild 0
</IfModule>
```

# 参考

- [5 Tips to Boost the Performance of Your Apache Web Server](http://www.tecmint.com/apache-performance-tuning/)
