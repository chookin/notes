# 简介
NTP（Network Time Protocol，网络时间协议）是由RFC 1305定义的时间同步协议，用来在分布式时间服务器和客户端之间进行时间同步。NTP基于UDP报文进行传输，使用的UDP端口号为123。 

使用NTP的目的是对网络内所有具有时钟的设备进行时钟同步，使网络内所有设备的时钟保持一致，从而使设备能够提供基于统一时间的多种应用。 
对于运行NTP的本地系统，既可以接收来自其他时钟源的同步，又可以作为时钟源同步其他的时钟，并且可以和其他设备互相同步。

# 安装与配置
选用C/S模式，一台服务器作为服务端，其他服务器作为客户端，客户端的时钟与服务端的同步。
## 服务端
### 安装
在集群的各机器上均安装ntp。

```shell
rpm -qa | grep ntp
```
使用上述命令检查ntp是否已安装，如果未安装，安装之。

```shell
yum -y install ntp
```

### 配置
修改/etc/ntp.conf，这是NTP的主要配置文件，里面设置了用来同步时间的时间服务器的域名或者IP地址。假定选择10.25.167.33为时钟源，则

```shell
$ sudo vim /etc/ntp.conf 

# For more information about this file, see the man pages
# ntp.conf(5), ntp_acc(5), ntp_auth(5), ntp_clock(5), ntp_misc(5), ntp_mon(5).

driftfile /var/lib/ntp/drift

# Permit time synchronization with our time source, but do not
# permit the source to query or modify the service on this system.
restrict default kod nomodify notrap nopeer noquery
restrict -6 default kod nomodify notrap nopeer noquery

# Permit all access over the loopback interface.  This could
# be tightened as well, but to do so would effect some of
# the administrative functions.
restrict 127.0.0.1
restrict -6 ::1

# Hosts on local network are less restricted.
#restrict 192.168.1.0 mask 255.255.255.0 nomodify notrap

# Use public servers from the pool.ntp.org project.
# Please consider joining the pool (http://www.pool.ntp.org/join.html).
#server 0.rhel.pool.ntp.org
#server 1.rhel.pool.ntp.org
server 10.25.167.33

#broadcast 192.168.1.255 autokey        # broadcast server
#broadcastclient                        # broadcast client
#broadcast 224.0.1.1 autokey            # multicast server
#multicastclient 224.0.1.1              # multicast client
#manycastserver 239.255.254.254         # manycast server
#manycastclient 239.255.254.254 autokey # manycast client

# Undisciplined Local Clock. This is a fake driver intended for backup
# and when no outside source of synchronized time is available. 
#server 127.127.1.0     # local clock
#fudge  127.127.1.0 stratum 10  

# Enable public key cryptography.
#crypto

includefile /etc/ntp/crypto/pw

# Key file containing the keys and key identifiers used when operating
# with symmetric key cryptography. 
keys /etc/ntp/keys
```

### 防火墙

```shell
$ sudo vi /etc/sysconfig/iptables

-A INPUT -p udp --dport 123 -j ACCEPT
-A OUTPUT -p udp --sport 123 -j ACCEPT
```

参考：http://superuser.com/questions/141772/what-are-the-iptables-rules-to-permit-ntp 

### 重启服务
```
service ntpd restart
```

### 设置开机自启动
为了使NTP服务可以在系统引导的时候自动启动，执行：

```shell
chkconfig --level 3 ntpd on
```

## 客户端
### 安装及防火墙配置
与服务端的相同。

### 时钟同步

```
/usr/sbin/ntpdate myntpserver
```
其中myntpserver为ntp服务端的hostname。

### 配置定时任务
```
# crontab -e

*/30 * * * * /usr/sbin/ntpdate myntpserver
```

此后，该客户端机器将每30分钟与服务端机器同步一次时钟。

# 常见问题

1）在ntp server上重新启动ntp服务后，ntp server自身或者与其server的同步的需要一个时间段，这个过程可能是5分钟，在这个时间之内在客户端运行ntpdate命令时会产生错误`no server suitable for synchronization found`

那么如何知道何时ntp server完成了和自身同步的过程呢？

在ntp server上使用命令：
```shell
watch ntpq -p
```

出现画面：
```
Every 2.0s: ntpq -p                                                                                                             Thu Jul 10 02:28:32 2008
     remote           refid      st t when poll reach   delay   offset jitter
==============================================================================
 192.168.30.22   LOCAL(0)         8 u   22   64    1    2.113 179133.   0.001
 LOCAL(0)        LOCAL(0)        10 l   21   64    1    0.000   0.000  0.001
```
注意LOCAL的这个就是与自身同步的ntp server。
注意reach这个值，在启动ntp server服务后，这个值就从0开始不断增加，当增加到17的时候，从0到17是5次的变更，每一次是poll的值的秒数，是64秒*5=320秒的时间。
如果之后从ntp客户端同步ntp server还失败的话，用ntpdate –d来查询详细错误信息，再做判断。

