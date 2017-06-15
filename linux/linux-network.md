

# 配置

## 超时断开

Linux云主机ssh自动登出的超时时间太短，如何修改？
出于安全考虑，Linux镜像默认的超时时间为180秒。如果要临时修改，可以登录shell后执行"unset TMOUT"，或者"export TMOUT=3600"；如果要永久修改，可以注释/etc/profile中的下面两行，然后重新登录shell

```shell
TIMEOUT=180
export TIMEOUT
```

## 修改hostname

1. Open the /etc/sysconfig/network file with your favorite text editor. Modify the HOSTNAME= value to match your FQDN host name.

```shell
$ sudo vi /etc/sysconfig/network
NETWORKING=yes
HOSTNAME=myserver.domain.com
```
2. Change the host that is associated to your main IPaddress for your server, this is for internal networking (found at /etc/hosts):
3. The 'hostname' command will let you change the hostname on the server that the commandline remembers, but it will not actively update all programs that are running under the old hostname.
4. reconnect the shell connection.

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
## 修改dns

编辑文件`/etc/resolv.conf`

```
echo 'nameserver 8.8.8.8' > /etc/resolv.conf
```

## 查看网卡是否连接网线

```shell
[root@lab50 ~]# mii-tool em1
em1: negotiated 100baseTx-FD, link ok
[root@lab50 ~]# mii-tool em2
SIOCGMIIPHY on 'em2' failed: Resource temporarily unavailable
```

由如上信息可判定em1网卡连接有网线，而em2没有连接网线。

# 查看端口连接

```shell
[root@lab32 ~]# lsof -i :22 -n
COMMAND   PID USER   FD   TYPE    DEVICE SIZE/OFF NODE NAME
sshd     7223 root    3u  IPv4 575622229      0t0  TCP *:ssh (LISTEN)
sshd     7223 root    4u  IPv6 575622231      0t0  TCP *:ssh (LISTEN)
sshd    29022 root    3u  IPv4 575416769      0t0  TCP 172.31.167.173:ssh->172.31.167.159:53515 (ESTABLISHED)
```

# 端口扫描 nc

netcat是网络工具中的瑞士军刀，它能通过TCP和UDP在网络中读写数据。通过与其他工具结合和重定向，你可以在脚本中以多种方式使用它。使用netcat命令所能完成的事情令人惊讶。
`yum install nc`

`nc -z -v -n <host> <port1-portn>`

```
- 可以运行在TCP或者UDP模式，默认是TCP，-u参数调整为udp.
- z 参数告诉netcat使用0 IO,连接成功后立即关闭连接， 不进行数据交换(谢谢@jxing 指点)
- v 参数指使用冗余选项（译者注：即详细输出）
- n 参数告诉netcat 不要使用DNS反向查询IP地址的域名
```

```shell
nohup nc -z -v -n 117.136.183.139 1-65535 > 139.log &
```


## 查看局域网内所有ip

1.进行ping扫描，打印出对扫描做出响应的主机　

nmap -sP 192.168.1.0/24
2.使用UDP ping探测主机

```shell
# inner
nmap -PU 172.31.167.0/24

# idrac
nmap -PU 172.31.238.0/24

# public
nmap -PU 117.136.183.0/24
```

3.使用频率最高的扫描选项（SYN扫描，又称为半开放扫描）执行得很快

nmap -sS 192.168.1.0/24
4.扫描之后查看arp缓存表获取局域网主机IP地址

cat /proc/net/arp

# 网速查看
nethogs是一款小巧的"net top"工具，可以显示每个进程所使用的带宽，并对列表排序，将耗用带宽最多的进程排在最上面。万一出现带宽使用突然激增的情况，用户迅速打开nethogs，就可以找到导致带宽使用激增的进程。nethogs可以报告程序的进程编号（PID）、用户和路径。
```shell
yum install -y nethogs
```

```
[root@localhost ~]# nethogs
Waiting for first packet to arrive (see sourceforge.net bug 1019381)
NetHogs version 0.8.5

    PID USER     PROGRAM                                                   DEV        SENT      RECEIVED
  16649 root     cd /etc                                                   eth1        0.451       0.214 KB/sec
  16650 root     ps -ef                                                    eth1        0.412       0.214 KB/sec
   1869 root     sshd: root@pts/1                                          eth0        0.401       0.129 KB/sec
      ? root     unknown TCP                                                           0.000       0.000 KB/sec

  TOTAL                                                                                1.264       0.558 KB/sec
```

# 测试带宽

```shell
wget https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py --no-check-certificate
python speedtest.py
```

# 限制网卡速度

```shell
yum install wondershaper -y
```

```shell
# 限制em1网卡下载速度500Kb，上传速度50Kb
wondershaper em1 500 50
# 清除em1网卡的网速限制
wondershaper clear em1
```

或者使用`tc`

限制eth0网卡的带宽为50kbit：

```shell
/sbin/tc qdisc add dev eth0 root tbf rate 50kbit latency 50ms burst 1000
```
解除eth0网卡的带宽限制：

```shell
/sbin/tc qdisc del dev eth0 root tbf
```

# 网页速度

```shell
$curl -o /dev/null -s -w %{time_connect}:%{time_starttransfer}:%{time_total} http://www.chinaunix.net

0.081:0.272:0.779
```

通过 -o 参数发送到 /dev/null。 -s 参数去掉所有状态信息。-w参数让 curl 写出列出的计时器的状态信息：

- time_connect     建立到服务器的 TCP 连接所用的时间
- time_starttransfer     在发出请求之后，Web 服务器返回数据的第一个字节所用的时间
- time_total         完成请求所用的时间

这些计时器都相对于事务的起始时间，甚至要先于 Domain Name Service（DNS）查询。
因此，在发出请求之后，Web 服务器处理请求并开始发回数据所用的时间是 0.272 - 0.081 = 0.191 秒。
客户机从服务器下载数据所用的时间是 0.779 - 0.272 = 0.507 秒

# web性能测试

```shell
$ab -n 100 -c 10 http://172.17.128.12:8001
ab: invalid URL
```

You're just missing the trailing slash.


## 压测工具 httping

多次连接测指定url的可访问性

```shell
httping -c10000 -g  http://111.13.47.169:8001/sv/24/316/1241/6?v=1
```

## 路由跟踪 traceroute

## 丢包率判断 mtr

```sh
[root@ad-check1 ~]# mtr -r -c 30 117.136.183.142
HOST: ad-check1.novalocal         Loss%   Snt   Last   Avg  Best  Wrst StDev
  1. ???                          100.0    30    0.0   0.0   0.0   0.0   0.0
  2. ???                          100.0    30    0.0   0.0   0.0   0.0   0.0
  3. promote.cache-dns.local       0.0%    30   92.8  38.0   0.7 127.2  44.9
  4. promote.cache-dns.local       0.0%    30    1.3   1.3   1.0   3.1   0.4
  5. 223.105.0.41                  0.0%    30    0.7   0.8   0.5   3.8   0.6
  6. 223.105.0.17                  0.0%    30    1.4   1.6   1.3   3.6   0.4
  7. 221.183.14.21                 0.0%    30    7.3   7.5   7.2   9.4   0.4
  8. 221.176.21.177                0.0%    30   28.0  30.5  28.0  50.0   5.8
  9. 221.183.11.50                 0.0%    30   28.8  30.0  28.6  40.2   2.9
 10. 117.136.183.5                 0.0%    30   26.2  26.4  26.2  27.0   0.1
 11. 172.31.255.6                  0.0%    30   25.7  25.6  25.4  26.4   0.2
 12. 117.136.183.142               0.0%    30   26.2  26.3  26.1  26.9   0.2
```

第三列:是显示的每个对应IP的丢包率
第四列:显示的最近一次的返回时延
第六列:是平均值 这个应该是发送ping包的平均时延
第七列:是最好或者说时延最短的
第八列:是最差或者说时延最常的
第九列:是标准偏差

## 抓包工具 tcpdump

```shell
tcpdump src <src_host> or dst <dst_host> -n -vv
```

```shell
[root@lab23 ~]# tcpdump -n -s500 -i any port 21888 -X | less
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on any, link-type LINUX_SLL (Linux cooked), capture size 500 bytes
18:43:44.709168 IP 117.131.17.253.51459 > 172.31.167.125.21888: Flags [P.], seq 1884194609:1884194789, ack 152254387, win 115, length 180
        0x0000:  4504 00dc 03fa 4000 3506 6601 7583 11fd  E.....@.5.f.u...
        0x0010:  ac1f a77d c903 5580 704e 8731 0913 37b3  ...}..U.pN.1..7.
        0x0020:  5018 0073 316e 0000 4745 5420 2f73 762f  P..s1n..GET./sv/
        0x0030:  3733 2f33 3131 2f32 3232 342f 363f 763d  73/311/2224/6?v=
        0x0040:  3126 7369 643d 3834 3634 6331 6435 2d33  1&sid=8464c1d5-3
        0x0050:  3538 382d 3434 6239 2d39 6131 322d 3065  588-44b9-9a12-0e
        0x0060:  3238 6264 3765 3232 6236 2d32 3031 3730  28bd7e22b6-20170
        0x0070:  3631 3331 3834 3330 3234 3935 2048 5454  613184302495.HTT
        0x0080:  502f 312e 310d 0a48 6f73 743a 206d 6f6e  P/1.1..Host:.mon
        0x0090:  6974 6f72 2e63 6d2d 616e 616c 7973 6973  itor.cm-analysis
        0x00a0:  2e63 6f6d 3a38 3030 310d 0a55 7365 722d  .com:8001..User-
        0x00b0:  4167 656e 743a 2069 666c 792d 676e 6f6d  Agent:.ifly-gnom
        0x00c0:  652f 322e 300d 0a43 6f6e 7465 6e74 2d4c  e/2.0..Content-L
        0x00d0:  656e 6774 683a 2030 0d0a 0d0a            ength:.0....
18:43:44.709263 IP 172.31.167.125.21888 > 117.131.17.253.51459: Flags [.], ack 180, win 123, length 0
        0x0000:  4500 0028 d83c 4000 4006 8776 ac1f a77d  E..(.<@.@..v...}
        0x0010:  7583 11fd 5580 c903 0913 37b3 704e 87e5  u...U.....7.pN..
        0x0020:  5010 007b 7cbe 0000 0000 0000 0000       P..{|.........
```

