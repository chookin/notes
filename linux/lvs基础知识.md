# 基础知识

## 服务性能扩展

当服务器遇到性能瓶颈需要进行扩展时，一般来说有两种解决思路：Scale-up 和 Scale out，也称作垂直扩展和水平扩展。

垂直扩展通常指增加 CPU 和内存，购买昂贵的高性能服务器。

优点：

- 耗电量相比使用多台服务器要少
- 实施简单

缺点

- 价格太昂贵
- 由于资源的争用，服务器性能的增长会越来越小
- 有很大的硬件故障导致服务不可用的风险
- 受限制于供应商，且可扩展升级的空间是有限的

水平扩展通常指增加多台普通配置的服务器。

优点

- 比起垂直扩展要便宜的多
- 有容错能力
- 易升级
- 有着很大的扩展空间

缺点

- 服务器的维护和管理更加麻烦
- 耗电和制冷的费用会比垂直扩展要高
- 如果使用付费授权软件，那么会增加 lisence 的费用

一般来说，随着服务器性能提升，其价格也是指数级上升的，使用水平扩展的方式能够节约很多成本，同时还能够增加整个服务的容错能力。

## 负载均衡

负载均衡集群指使用多台提供相同服务的服务器组成集群系统，提高服务的并发处理能力。负载均衡集群的前端使用一个调度器，将客户端请求平均分配到后端的服务器中，同时调度器可能还具有后端服务器状态检测的功能，将故障的服务器自动下线，使得集群具有一定的容错能力。

使用负载均衡集群能够有效的扩展服务的并发能力，负载均衡集群中的主机间应该尽量的「低耦合」，最好是「无状态」的，这样就能够方便的增加主机实现扩展。

## 常见的负载均衡器

根据工作在的协议层划分可划分为：

- 四层负载均衡：根据请求报文中的目标地址和端口进行调度
- 七层负载均衡：根据请求报文的内容进行调度，这种调度属于「代理」的方式

根据软硬件划分：

硬件负载均衡：

- F5 的 BIG-IP
- Citrix 的 NetScaler

这类硬件负载均衡器通常能同时提供四层和七层负载均衡，但同时也价格不菲
软件负载均衡：

- TCP 层：LVS
- 基于 HTTP 协议：Haproxy，Nginx，ATS（Apache Traffic Server），squid，varnish
- 基于 MySQL 协议：mysql-proxy

LVS 是一个**工作在四层的负载均衡器**，不支持複雜特性的負載均衡，效率比 Layer 7 高。nginx、haproxy都是 Layer 7 的負載均衡，可以根據特性進行負載均衡，比較靈活。

## LVS

LVS是Linux Virtual Server的简称，也就是Linux虚拟服务器, 是一个由章文嵩博士发起的自由软件项目，它的官方站点是www.linuxvirtualserver.org。使用LVS技术要达到的目标是：通过LVS提供的负载均衡技术和Linux操作系统实现一个高性能、高可用的服务器群集，它具有良好可靠性、可扩展性和可操作性。从而以低廉的成本实现最优的服务性能。

LVS的实现和 iptables/netfilter 类似，工作在内核空间的 TCP/IP 协议栈上。

LVS 工作在 INPUT Hook Funtion 上，并在 INPUT 设置附加规则，一旦客户端请求的是集群服务，LVS 会强行修改请求报文，将报文发往 POSTROUTING，转发至后端的主机。

和 iptables/netfilter 类似，LVS 也是两段式的：

- ipvsadm：工作在用户空间，负责定义和管理集群服务的规则
- ipvs：工作在内核中，在 2.4.23 之前，必须向内核打补丁，并重新编译内核。在 2.4.23 和 2.6 之后的版本，ipvs 直接内置在内核中。

# LVS的工作模型

使用LVS架设的服务器集群系统有三个部分组成：最前端的负载均衡层，用Load Balancer表示，中间的服务器群组层，用Server Array表示，最底端的数据共享存储层，用Shared Storage表示，在用户看来，所有的内部应用都是透明的，用户只是在使用一个虚拟服务器提供的高性能服务。

LVS 有三種模式：LVS-NAT、LVS-TUN、LVS-DR。

除了NAT模式，其他模式要求RealServer可访问公网。

## LVS-NAT

NAT模型:地址转换类型，主要是做地址转换，类似于iptables的DNAT类型，当客户端请求的是集群服务时，LVS 修改请求报文的目标地址为 RIP，转发至后端的 RealServer，并修改后端响应报文的源地址为 VIP，响应至客户端。

LVS-NAT 的特性：

- 集群节点跟 Director 必须在同一个 IP 网络中
- RIP 通常是私有地址，仅用于各集群节点间的通信
- Director 位于 client 和 Realserver 之间，负责处理进出的所有报文
- Realserver 必须将网关指向 DIP
- 支持端口映射
- 较大规模应用场景中，Director 易成为系统瓶颈（bottleneck）

## LVS-DR

DR 值 Direct Routing，直接路由，DR 模型中，Director 和 Realserver 处在同一网络中，对于 Director，VIP 用于接受客户端请求，DIP 用于和 Realserver 通信。对于 Realserver，**每个 Realserver 都配有和 Director 相同的 VIP（此 VIP 隐藏，关闭对 ARP 请求的响应）**，仅用于返回数据给客户端，RIP 用于和 Director 通信。

当客户端请求集群服务时，请求报文发送至 Director 的 VIP（Realserver的 VIP 不会响应 ARP 请求），Director 将客户端报文的源和目标 MAC 地址进行重新封装，将报文转发至 Realserver。**Realserver 接收转发的报文，此时报文的源 IP 和目标 IP 都没有被修改，因此 Realserver 接受到的请求报文的目标 IP 地址为本机配置的 VIP，它将使用自己的 VIP 直接响应客户端**。

LVS-DR 模型中，客户端的响应报文不会经过 Director，因此 Director 的并发能力有很大提升。

LVS-DR 模型的特性：

- 保证前端路由器将目标地址为 VIP 的报文通过 ARP 解析后送往 Director。
  - 静态绑定：在前端路由将 VIP 对应的目标 MAC 地址静态配置为Director VIP 接口的 MAC 地址
  - Real Server 主機需要綁定 VIP 地址在 LO 接口上 (有相同的VIP和單獨的RIP)，並且需要設定 ARP 抑制(由於網絡接口都會進行ARP廣播回應，但 cluster 的其他機器都有這個 VIP 的 lo port，都回應就會衝突。所以我們需要把 Real Server 的 lo 接口的 ARP 回應關閉掉)
- 各RIP 必须与 DIP 在同一个物理网络中
- RS 的 RIP 可以使用私有地址，也可以使用公网地址，以方便配置
- Director 仅负责处理入站请求，响应报文由 Realserver 直接发往客户端
- Realserver 不能将网关指向 DIP，而直接使用前端网关
- Director 不支持端口映射

## LVS-TUN

和 DR 模型类似，Realserver 都配有不可见的 VIP，Realserver 的 RIP 是公网地址，且可能和 DIP 不再同一网络中。当请求到达 Director 后，Director 不修改请求报文的源 IP 和目标 IP 地址，而是使用 IP 隧道技术，使用 DIP 作为源 IP，RIP 作为目标 IP 再次封装此请求报文，转发至 RIP 的 Realserver 上，Realserver 解析报文后仍然使用 VIP 作为源地址响应客户端。

LVS-TUN 的特性： 

- 集群节点和可以跨越 Internet
- RIP，DIP，VIP 都是公网地址
- Director 仅负责处理入站请求，响应报文由 Realserver 直接发往客户端
- Realserver 使用自己的网关而不是 Director
- Realserver 只能使用支持隧道功能的操作系统
- 不支持端口映射

# LVS 的调度算法

当 LVS 接受到一个客户端对集群服务的请求后，它需要进行决策将请求调度至某一台后端主机进行响应。LVS 的调度算法共有 10 种，按类别可以分为动态和静态两种类型。

## 静态调度算法Fixed Scheduling Method 

- rr：round robin，轮询，即简单在各主机间轮流调度。假設所有服務器處理性能均相同時使用，當所有 Server 的性能不一，request 服務時間變化比較大時，輪叫調度算法容易導致服務器間的負載不平衡。
- wrr：weighted round robin，加权轮询，根据各主机的权重进行轮询
- sh：source hash，源地址哈希，对客户端地址进行哈希计算，保存在 Director 的哈希表中，在一段时间内，同一个客户端 IP 地址的请求会被调度至相同的 Realserver。sh 算法的目的是实现 session affinity（会话绑定），但是它也在一定程度上损害了负载均衡的效果。如果集群本身有 session sharing 机制或者没有 session 信息，那么不需要使用 sh 算法
- dh：destination hash，和 sh 类似，dh 将请求的目标地址进行哈希，将相同 IP 的请求发送至同一主机，dh 机制的目的是，当 Realserver 为透明代理缓存服务器时，提高缓存的命中率。

## 动态调度算法Dynamic Scheduling Method 

动态调度算法在调度时，会根据后端 Realserver 的负载状态来决定调度选择，Realserver 的负载状态通常由活动链接（active），非活动链接（inactive）和权重来计算。

- lc：least connted，最少连接，LVS 根据`overhead = active*256 + inactive` 计算服务器的负载状态，每次选择 overhead 最小的服务器。當各個服務器的處理能力不同時，該算法並不理想，因為TCP連接處理請求後會進入TIMEWAIT狀態，TCP的TIMEWAIT一般 為2分鐘，此時連接還佔用服務器的資源，所以會出現這樣情形：性能高的服務器已處理所收到的連接，連接處於TIME_WAIT狀態，而性能低的服務器忙於處理所收到的連接，還不斷地收到新的連接請求。
- wlc：weighted lc，加权最少连接，LVS 根据 `overhead = (active*256+inactive)/weight` 来计算服务器负载，每次选择 overhead 最小的服务器，它是 LVS 的默认调度算法
- sed：shortest expected delay，最短期望延迟，它不对 inactive 状态的连接进行计算，根据 overhead = (active+1)*256/weight 计算服务器负载，选择 overhead 最小的服务器进行调度
- nq：never queue，当有空闲服务器时，直接调度至空闲服务器，当没有空闲服务器时，使用 SED 算法进行调度
- LBLC：locality based least connection，基于本地的最少连接，相当于 dh + wlc，正常请求下使用 dh 算法进行调度，如果服务器超载，则使用 wlc 算法调度至其他服务器。針對 request 的 destination IP address 的負載均衡調度，目前主要用於Cache cluster，因為在 Cache 集群中，client request 的目標IP地址是變化的。這裡假設任何後端服務器都可以處理任一請求，算法的設計目標是在服務器的負載基本平衡情況下，將相同目標IP地址的request 轉發到同一台服務器，來提高各台服務器的訪問局部性和主存Cache命中率，從而整個集群系統的處理能力。
- LBLCR：locality based least connection with replication，基于本地的带复制功能的最少连接，与 LBLC 不同的是 LVS 将请求 IP 映射至一个服务池中，使用 dh 算法调度请求至对应的服务池中，使用 lc 算法选择服务池中的节点，当服务池中的所有节点超载，使用 lc 算法从所有后端 Realserver 中选择一个添加至服务吃中。也是針對目標IP地址的負載均衡，目前主要用於Cache集群系統。它與LBLC算法的不同之處是它要維護從一個目標IP地址到一組服務器的映射，而LBLC算法維護從一個目標IP地址到一台服務器的映射。對於一個“熱門”站點的服務請求，一台Cache 服務器可能會忙不過來處理這些請求。這時，LBLC調度算法會從所有的Cache服務器中按“最小連接”原則選出一台Cache服務器，映射該“熱門”站 點到這台Cache服務器，很快這台Cache服務器也會超載，就會重複上述過程選出新的Cache服務器。這樣，可能會導致該“熱門”站點的映像會出現 在所有的Cache服務器上，降低了Cache服務器的使用效率。LBLCR調度算法將“熱門”站點映射到一組Cache服務器（服務器集合），當該“熱 門”站點的請求負載增加時，會增加集合裡的Cache服務器，來處理不斷增長的負載；當該“熱門”站點的請求負載降低時，會減少集合裡的Cache服務器 數目。這樣，該“熱門”站點的映像不太可能出現在所有的Cache服務器上，從而提供Cache集群系統的使用效率。

# 命令

## ipvsadm

ipvsadm 用于配置 LVS 的调度规则，管理集群服务和 Realserver

```
添加：-A -t|u|f service-address [-s scheduler]
	 -t: TCP协议的集群
	 -u: UDP协议的集群
		service-address:     IP:PORT
	 -f: FWM: 防火墙标记
		service-address: Mark Number
修改：-E
删除：-D -t|u|f service-address

例如：
# ipvsadm -A -t 10.10.0.1:80 -s rr
```

管理集群服务中的 RS

```
添加：-a -t|u|f service-address -r server-address [-g|i|m] [-w weight]
	-t|u|f service-address：事先定义好的某集群服务
	-r server-address: 某RS的地址，在NAT模型中，可使用IP：PORT实现端口映射；
	[-g|i|m]: LVS类型
		-g: DR
		-i: TUN
		-m: NAT
	[-w weight]: 定义服务器权重
修改：-e
删除：-d -t|u|f service-address -r server-address

例如：
# ipvsadm -a -t 10.10.0.2:80 -r 192.168.10.8 -m
# ipvsadm -a -t 10.10.0.3:80 -r 192.168.10.9 -m
```

查看规则

```
-L|-l
-n：数字格式显式主机地址和端口
--stats：统计数据
--rate: 速率
--timeout: 显示tcp、tcpfin和udp的会话超时时长
-c: 显示当前的ipvs连接状况
```

删除所有集群服务

```
-C：清空 ipvs 规则
```

保存规则

```
-S
如：
# ipvsadm -S > /path/to/somefile
```

载入保存的规则

```
-R
如：
# ipvsadm -R < /path/from/somefile
```

# DR 模型的配置

## DR 模型的 Realserver 禁止 ARP 响应

对于 Linux 来说，地址是属于主机的，Linux 主机在开机时会通告连接所有网络内的所有其他主机自己的所有 ip 地址和 mac 地址。

可以利用 Linux 的特性，将VIP配置在 Realserver 的本地回环接口上作为别名，并使用 arp_ignore 和 arp_annouce 内核参数。

## 禁止 ARP 响应的方式

arptables：红帽系统上提供的程序

修改内核参数：

- arp_ignore：定义接收到 ARP 请i去时的响应级别
  - 0：只要本地配置有响应地址，就给与响应
  - 1：表示Real Server的网卡接收到网络上发来对VIP的ARP广播包，Real Server的将会丢弃；因为如果做出应答，根据ARP协议，相当于通告网络上其它的请求主机，VIP对应的MAC地址是Real Server的Mac地址，而不是Director的MAC地址，这样客户端请求就会绕过Director，直接与后端的Real Server通信。
- arp_announce：定义主机将自己的地址向外通告时的通告级别
  - 0：将本地任何接口上的任何地址向外通告
  - 1：向目标网络通告与其网络匹配的地址
  - 2：仅向本地接口上匹配的网络进行通告

当请求 Realserver 时，Realserver 的 VIP 是 lo 接口的别名，而 VIP 对外的通信实际需要使用的却是 eth0 接口，因此需要添加路由条目，让主机在使用 VIP 向外通信时，强制使用 lo 端口，因而它会使用 lo 端口的地址作为源 IP 进行响应，并最终由 lo 接口转发至 eth0 接口发出报文。

```shell
/sbin/route add -host $VIP dev lo:0
```

# DR实施测试

Director 10.1.0.2		eth0:0	vip 10.1.0.102

```
[root@ad-manage-test1 ~]# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
10.1.0.0        0.0.0.0         255.255.255.0   U     0      0        0 eth0
169.254.0.0     0.0.0.0         255.255.0.0     U     1002   0        0 eth0
0.0.0.0         10.1.0.1        0.0.0.0         UG    0      0        0 eth0
```



RealServer 10.1.0.3	lo:0		vip 10.1.0.102

```shell
[root@ad-manage-test2 ~]# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
10.1.0.0        0.0.0.0         255.255.255.0   U     0      0        0 eth0
169.254.0.0     0.0.0.0         255.255.0.0     U     1002   0        0 eth0
0.0.0.0         10.1.0.1        0.0.0.0         UG    0      0        0 eth0
```



## RealServer

添加lo:0 vip

```shell
DEVICE=lo:0
BOOTPROTO=static
IPADDR=10.1.0.102
# 配置成专用网络，并且只有lo:0一台主机
broadcast=10.1.0.102
NETMASK=255.255.255.255
ONBOOT=yes
TYPE=Ethernet
```

或者临时添加

```shell
ifconfig lo:0 10.1.0.102 broadcast 10.1.0.102 netmask 255.255.255.255 up
```

对网络内的VIP的ARP请求，Real Server不响应，只有Director响应，这样Client的请求就能首先路由到Director，再由Director转发到Real Server

```shell
echo 1 > /proc/sys/net/ipv4/conf/lo/arp_ignore
echo 2 > /proc/sys/net/ipv4/conf/lo/arp_announce

echo 1 > /proc/sys/net/ipv4/conf/all/arp_ignore
echo 2 > /proc/sys/net/ipv4/conf/all/arp_announce

echo 0 > /proc/sys/net/ipv4/conf/all/arp_ignore
echo 0 > /proc/sys/net/ipv4/conf/all/arp_announce
```

Director转发client的请求到Real Server后，Real Server通过eth0--RIP接收处理，而响应回去的源地址需要为VIP，即通过lo:0--VIP接口返回，而不是RIP接口

```shell
# route del -host 10.1.0.102 dev lo:0
route add -host 10.1.0.102 dev lo:0
```

启动apache

```
yum install httpd
service httpd start
```

若访问拒绝

```
[root@ad-manage-test2 ~]# wget localhost
--2016-11-02 10:58:25--  http://localhost/
Resolving localhost... ::1, 127.0.0.1
Connecting to localhost|::1|:80... connected.
HTTP request sent, awaiting response... 403 Forbidden
2016-11-02 10:58:25 ERROR 403: Forbidden.
```

分析日志

```

[root@ad-manage-test2 ~]# tail /var/log/httpd/error_log -n 1
[Wed Nov 02 10:58:25 2016] [error] [client ::1] Directory index forbidden by Options directive: /var/www/html/
```

解决办法：

```shell
echo 'hello' > /var/www/html/index.html
chown apache.apache /var/www/html/index.html
service httpd restart
```

## Director

若不存在安装ipvsadm

```
[root@ad-manage-test1 yum.repos.d]# vi centos.repo
[centos6-iso]
name=centos6-iso
baseurl=http://centos.ustc.edu.cn/centos/6/os/x86_64/
enabled=1
gpgcheck=0

[centos6-updates]
name=centos6-updates
baseurl=http://centos.ustc.edu.cn/centos/6/updates/x86_64/
enabled=1
gpgcheck=0
```



```shell
yum install ipvsadm
```



```shell
# ifconfig eth0:0 10.1.0.102 broadcast 10.1.0.255 netmask 255.255.255.0 up
ifconfig eth0:0 10.1.0.102 broadcast 10.1.0.102 netmask 255.255.255.255 up
```

添加route

```shell
# route del -host 10.1.0.102 dev eth0:0
route add -host 10.1.0.102 dev eth0:0
```

配置转发

```
ipvsadm -C
ipvsadm -A -t 10.1.0.102:80 -s wrr
ipvsadm -a -t 10.1.0.102:80 -r 10.1.0.3 -g -w 1
ipvsadm -L -n
```



```shell
echo 1 > /proc/sys/net/ipv4/ip_forward
```

## 测试

在Director上访问

```shell
[root@ad-manage-test1 ~]# wget 10.1.0.102                       
--2016-11-02 11:04:55--  http://10.1.0.102/
Connecting to 10.1.0.102:80... failed: Connection timed out.
Retrying.
```

访问失败，问题排查

```shell
[root@ad-manage-test1 ~]# yum install -y tcpdump
[root@ad-manage-test1 ~]# tcpdump -n dst 10.1.0.3 -vv
tcpdump: listening on eth0, link-type EN10MB (Ethernet), capture size 65535 bytes
11:06:04.277563 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 10.1.0.3 tell 10.1.0.2, length 28
11:06:35.277606 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 10.1.0.3 tell 10.1.0.2, length 28
```



# 参考

- [三種 LVS 的模式：LVS-NAT、LVS-TUN、LVS-DR](http://blog.maxkit.com.tw/2016/05/lvs-lvs-natlvs-tunlvs-dr.html)
- [负载均衡集群 LVS 详解](http://liaoph.com/lvs/)
- http://www.linuxvirtualserver.org/zh/index.html
- http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.LVS-NAT.html#one_network
- [LINUX集群--均衡负载 LVS（二） NAT和DR的应用配置](http://blog.csdn.net/tjiyu/article/details/52493597?locationNum=5&fps=1)
- [LINUX集群--均衡负载 LVS（三） LVS后端服务健康状态检查](http://blog.csdn.net/tjiyu/article/details/52497674)
- [keepalived 及 keepalived配置LVS高可用集群](http://blog.csdn.net/tjiyu/article/details/52891835)

