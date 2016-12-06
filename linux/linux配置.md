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
## 超时断开

Linux云主机ssh自动登出的超时时间太短，如何修改？
出于安全考虑，Linux镜像默认的超时时间为180秒。如果要临时修改，可以登录shell后执行"unset TMOUT"，或者"export TMOUT=3600"；如果要永久修改，可以注释/etc/profile中的下面两行，然后重新登录shell

```shell
TIMEOUT=180
export TIMEOUT 
```

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
4. reconnect the shell connection.

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
### 增加虚网卡IP


若网卡为em1,则创建文件`/etc/sysconfig/network-scripts/ifcfg-em1:0`,编辑文件内容
```shell
DEVICE=em1:0
BOOTPROTO=static
IPADDR=111.13.47.168
NETMASK=255.255.255.224
GETWAY=111.13.47.190
ONBOOT=yes
TYPE=Ethernet
```
注意：**若需要在其他网段访问该ip，则必须配置网关`GATEWAY`.**

之后，启动该网卡

```shell
ifup em1:0
```
若要停掉该网卡，命令是
```shell
ifdown em1:0
```
若提示找不到设备，则使用命令：

```shell
ifconfig em1:0 up
```

或者一步到位增加ip（网卡服务重启后失效）

```shell
ip address add 10.10.33.145/27 broadcast + dev em1 label em1:0
```

删除新增的虚ip的方法
```shell
ip address delete 10.10.33.145/27 broadcast + dev em1 label em1:0
```

### 关于子网掩码
某IP的子网掩码255.255.255.0 可以表述为***.***.***.***/24, 该子网掩码用2进制表述为11111111.11111111.11111111.0000 0000，其中二进制里有多少个“1”，24个吧。
255.255.255.224的子网掩码用二进制表述为11111111.11111111.11111111.1110 0000，其中有27个“1”,所以"/27"等同于子网掩码255.255.255.224

## 网关

查看网关配置

```shell
[root@ad-check2 ~]# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
10.1.0.0        0.0.0.0         255.255.255.0   U     0      0        0 eth0
169.254.0.0     0.0.0.0         255.255.0.0     U     1002   0        0 eth0
0.0.0.0         10.1.0.1        0.0.0.0         UG    0      0        0 eth0
[root@ad-check2 ~]# ip route show
10.1.0.0/24 dev eth0  proto kernel  scope link  src 10.1.0.8 
169.254.0.0/16 dev eth0  scope link  metric 1002 
default via 10.1.0.1 dev eth0 
[root@ad-check2 ~]# netstat -r
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
10.1.0.0        *               255.255.255.0   U         0 0          0 eth0
link-local      *               255.255.0.0     U         0 0          0 eth0
default         promote.cache-d 0.0.0.0         UG        0 0          0 eth0
```

临时添加方法 

```shell
route add -net default netmask 0.0.0.0 gw 10.1.0.1
route add -net 10.1.0.0 netmask 255.255.255.0 dev eth0
```

删除 

```shell
route del -net default netmask 0.0.0.0 gw 10.1.0.1
route del -net 10.1.0.0 netmask 255.255.255.0 dev eth0
```


永久添加方法 
把命令追加到`/etc/rc.local` 

## 查看局域网内所有ip

1.进行ping扫描，打印出对扫描做出响应的主机　

nmap -sP 192.168.1.0/24　　
2.使用UDP ping探测主机

nmap -PU 192.168.1.0/24　　
3.使用频率最高的扫描选项（SYN扫描，又称为半开放扫描）执行得很快

nmap -sS 192.168.1.0/24
4.扫描之后查看arp缓存表获取局域网主机IP地址

cat /proc/net/arp



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
-A INPUT -s 192.168.110.0/24 -p tcp -j ACCEPT
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

## 端口扫描 nc

netcat是网络工具中的瑞士军刀，它能通过TCP和UDP在网络中读写数据。通过与其他工具结合和重定向，你可以在脚本中以多种方式使用它。使用netcat命令所能完成的事情令人惊讶。
`yum install nc`

`nc -z -v -n <host> <port1-portn>`

- 可以运行在TCP或者UDP模式，默认是TCP，-u参数调整为udp.
- z 参数告诉netcat使用0 IO,连接成功后立即关闭连接， 不进行数据交换(谢谢@jxing 指点)
- v 参数指使用冗余选项（译者注：即详细输出）
- n 参数告诉netcat 不要使用DNS反向查询IP地址的域名

```shell
nohup nc -z -v -n 111.13.47.164 1-65535 > 164.log &
```

## 压测工具 httping

多次连接测指定url的可访问性

```shell
httping -c10000 -g  http://111.13.47.169:8001/sv/24/316/1241/6?v=1 
```

## 抓包工具 tcpdump

```shell
tcpdump src <src_host> or dst <dst_host> -n -vv
```

## 添加.so等文件的搜索路径

很多时候，我们的.h/.so/.a/bin文件都不在Linux发行版所指定的默认路径下，这时可以通过~/.bashrc来增加搜索路径。

```shell
#增加.so搜索路径
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/liheyuan/soft/lib

#增加.a搜索路径
LIBRARY_PATH=$LIBRARY_PATH:/home/liheyuan/soft/lib

#增加bin搜索路径
export PATH=$PATH:/home/liheyuan/soft/bin

#增加GCC的include文件搜索路径
export C_INCLUDE_PATH=$C_INCLUDE_PATH:/home/liheyuan/soft/include

#增加G++的include文件搜索路径
export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:/home/liheyuan/soft/inc
```

# 配置端口转发

## 0 需求

配置端口80的请求转发到21888

## 1 检查80端口是否已被使用

```shell
netstat -lanp |grep 80 | less
```

若被使用，请确认无影响或处理。

## 2 启用端口转发

检查是否已启用转发，若没有启用，则启用

```shell
cat /proc/sys/net/ipv4/ip_forward 
```

如果返回1，则已启用，否则

```shell
echo 1 > /proc/sys/net/ipv4/ip_forward 
```

## 3 确定需要在哪个网卡配置转发

```shell
# ifconfig -a |grep addr
eth0      Link encap:Ethernet  HWaddr D8:50:E6:17:58:3B  
          inet addr:192.168.110.115  Bcast:192.168.110.255  Mask:255.255.255.0
          inet6 addr: fe80::da50:e6ff:fe17:583b/64 Scope:Link
eth0:0    Link encap:Ethernet  HWaddr D8:50:E6:17:58:3B  
          inet addr:111.13.47.164  Bcast:111.13.47.191  Mask:255.255.255.224
eth1      Link encap:Ethernet  HWaddr D8:50:E6:17:57:73  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
```

可以发现公网ip配置在eth0:0网卡，因此，需在eth0:0网卡配置转发。但是eth0:0是虚网卡，可以么？

## 4 配置端口转发

语法格式是：

```shell
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport $srcPortNumber -j REDIRECT --to-port $dstPortNumber
```

具体为

```shell
iptables -t nat -A PREROUTING -i eth0:0 -p tcp --dport 80 -j REDIRECT --to-port 21888
```

补充：

udp的

```shell
iptables -t nat -A PREROUTING -i eth0 -p udp --dport $srcPortNumber -j REDIRECT --to-port $dstPortNumber
```

ip的

```shell
iptables -t nat -I PREROUTING --src $SRC_IP_MASK --dst $DST_IP -p tcp --dport $portNumber -j REDIRECT --to-ports $rediectPort
```

## 5 开放防火墙的80端口

如果防火墙没有开发80端口，开放之。

```shell
iptables -I INPUT -p tcp -m tcp --dport 80 -j ACCEPT
```

## 6 测试

确保如果两个都能成功响应。

```shell
wget http://111.13.47.164:21888/sc/28/321/1472/5?v=1
wget http://111.13.47.164:80/sc/28/321/1472/5?v=1
```

## 7 保存防火墙配置

```shell
service iptables save
```

