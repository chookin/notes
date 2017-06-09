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

