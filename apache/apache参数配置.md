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

# 参考
- [How to optimize Apache performance](http://www.woktron.com/secure/knowledgebase/133/How-to-optimize-Apache-performance.html)
