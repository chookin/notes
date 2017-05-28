
## 查看磁盘挂载

```shell
[root@ad-check1 ~]# df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/vda1        40G   24G   15G  63% /
tmpfs            16G     0   16G   0% /dev/shm
/dev/vdb        197G  121G   67G  65% /data
```

## iostat

查看或监控磁盘的读写性能，可以用到iostat命令

```shell
iostat -d -k 1 10
```

```
-d：显示某块具体硬盘，这里没有给出硬盘路径就是默认全部了
-k：以KB为单位显示
1：统计间隔为1秒
10：共统计10次的
tps：该设备每秒的传输次数（Indicate the number of transfers per second that were issued to the device.）。“一次传输”意思是“一次I/O请求”。多个逻辑请求可能会被合并为“一次I/O请求”。“一次传输”请求的大小是未知的。
```
