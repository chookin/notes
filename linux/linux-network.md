

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
vi /etc/sysconfig/network
NETWORKING=yes
HOSTNAME=myserver.domain.com
```
2. Change the host that is associated to your main IPaddress for your server, this is for internal networking (found at /etc/hosts):
3. The 'hostname' command will let you change the hostname on the server that the commandline remembers, but it will not actively update all programs that are running under the old hostname.
4. execute `sysctl kernel.hostname=lab16 `

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

```sh
# baidu dns
echo 'nameserver 180.76.76.76' >> /etc/resolv.conf
# google dns
echo 'nameserver 8.8.8.8' >> /etc/resolv.conf
```

如果dns由`NetworkManager`自动设定，则可能需要在`/etc/sysconfig/network-scripts/ifcfg-eth0`(具体根据网卡情况调整)中设定dns。否则，当重启network服务时，dns会被overwrite.

```sh
vi /etc/sysconfig/network-scripts/ifcfg-eth0
DNS1=180.76.76.76
DNS2=114.114.114.114
DNS3=8.8.8.8
```

当然若启用了NetworkManager，可把其停用。

```sh
[root@lab16 ~]# service NetworkManager status
NetworkManager (pid  2190) 正在运行...
[root@lab16 ~]# service NetworkManager stop
停止 NetworkManager 守护进程：                             [确定]
[root@lab16 ~]# chkconfig --levels 0123456 NetworkManager off
```

确保可用dns解析，即/etc/nsswitch.conf文件中hosts使用了dns.

```sh
$ grep hosts /etc/nsswitch.conf  
-------------------------------------------------------------------  
hosts:      files dns  
-------------------------------------------------------------------
```

注意，上面的配置要加上dns。
以下是dns的配置，备忘。

```
hosts: dns files #表示只在DNS失效时候才使用/etc/hosts文件
hosts: dns #表示只用DNS解析主机
host: files #表示只用/etc/hosts文件解析主机
hosts: files dns #将使用/etc/hosts文件解析主机，表示如果无法解析主机名将使用DNS。
```

## 查看网卡是否连接网线

```shell
[root@lab50 ~]# mii-tool em1
em1: negotiated 100baseTx-FD, link ok
[root@lab50 ~]# mii-tool em2
SIOCGMIIPHY on 'em2' failed: Resource temporarily unavailable
```

由如上信息可判定em1网卡连接有网线，而em2没有连接网线。

# 实用工具

## 端口查看 ss

ss是Socket Statistics的缩写。他可以显示PACKET sockets, TCP sockets, UDP sockets, DCCP sockets, RAW sockets, Unix domain sockets等等统计.

当服务器的socket连接数量变得非常大时，无论是使用netstat命令还是直接cat /proc/net/tcp，执行速度都会很慢。可能你不会有切身的感受，但请相信我，当服务器维持的连接达到上万个的时候，使用netstat等于浪费 生命，而用ss才是节省时间。

```sh
# time netstat -ant | grep EST | wc -l
3100

real 0m12.960s
user 0m0.334s
sys 0m12.561s
# time ss -o state established | wc -l
3204

real 0m0.030s
user 0m0.005s
sys 0m0.026s
```

**常用ss命令**

```sh
ss -l 显示本地打开的所有端口
ss -pl 显示每个进程具体打开的socket
ss -t -a 显示所有tcp socket
ss -u -a 显示所有的UDP Socekt
ss -o state established '( dport = :smtp or sport = :smtp )' 显示所有已建立的SMTP连接
ss -o state established '( dport = :http or sport = :http )' 显示所有已建立的HTTP连接
ss -x src /tmp/.X11-unix/* 找出所有连接X服务器的进程
ss -s 列出当前socket详细信息:
```

查看tcp各状态的连接数

```sh
[root@lab27 ~]# ss -ant | awk '{++s[$1]} END {for(k in s) print k,s[k]}'
SYN-SENT 2
LAST-ACK 15
SYN-RECV 64
ESTAB 90
State 1
FIN-WAIT-1 21
CLOSING 2
FIN-WAIT-2 39
TIME-WAIT 63677
LISTEN 16
```

ss命令是iproute工具集中的一员。

```sh
$ rpm -qf /usr/sbin/ss
iproute-2.6.32-31.el6.x86_64
```

[《篡权的ss》-linux命令五分钟系列之三十一](http://roclinux.cn/?p=2420)

## 端口查看 netstat

Netstat用于显示与IP、TCP、UDP和ICMP协议相关的统计数据，一般用于检验本机各端口的网络连接情况。
▲常见用法：
netstat –npl   可以查看你要打开的端口是否已经打开。
netstat –rn    打印路由表信息。
netstat –in    提供系统上的接口信息，打印每个接口的MTU,输入分组数，输入错误，输出分组数，输出错误，冲突以及当前的输出队列的长度。

```sh
[work@lab26 ~]$ netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'
TIME_WAIT 1950
CLOSE_WAIT 1
FIN_WAIT1 27
SYN_SENT 4
FIN_WAIT2 99
ESTABLISHED 267
SYN_RECV 97
CLOSING 2
LAST_ACK 16
CLOSING 8
LAST_ACK 37
```

```sh
➜  ~ netstat -in
Kernel Interface table
Iface       MTU Met    RX-OK RX-ERR RX-DRP RX-OVR    TX-OK TX-ERR TX-DRP TX-OVR Flg
em1        1500   0 409878658     10     29      0 72736790      0      0      0 BMRU
em1:1      1500   0      - no statistics available -                            BMRU
em2        1500   0 217918018      2      0      0 158572984      0      0      0 BMRU
lo        16436   0 5163230902   1962   1962      0 5163230902      0      0      0 LRU
vmnet1     1500   0        0      0      0      0        6      0      0      0 BMRU
vmnet8     1500   0  2804930      0      0      0        6      0      0      0 BMRU
```


## 查看端口连接 lsof
lsof(list open files)是一个列出当前系统打开文件的工具。通过lsof工具能够查看这个列表对系统检测及排错，常见的用法：
查看文件系统阻塞  `lsof /boot`
查看端口号被哪个进程占用   `lsof  -i :3306`
查看用户打开哪些文件   `lsof –u username`
查看进程打开哪些文件   `lsof –p  4838`
查看远程已打开的网络链接  `lsof –i @192.168.34.128`

```shell
[root@lab32 ~]# lsof -i :22 -n
COMMAND   PID USER   FD   TYPE    DEVICE SIZE/OFF NODE NAME
sshd     7223 root    3u  IPv4 575622229      0t0  TCP *:ssh (LISTEN)
sshd     7223 root    4u  IPv6 575622231      0t0  TCP *:ssh (LISTEN)
sshd    29022 root    3u  IPv4 575416769      0t0  TCP 172.31.167.173:ssh->172.31.167.159:53515 (ESTABLISHED)
```

## 端口扫描 nc

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


## 查看局域网内所有ip nmap

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

## 网速查看 nethogs
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

## 测试带宽 speedtest.py

```shell
wget https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py --no-check-certificate
python speedtest.py
```

## 限制网卡速度 wondershaper

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

## 网页速度测试

```shell
$curl -o /dev/null -s -w %{time_connect}:%{time_starttransfer}:%{time_total} http://www.chinaunix.net

0.081:0.272:0.779
```

通过 `-o` 参数发送到 /dev/null。 `-s` 参数去掉所有状态信息。`-w`参数让 curl 写出列出的计时器的状态信息：

- time_connect     建立到服务器的 TCP 连接所用的时间
- time_starttransfer     在发出请求之后，Web 服务器返回数据的第一个字节所用的时间
- time_total         完成请求所用的时间

这些计时器都相对于事务的起始时间，甚至要先于 Domain Name Service（DNS）查询。
因此，在发出请求之后，Web 服务器处理请求并开始发回数据所用的时间是 0.272 - 0.081 = 0.191 秒。
客户机从服务器下载数据所用的时间是 0.779 - 0.272 = 0.507 秒

## 带宽测试iperf

带宽测试通常采用UDP模式，因为能测出极限带宽、时延抖动、丢包率。在进行测试时，首先以链路理论带宽作为数据发送速率进行测试，例如，从客户端到服务器之间的链路的理论带宽为100Mbps，先用-b 100M进行测试，然后根据测试结果（包括实际带宽，时延抖动和丢包率），再以实际带宽作为数据发送速率进行测试，会发现时延抖动和丢包率比第一次好很多，重复测试几次，就能得出稳定的实际带宽。 

UDP模式

服务器端： iperf -u -s

客户端：

在udp模式下，以100Mbps为数据发送速率，客户端到服务器192.168.1.1上传带宽测试，测试时间为60秒。 

```sh
iperf -u -c 192.168.1.1 -b 100M -t 60
```

客户端同时向服务器端发起30个连接线程，以5Mbps为数据发送速率。

```sh
iperf -u -c 192.168.1.1 -b 5M -P 30 -t 60
```

以100M为数据发送速率，进行上下行带宽测试。

```sh
iperf -u -c 192.168.1.1 -b 100M -d -t 60
```



TCP模式

服务器端：

```sh
iperf -s 
```

客户端：

在tcp模式下，客户端到服务器192.168.1.1上传带宽测试，测试时间为60秒。

```sh
iperf -c 192.168.1.1 -t 60
```

客户端同时向服务器端发起30个连接线程。 

```sh
iperf -c 192.168.1.1 -P 30 -t 60
```

进行上下行带宽测试。

```sh
iperf -c 192.168.1.1 -d -t 60
```

来自: <http://man.linuxde.net/iperf>

## 性能测试 ab

```shell
$ab -n 100 -c 10 http://172.17.128.12:8001
ab: invalid URL
```

You're just missing the trailing slash.

常见问题

Q: apr_poll: The timeout specified has expired (70007)
A: 在命令行中加-k 使得connection keep alive

- [用ab和wrk做压力测试](http://galoisplusplus.coding.me/galoisplusplus/blog/2016/07/07/server-press-test-tips/)

```
-n在测试会话中所执行的请求个数。默认时，仅执行一个请求。
-c一次产生的请求个数。默认是一次一个。
-t测试所进行的最大秒数。其内部隐含值是-n 50000，它可以使对服务器的测试限制在一个固定的总时间以内。默认时，没有时间限制。
-p包含了需要POST的数据的文件。
-P对一个中转代理提供BASIC认证信任。用户名和密码由一个:隔开，并以base64编码形式发送。无论服务器是否需要(即, 是否发送了401认证需求代码)，此字符串都会被发送。
-T POST数据所使用的Content-type头信息。
-v设置显示信息的详细程度-4或更大值会显示头信息，3或更大值可以显示响应代码(404,200等),2或更大值可以显示警告和其他信息。
-V显示版本号并退出。
-w以HTML表的格式输出结果。默认时，它是白色背景的两列宽度的一张表。
-i执行HEAD请求，而不是GET。
-x设置<table>属性的字符串。
-X对请求使用代理服务器。
-y设置<tr>属性的字符串。
-z设置<td>属性的字符串。
-C对请求附加一个Cookie:行。其典型形式是name=value的一个参数对，此参数可以重复。
-H对请求附加额外的头信息。此参数的典型形式是一个有效的头信息行，其中包含了以冒号分隔的字段和值的对(如,"Accept-Encoding:zip/zop;8bit")。
-A对服务器提供BASIC认证信任。用户名和密码由一个:隔开，并以base64编码形式发送。无论服务器是否需要(即,是否发送了401认证需求代码)，此字符串都会被发送。
-h显示使用方法。
-d不显示"percentage served within XX [ms] table"的消息(为以前的版本提供支持)。
-e产生一个以逗号分隔的(CSV)文件，其中包含了处理每个相应百分比的请求所需要(从1%到100%)的相应百分比的(以微妙为单位)时间。由于这种格式已经“二进制化”，所以比'gnuplot'格式更有用。
-g把所有测试结果写入一个'gnuplot'或者TSV(以Tab分隔的)文件。此文件可以方便地导入到Gnuplot,IDL,Mathematica,Igor甚至Excel中。其中的第一行为标题。
-i执行HEAD请求，而不是GET。
-k启用HTTP KeepAlive功能，即在一个HTTP会话中执行多个请求。默认时，不启用KeepAlive功能。
-q如果处理的请求数大于150，ab每处理大约10%或者100个请求时，会在stderr输出一个进度计数。此-q标记可以抑制这些信息。
```

## 定向连接测试 httping

多次连接测指定url的可访问性

```shell
httping --ts -v -GbY -Ss -b -g http://117.136.183.146:21008/sv/9999/325/9999 -c 2
```

简单介绍一下几个常用的选项

-g 要测量的网址
-l 使用SSL连接
-c 这个和ping 一样，为请求数量
-Y 启用颜色输出
-x host:port(如果是测squid，用-x，不要用-h；和curl的不一样，curl -H指定的是发送的hostname，这个-h是指定给DNS解析的hostname)
-S 将时间分开成连接和传输两部分显示
-s 显示http状态码
-G GET(默认是HEAD)
-b 在使用了GET的前提下显示传输速度KB/s
-B 同-b，不过使用了压缩
-n a,b 提供给nagios监控用的，当平均响应时间>=a时，返回1；>=b，返回2；默认为0
-N c 提供给nagios监控用的，一切正常返回0，否则只要有失败的就返回c
-K 使用图形模式
--timestamp / --ts       put a timestamp before the measured values, use -v to include the date and -vv to show in microseconds
-C cookie=value / --cookie add a cookie to the request


- [用httping测试WEB页面响应时间](https://mp.weixin.qq.com/s?__biz=MzI3MTI2NzkxMA==&mid=2247483875&idx=1&sn=0a2a19fa53c71f72bbb6ec4cc783b27c&scene=23&srcid=0530GUZA6NkNGlvRjv8ncjKx#rd)
- [分享一个比较有用的测试Web站点访问速度的工具httping](http://f.dataguru.cn/thread-745246-1-1.html)

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

- [Linux tcpdump命令详解](http://www.cnblogs.com/ggjucheng/archive/2012/01/14/2322659.html)
- [Linux抓包工具tcpdump详解](http://www.ha97.com/4550.html)

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

```
➜  ~ tcpdump -i em2 host 223.69.29.234 and port 21889 -s500 -X | head -n 20
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on em2, link-type EN10MB (Ethernet), capture size 500 bytes
19:05:19.088046 IP 223.69.29.234.62244 > 117.136.183.146.21889: Flags [S], seq 1558134796, win 65535, options [mss 1380,nop,wscale 5,nop,nop,TS val 94571138 ecr 0,sackOK,eol], length 0
        0x0000:  4504 0040 4d5e 4000 3806 cb0b df45 1dea  E..@M^@.8....E..
        0x0010:  7588 b792 f324 5581 5cdf 400c 0000 0000  u....$U.\.@.....
        0x0020:  b002 ffff 174c 0000 0204 0564 0103 0305  .....L.....d....
        0x0030:  0101 080a 05a3 0a82 0000 0000 0402 0000  ................
19:05:19.088096 IP 117.136.183.146.21889 > 223.69.29.234.62244: Flags [S.], seq 2071082972, ack 1558134797, win 14480, options [mss 1460,sackOK,TS val 2186831752 ecr 94571138,nop,wscale 9], length 0
        0x0000:  4500 003c 0000 4000 4006 1072 7588 b792  E..<..@.@..ru...
        0x0010:  df45 1dea 5581 f324 7b72 37dc 5cdf 400d  .E..U..${r7.\.@.
        0x0020:  a012 3890 522c 0000 0204 05b4 0402 080a  ..8.R,..........
        0x0030:  8258 6788 05a3 0a82 0103 0309            .Xg.........
19:05:19.092679 IP 223.69.29.234.62244 > 117.136.183.146.21889: Flags [.], ack 1, win 4104, options [nop,nop,TS val 94571143 ecr 2186831752], length 0
        0x0000:  4504 0034 d4d8 4000 3806 439d df45 1dea  E..4..@.8.C..E..
        0x0010:  7588 b792 f324 5581 5cdf 400d 7b72 37dd  u....$U.\.@.{r7.
        0x0020:  8010 1008 a97d 0000 0101 080a 05a3 0a87  .....}..........
        0x0030:  8258 6788                                .Xg.
19:05:19.092886 IP 223.69.29.234.62244 > 117.136.183.146.21889: Flags [P.], seq 1:543, ack 1, win 4104, options [nop,nop,TS val 94571143 ecr 2186831752], length 542
        0x0000:  4504 0252 68cd 4000 3806 ad8a df45 1dea  E..Rh.@.8....E..
        0x0010:  7588 b792 f324 5581 5cdf 400d 7b72 37dd  u....$U.\.@.{r7.
        0x0020:  8018 1008 59be 0000 0101 080a 05a3 0a87  ....Y...........
        0x0030:  8258 6788 4f50 5449 4f4e 5320 2f72 6570  .Xg.OPTIONS./rep
16 packets captured
1718 packets received by filter
0 packets dropped by kernel
```
