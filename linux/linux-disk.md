
## 查看磁盘挂载

```shell
[root@ad-check1 ~]# df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/vda1        40G   24G   15G  63% /
tmpfs            16G     0   16G   0% /dev/shm
/dev/vdb        197G  121G   67G  65% /data
```

# dstat--系统监控工具
dstat显示了cpu使用情况，磁盘io情况，网络发包情况和换页情况，输出是彩色的，可读性较强，相对于vmstat和iostat的输入更加详细且较为直观。

```sh
[work@lab22 logs]$ dstat -cdlmnpsy
----total-cpu-usage---- -dsk/total- ---load-avg--- ------memory-usage----- -net/total- ---procs--- ----swap--- ---system--
usr sys idl wai hiq siq| read  writ| 1m   5m  15m | used  buff  cach  free| recv  send|run blk new| used  free| int   csw
  0   0 100   0   0   0| 230B 8453B|0.06 0.14 0.16|3344M  615M 32.6G  153G|   0     0 |  0   0 0.2|   0  4096M| 303   267
  0   0 100   0   0   0|   0     0 |0.06 0.14 0.16|3344M  615M 32.6G  153G|3195B 4099B|  0   0   0|   0  4096M| 292   346
  0   0 100   0   0   0|   0     0 |0.05 0.14 0.16|3344M  615M 32.6G  153G|3056B 3322B|  0   0   0|   0  4096M| 227   226
  0   0 100   0   0   0|   0     0 |0.05 0.14 0.16|3343M  615M 32.6G  153G|1075B 1523B|  0   0   0|   0  4096M| 169   220
  0   0 100   0   0   0|   0     0 |0.05 0.14 0.16|3343M  615M 32.6G  153G|2580B 2314B|  0   0   0|   0  4096M| 180   196
  0   0 100   0   0   0|   0     0 |0.05 0.14 0.16|3343M  615M 32.6G  153G|1460B 1353B|  0   0   0|   0  4096M| 148   214
```

# iotop--LINUX进程实时监控工具
iotop命令是专门显示硬盘IO的命令，界面风格类似top命令，可以显示IO负载具体是由哪个进程产生的。是一个用来监视磁盘I/O使用状况的top类工具，具有与top相似的UI，其中包括PID、用户、I/O、进程等相关信息。

```sh
➜  ~ iotop
Total DISK READ: 0.00 B/s | Total DISK WRITE: 2.24 M/s
  TID  PRIO  USER     DISK READ  DISK WRITE  SWAPIN     IO>    COMMAND
 1097 be/3 root        0.00 B/s    0.00 B/s  0.00 %  0.26 % [jbd2/dm-0-8]
107327 be/4 ganglia     0.00 B/s   30.33 K/s  0.00 %  0.00 % gmetad
 2673 be/4 root        0.00 B/s  966.61 K/s  0.00 %  0.00 % [flush-253:0]
13089 be/4 root        0.00 B/s    3.79 K/s  0.00 %  0.00 % python /usr/sbin/tuned -d -c /etc/tuned.conf
 6958 be/4 hadoop      0.00 B/s    3.79 K/s  0.00 %  0.00 % java -Dproc_namenode -Xmx10~fs.server.namenode.NameNode
 7575 be/4 hadoop      0.00 B/s    3.79 K/s  0.00 %  0.00 % java -Dproc_resourcemanager~urcemanager.ResourceManager
 7704 be/4 hadoop      0.00 B/s    3.79 K/s  0.00 %  0.00 % java -Dproc_nodemanager -Xm~ver.nodemanager.NodeManager
    1 be/4 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % init
    2 be/4 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % [kthreadd]
    3 rt/4 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % [migration/0]
    4 be/4 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % [ksoftirqd/0]
    5 rt/4 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % [migration/0]
    6 rt/4 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % [watchdog/0]
    7 rt/4 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % [migration/1]
    8 rt/4 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % [migration/1]
    9 be/4 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % [ksoftirqd/1]
   10 rt/4 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % [watchdog/1]
```

## iostat

iostat用于报告中央处理器（CPU）统计信息和整个系统、适配器、tty 设备、磁盘和 CD-ROM 的输入/输出统计信息.

```shell
iostat -t -d -x -k 1 10
```

```
-d：显示某块具体硬盘，这里没有给出硬盘路径就是默认全部了
-k：以KB为单位显示
-t: 打印出时间信息
-x： 打印出额外信息
1：统计间隔为1秒
10：共统计10次的
tps：该设备每秒的传输次数（Indicate the number of transfers per second that were issued to the device.）。“一次传输”意思是“一次I/O请求”。多个逻辑请求可能会被合并为“一次I/O请求”。“一次传输”请求的大小是未知的。
```

```
[work@lab22 logs]$ iostat -t -d -x -k 1 10
Linux 2.6.32-573.18.1.el6.x86_64 (lab22)        07/13/2017      _x86_64_        (32 CPU)

07/13/2017 05:12:21 PM
Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
sda               0.00     1.09    0.01    0.96     0.22     8.18    17.44     0.00    0.48   0.33   0.03
sdb               0.00     0.00    0.00    0.00     0.00     0.08   423.29     0.00   42.75   0.44   0.00
dm-0              0.00     0.00    0.00    0.73     0.05     2.92     8.08     0.00    0.42   0.16   0.01
dm-1              0.00     0.00    0.00    0.00     0.00     0.00     8.00     0.00    0.90   0.88   0.00
dm-2              0.00     0.00    0.00    1.31     0.18     5.26     8.25     0.00    1.73   0.15   0.02
```
```sh
rrqm/s:   每秒进行 merge 的读操作数目.即 delta(rmerge)/s
wrqm/s:  每秒进行 merge 的写操作数目.即 delta(wmerge)/s
r/s:           每秒完成的读 I/O 设备次数.即 delta(rio)/s
w/s:         每秒完成的写 I/O 设备次数.即 delta(wio)/s
rsec/s:    每秒读扇区数.即 delta(rsect)/s
wsec/s: 每秒写扇区数.即 delta(wsect)/s
rkB/s:      每秒读K字节数.是 rsect/s 的一半,因为每扇区大小为512字节.(需要计算)
wkB/s:    每秒写K字节数.是 wsect/s 的一半.(需要计算)
avgrq-sz: 平均每次设备I/O操作的数据大小 (扇区).delta(rsect+wsect)/delta(rio+wio)
avgqu-sz: 平均I/O队列长度.即 delta(aveq)/s/1000(因为aveq的单位为毫秒).
await:    平均每次设备I/O操作的等待时间(毫秒).即 delta(ruse+wuse)/delta(rio+wio)
svctm:  平均每次设备I/O操作的服务时间 (毫秒).即 delta(use)/delta(rio+wio)
%util:     一秒中有百分之多少的时间用于 I/O 操作,或者说一秒中有多少时间 I/O 队列是非空的.即 delta(use)/s/1000 (因为use的单位为毫秒)
(如果 %util 接近 100%,说明产生的I/O请求太多,I/O系统已经满负荷,该磁盘可能存在瓶颈.
```
