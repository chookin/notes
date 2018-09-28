# nat模式

lvs server的转发ip不能和client的处于同一网段。如果不能满足，还需要添加子网。

# 安装
1.在lvs director服务器上安装 ipvadm

```shell
yum install -y ipvsadm
```
2.设置默认网关

在real server上执行如下脚本

```shell
# lvs server的内网ip
lvs_server_inner_ip=192.168.110.221
route add -net default netmask 0.0.0.0 gw $lvs_server_inner_ip
```
3.开启转发

分别在real server上执行

```shell
echo 1 > /proc/sys/net/ipv4/ip_forward
```
4.设置ipvs转发

在director上执行

```shell
ipvsadm -C
# lvs server的外网ip
lvs_server_outer_ip=111.13.47.171

# 设置转发算法为加权轮叫调度（Weighted Round Robin），端口为8001
ipvsadm -A -t $lvs_server_outer_ip:8001 -s wrr

# 添加realserver
# 转发到机器192.168.110.222的端口21889
ipvsadm -a -t $lvs_server_outer_ip:8001 -r 192.168.110.222:21889 -m
```

ipvsadm -A -t 117.136.183.142:443 -s wrr
ipvsadm -a -t 117.136.183.142:443 -r 172.31.167.127:8443 -m
ipvsadm -a -t 117.136.183.142:443 -r 172.31.167.125:8443 -m
ipvsadm -a -t 117.136.183.142:443 -r 172.31.167.124:8443 -m
ipvsadm -a -t 117.136.183.142:443 -r 172.31.167.123:8443 -m


5.查看配置的现有转发

```shell
# /sbin/ipvsadm -Ln
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  111.13.47.171:vcom-tunnel wrr
  -> dsp02.cm:21889               Masq    1      0          0
```


http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.LVS-NAT.html#one_network

