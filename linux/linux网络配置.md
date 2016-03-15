# 网络
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
# 该规则表示INPUT表默认策略是ACCEPT
:INPUT ACCEPT [0:0]
# 该规则表示FORWARD表默认策略是ACCEPT
:FORWARD ACCEPT [0:0]
# 该规则表示OUTPUT表默认策略是ACCEPT
:OUTPUT ACCEPT [0:0]
# 允许已建立的或相关连的通行
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
# 向指定网段开放
-A INPUT -s 192.168.0.0/255.255.255.0 -j ACCEPT
#允许本地回环接口(即运行本机访问本机)
-A INPUT -s 127.0.0.1 -d 127.0.0.1 -j ACCEPT 
# 开放22端口
-A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
# -A INPUT -p icmp -j ACCEPT
# 下面两条的意思是在INPUT表和FORWARD表中拒绝所有其他不符合上述任何一条规则的数据包。并且发送一条host prohibited的消息给被拒绝的主机。
-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A FORWARD -j REJECT --reject-with icmp-host-prohibited
-A OUTPUT -j ACCEPT
COMMIT
```

## dns
```
echo 'nameserver 8.8.8.8' > /etc/resolv.conf
```
