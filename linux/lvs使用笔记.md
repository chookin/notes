lvs server的转发ip不能和client的处于同一网段。如果不能满足，还需要添加子网。
# 安装
1.在lvs server服务器上安装 ipvadm
```shell
yum install -y ipvsadm
```
2.设置默认网关 server client
```shell
lvs_server_inner_ip=192.168.110.221
route del -net 0.0.0.0 netmask 0.0.0.0
route add -net default netmask 0.0.0.0 gw $lvs_server_inner_ip
```
3.开启转发  server client
```shell
echo 1 > /proc/sys/net/ipv4/ip_forward
```
4.设置ipvs转发 server
```shell
ipvsadm -C
lvs_server_outer_ip=111.13.47.171
# 设置转发算法为加权轮叫调度（Weighted Round Robin）
ipvsadm -A -t $lvs_server_outer_ip:8001 -s wrr
ipvsadm -a -t $lvs_server_outer_ip:8001 -r 192.168.110.222:21889 -m
```
5.查看配置的现有转发
```shell
# /sbin/ipvsadm -l
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  111.13.47.171:vcom-tunnel wrr
  -> dsp02.cm:21889               Masq    1      0          0 
```
