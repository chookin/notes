
##  检测到目标主机可能存在缓慢的http拒绝服务攻击

```
Apache
============

建议使用mod_reqtimeout和mod_qos两个模块相互配合来防护。
1、mod_reqtimeout用于控制每个连接上请求发送的速率。配置例如：
#请求头部分，设置超时时间初始为10秒，并在收到客户端发送的数据后，每接收到500字节数据就将超时时间延长1秒，但最长不超过40秒。可以防护slowloris型的慢速攻击。
RequestReadTimeout header=10-40,minrate=500
#请求正文部分，设置超时时间初始为10秒，并在收到客户端发送的数据后，每接收到500字节数据就将超时时间延长1秒，但最长不超过40秒。可以防护slow message body型的慢速攻击。
RequestReadTimeout body=10-40,minrate=500
需注意，对于HTTPS站点，需要把初始超时时间上调，比如调整到20秒。

2、mod_qos用于控制并发连接数。配置例如：
# 当服务器并发连接数超过600时，关闭keepalive
QS_SrvMaxConnClose 600
# 限制每个源IP最大并发连接数为50
QS_SrvMaxConnPerIP 50
这两个数值可以根据服务器的性能调整。
```

解决办法，配置`reqtimeout_module`和`mod_qos`,具体配置

```shell
LimitRequestBody 102400

# mod_reqtimeout用于控制每个连接上请求发送的速率
# 请求头部分，设置超时时间初始为10秒，并在收到客户端发送的数据后，每接收到500字节数据就将超时时间延长1秒，但最长不超过40秒。可以防护slowloris型的慢速攻击。
RequestReadTimeout header=10-40,minrate=500
#请求正文部分，设置超时时间初始为10秒，并在收到客户端发送的数据后，每接收到500字节数据就将超时时间延长1秒，但最长不超过40秒。可以防护slow message body型的慢速攻击。
#对于HTTPS站点，需要把初始超时时间上调，比如调整到20秒
RequestReadTimeout body=20-40,minrate=500

# mod_qos用于控制并发连接数
LoadModule qos_module modules/mod_qos.so
# 当服务器并发连接数超过85%时，关闭keepalive
QS_SrvMaxConnClose 85%
# 限制每个源IP最大并发连接数为900
QS_SrvMaxConnPerIP 900
```

对于reqtimeout_module，http自带，不用安装；
对于 mod_qos，需要下载编译安装

http://mod-qos.sourceforge.net

```shell
wget https://jaist.dl.sourceforge.net/project/mod-qos/mod_qos-11.39.tar.gz
tar xvf mod_qos*
cd apache2
# 需要先安装pcre pcre-devel
apxs -i -c mod_qos.c
```
