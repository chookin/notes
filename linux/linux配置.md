[TOC]

# 时区
## 查看时区

```shell
$ date -R
Thu, 07 Apr 2016 10:29:09 +0800
```

## 修改时区

```shell
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```

# 网络
## hostname
### 修改hostname

1. Open the /etc/sysconfig/network file with your favorite text editor. Modify the HOSTNAME= value to match your FQDN host name.
```shell
$ sudo vi /etc/sysconfig/network
NETWORKING=yes
HOSTNAME=myserver.domain.com
```
2. Change the host that is associated to your main IPaddress for your server, this is for internal networking (found at /etc/hosts):
3. The 'hostname' command will let you change the hostname on the server that the commandline remembers, but it will not actively update all programs that are running under the old hostname.
4. reconnect the shell connection, or restart network.

## 查看网卡是否连接网线

```shell
[root@lab50 ~]# mii-tool em1
em1: negotiated 100baseTx-FD, link ok
[root@lab50 ~]# mii-tool em2
SIOCGMIIPHY on 'em2' failed: Resource temporarily unavailable
```
由如上信息可判定em1网卡连接有网线，而em2没有连接网线。

## 网卡

```shell
[root@lab50 ~]# vi /etc/sysconfig/network-scripts/ifcfg-em1 
DEVICE=em1
TYPE=Ethernet
UUID=5138aae7-f1ab-4579-bce5-e9e858d6e5d3
ONBOOT=yes
NM_CONTROLLED=yes
# start when systerm boot.
BOOTPROTO=none
HWADDR=14:18:77:3C:A0:24
IPADDR=192.168.110.123
PREFIX=24
GATEWAY=192.168.110.254
DEFROUTE=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT=no
NAME="System em1"
```

`HWADDR`即为mac地址，mac地址
### 增加ip
若网卡为em1,则创建文件`/etc/sysconfig/network-scripts/ifcfg-em1:0`,编辑文件内容
```shell
DEVICE=em1:0
BOOTPROTO=static
IPADDR=10.10.33.145
NETMASK=255.255.255.224
NETWORK=10.10.33.0
ONBOOT=yes
TYPE=Ethernet
```
之后，启动该网卡项
```shell
ifup em1:0
```
若有停掉该网卡，命令是
```shell
ifdown em1:0
```
或者一步到位增加ip（网卡服务重启后失效）
```shell
ip address add 10.10.33.145/27 broadcast + dev em1 label em1:0
```

## 关于子网掩码
某IP的子网掩码255.255.255.0 可以表述为***.***.***.***/24, 该子网掩码用2进制表述为11111111.11111111.11111111.0000 0000，其中二进制里有多少个“1”，24个吧。
255.255.255.224的子网掩码用二进制表述为11111111.11111111.11111111.1110 0000，其中有27个“1”,所以"/27"等同于子网掩码255.255.255.224

## nat上网
### 入口服务器
配置iptables
```
*nat
:PREROUTING ACCEPT [60:6658]
:POSTROUTING ACCEPT [27:1912]
:OUTPUT ACCEPT [27:1912]
-A POSTROUTING -s 192.168.110.0/255.255.255.0 -o eth1 -j MASQUERADE 
-A POSTROUTING -s 192.168.110.0/255.255.255.0 -o eth1 -j MASQUERADE 
-A POSTROUTING -s 192.168.110.0/255.255.255.0 -o eth1 -j MASQUERADE 
COMMIT
```

### 内部服务器
执行如下命令：
```
iptables -t nat -A POSTROUTING -s 192.168.110.0/24 -o eth1 -j MASQUERADE
route del default gw 192.168.110.254
route add default gw 192.168.110.103
```

## 防火墙
```shell
[root@lab50 ~]# vi /etc/sysconfig/iptables
# Firewall configuration written by system-config-firewall
# Manual customization of this file is not recommended.
*filter
# the default rule for input is ACCEPT
:INPUT ACCEPT [0:0]
# the default rule for forward is ACCEPT
:FORWARD ACCEPT [0:0]
# the default rule for output is ACCEPT
:OUTPUT ACCEPT [0:0]
# accept input of established connections
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
# open to sub network
-A INPUT -s 192.168.0.0/255.255.255.0 -j ACCEPT
# accept loop access
-A INPUT -s 127.0.0.1 -d 127.0.0.1 -j ACCEPT
# open port 22
-A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
# -A INPUT -p icmp -j ACCEPT
# reject other packets, and send a message of 'host prohibited' to the rejected host.
-A INPUT -j REJECT --reject-with icmp-host-prohibited

# if reject forward, lvs nat cannot work
# -A FORWARD -j REJECT --reject-with icmp-host-prohibited
-A OUTPUT -j ACCEPT
COMMIT
```

## dns
```
echo 'nameserver 8.8.8.8' > /etc/resolv.conf
```
