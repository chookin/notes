
# 进程
## ps
ps参数太多，具体使用方法可以参考man ps，常用的方法：`ps  aux  #hsserver`；`ps –ef |grep #hundsun`
▪ 杀掉某一程序的方法：`ps  aux | grep mysqld | grep –v grep | awk ‘{print $2 }’ xargs kill -9`
▪ 杀掉僵尸进程：`ps –eal | awk ‘{if ($2 == “Z”){print $4}}’ | xargs kill -9`

```sh
➜  extra ps -C httpd -f
UID         PID   PPID  C STIME TTY          TIME CMD
work     156716      1  0 16:24 ?        00:00:00 /home/work/local/apache-2.4.27/bin/httpd -k restart
work     159090 156716 20 16:27 ?        00:00:35 /home/work/local/apache-2.4.27/bin/httpd -k restart
```
```
字　段          含义
USER            进程所有者的用户名
PID                进程号
%CPU           进程自最近一次刷新以来所占用的CPU时间和总时间的百分比
%MEM          进程使用内存的百分比
VSZ              进程使用的虚拟内存大小，以K为单位
RSS              驻留空间的大小。显示当前常驻内存的程序的K字节数。
TTY              进程相关的终端
STAT            进程状态，用下面的代码中的一个给出：
                     D    不可中断     Uninterruptible sleep (usually IO)
                     R    正在运行，或在队列中的进程
                     S    处于休眠状态
                     T    停止或被追踪
                     Z    僵尸进程
                     W    进入内存交换（从内核2.6开始无效）
                     X    死掉的进程
                     <    高优先级
                     N    低优先级
                     L    有些页被锁进内存
                     s    包含子进程
                     +    位于后台的进程组；
                     l    多线程，克隆线程

TIME            进程使用的总CPU时间
COMMAND  被执行的命令行
NI                 进程的优先级值，较小的数字意味着占用较少的CPU时间
PRI               进程优先级。
PPID             父进程ID
WCHAN        进程等待的内核事件名
```

## htop
Htop是一款运行于Linux系统监控与进程管理软件，用于取代Unix下传统的top。与top只提供最消耗资源的进程列表不同，htop提供所有进程的列表，并且使用彩色标识出处理器、swap和内存状态。

```sh
➜  ~ htop

  1  [||             1.4%]    9  [|              0.5%]     17 [|              0.5%]    25 [               0.0%]
  2  [||             1.9%]    10 [               0.0%]     18 [               0.0%]    26 [|              0.5%]
  3  [|              0.5%]    11 [|              4.3%]     19 [               0.0%]    27 [               0.0%]
  4  [||             1.9%]    12 [               0.0%]     20 [|              0.5%]    28 [               0.0%]
  5  [|              1.9%]    13 [               0.0%]     21 [|              0.5%]    29 [               0.0%]
  6  [||             1.4%]    14 [               0.0%]     22 [               0.0%]    30 [               0.0%]
  7  [||             0.9%]    15 [               0.0%]     23 [               0.0%]    31 [               0.0%]
  8  [|              1.9%]    16 [               0.0%]     24 [               0.0%]    32 [               0.0%]
  Mem[|||||||||||||||||||||||||||||||||11533/193584MB]     Tasks: 132, 844 thr; 1 running
  Swp[|                                      1/4095MB]     Load average: 0.00 0.00 0.00
                                                           Uptime: 218 days(!), 02:08:09

  PID USER      PRI  NI  VIRT   RES   SHR S CPU% MEM%   TIME+  Command
68481 root       20   0 18.3G 3663M 3607M S 16.0  1.9     422h /usr/lib/vmware/bin/vmware-vmx -s sched.group= -# pr
68544 root       20   0 18.3G 3663M 3607M S  4.7  1.9     108h /usr/lib/vmware/bin/vmware-vmx -s sched.group= -# pr
68540 root       20   0 18.3G 3663M 3607M S  2.8  1.9 91h29:40 /usr/lib/vmware/bin/vmware-vmx -s sched.group= -# pr
68537 root       20   0 18.3G 3663M 3607M S  1.9  1.9 58h48:00 /usr/lib/vmware/bin/vmware-vmx -s sched.group= -# pr
68543 root       20   0 18.3G 3663M 3607M S  1.4  1.9 37h05:12 /usr/lib/vmware/bin/vmware-vmx -s sched.group= -# pr
68539 root       20   0 18.3G 3663M 3607M S  1.9  1.9 36h13:20 /usr/lib/vmware/bin/vmware-vmx -s sched.group= -# pr
68542 root       20   0 18.3G 3663M 3607M S  1.4  1.9 29h24:45 /usr/lib/vmware/bin/vmware-vmx -s sched.group= -# pr
68538 root       20   0 18.3G 3663M 3607M S  0.5  1.9 27h43:31 /usr/lib/vmware/bin/vmware-vmx -s sched.group= -# pr
68541 root       20   0 18.3G 3663M 3607M S  0.9  1.9 25h43:45 /usr/lib/vmware/bin/vmware-vmx -s sched.group= -# pr
 7525 hadoop     20   0 1839M  284M 17392 S  0.0  0.1  7h29:23 /usr/local/jdk1.7.0_79/bin/java -Dproc_resourcemanag
 7654 hadoop     20   0 1758M  310M 17388 S  0.0  0.2  5h51:46 /usr/local/jdk1.7.0_79/bin/java -Dproc_nodemanager -
143181 work       20   0  465M 41088 10524 S  0.0  0.0  4h16:00 bin/mongod --port 11111 --dbpath /home/work/local/m
107327 ganglia    20   0  555M  6928  1064 S  1.4  0.0  3h59:21 /usr/sbin/gmetad
49760 zhuyin     20   0  987M 50092 12744 S  0.5  0.0  3h15:36 mongod --dbpath=/data/zhuyin/mongo/data/ --logpath=/
139449 gdm        20   0  429M 39008  9168 S  0.0  0.0  3h11:39 /usr/libexec/gnome-settings-daemon --gconf-prefix=/
104598 root       20   0 1924M  124M 71876 S  0.0  0.1  2h36:53 /usr/lib/vmware/bin/vmware-hostd -a /etc/vmware/hos
160103 test_dati  20   0  565M 28620  8396 S  0.0  0.0  2h17:26 /usr/libexec/gnome-settings-daemon
107336 ganglia    20   0  555M  6928  1064 S  0.9  0.0  1h57:00 /usr/sbin/gmetad
```

##  查看进程确切启动时间

```shell
ps -eO lstart
```

## 查看进程数


```shell
[root@localhost cron.hourly]# pstree
init─┬─.sshd───{.sshd}
     ├─7───3*[{7}]
     ├─abrtd
     ├─acpid
     ├─atd
     ├─auditd───{auditd}
     ├─automount───4*[{automount}]
     ├─5*[bjtpdnodbk]
     ├─catalina.sh───java───822*[{java}]
     ├─certmonger
     ├─console-kit-dae───63*[{console-kit-da}]
     ├─crond
     ├─cronolog
     ├─cupsd
     ├─dbus-daemon
     ├─hald─┬─hald-runner─┬─hald-addon-acpi
     │      │             └─hald-addon-inpu
     │      └─{hald}
     ├─irqbalance
     ├─mcelog
     ├─memcached───5*[{memcached}]
     ├─6*[mingetty]
     ├─mysqld_safe───mysqld───72*[{mysqld}]
     ├─rhsmcertd
     ├─rpc.statd
     ├─rpcbind
     ├─rsyslogd───3*[{rsyslogd}]
     ├─sshd─┬─sshd───bash───pstree
     │      ├─sshd───bash
     │      └─2*[sshd───sftp-server]
     ├─tty───8*[{tty}]
     └─udevd───2*[udevd]
```

## 停止进程运行

```shell
kill -STOP 16621
```

## 结束进程

```shell
jps | grep appname | awk '{print $1}' | xargs kill -9
ps axu |grep gradle |grep -v grep |  awk '{print $2}' | xargs kill -9
pgrep appname | xargs kill -9
```

## 跟踪进程
strace常用来跟踪进程执行时的系统调用和所接收的信号。 在Linux世界，进程不能直接访问硬件设备，当进程需要访问硬件设备(比如读取磁盘文件，接收网络数据等等)时，必须由用户态模式切换至内核态模式，通 过系统调用访问硬件设备。strace可以跟踪到一个进程产生的系统调用,包括参数，返回值，执行消耗的时间。

```sh
➜  ~  strace cat /dev/null
execve("/bin/cat", ["cat", "/dev/null"], [/* 27 vars */]) = 0
brk(0)                                  = 0x10bd000
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f3baa2a5000
access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory)
open("/etc/ld.so.cache", O_RDONLY)      = 3
fstat(3, {st_mode=S_IFREG|0644, st_size=36160, ...}) = 0
mmap(NULL, 36160, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7f3baa29c000
close(3)                                = 0
open("/lib64/libc.so.6", O_RDONLY)      = 3
read(3, "\177ELF\2\1\1\3\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0000\356\1\0\0\0\0\0"..., 832) = 832
fstat(3, {st_mode=S_IFREG|0755, st_size=1923352, ...}) = 0
mmap(NULL, 3750184, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7f3ba9cf3000
mprotect(0x7f3ba9e7d000, 2097152, PROT_NONE) = 0
mmap(0x7f3baa07d000, 24576, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x18a000) = 0x7f3baa07d000
mmap(0x7f3baa083000, 14632, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7f3baa083000
close(3)                                = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f3baa29b000
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f3baa29a000
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f3baa299000
arch_prctl(ARCH_SET_FS, 0x7f3baa29a700) = 0
mprotect(0x7f3baa07d000, 16384, PROT_READ) = 0
mprotect(0x7f3baa2a6000, 4096, PROT_READ) = 0
munmap(0x7f3baa29c000, 36160)           = 0
brk(0)                                  = 0x10bd000
brk(0x10de000)                          = 0x10de000
open("/usr/lib/locale/locale-archive", O_RDONLY) = 3
fstat(3, {st_mode=S_IFREG|0644, st_size=99164480, ...}) = 0
mmap(NULL, 99164480, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7f3ba3e60000
close(3)                                = 0
fstat(1, {st_mode=S_IFCHR|0620, st_rdev=makedev(136, 0), ...}) = 0
open("/dev/null", O_RDONLY)             = 3
fstat(3, {st_mode=S_IFCHR|0666, st_rdev=makedev(1, 3), ...}) = 0
read(3, "", 32768)                      = 0
close(3)                                = 0
close(1)                                = 0
close(2)                                = 0
exit_group(0)                           = ?
+++ exited with 0 +++
```

每一行都是一条系统调用，等号左边是系统调用的函数名及其参数，右边是该调用的返回值。
strace 显示这些调用的参数并返回符号形式的值。strace 从内核接收信息，而且不需要以任何特殊的方式来构建内核。

strace参数

```
-c 统计每一系统调用的所执行的时间,次数和出错的次数等.
-d 输出strace关于标准错误的调试信息.
-f 跟踪由fork调用所产生的子进程.
-ff 如果提供-o filename,则所有进程的跟踪结果输出到相应的filename.pid中,pid是各进程的进程号.
-F 尝试跟踪vfork调用.在-f时,vfork不被跟踪.
-h 输出简要的帮助信息.
-i 输出系统调用的入口指针.
-q 禁止输出关于脱离的消息.
-r 打印出相对时间关于,,每一个系统调用.
-t 在输出中的每一行前加上时间信息.
-tt 在输出中的每一行前加上时间信息,微秒级.
-ttt 微秒级输出,以秒表示时间.
-T 显示每一调用所耗的时间.
-v 输出所有的系统调用.一些调用关于环境变量,状态,输入输出等调用由于使用频繁,默认不输出.
-V 输出strace的版本信息.
-x 以十六进制形式输出非标准字符串
-xx 所有字符串以十六进制形式输出.
-a column
设置返回值的输出位置.默认 为40.
-e expr
指定一个表达式,用来控制如何跟踪.格式如下:
[qualifier=][!]value1[,value2]...
qualifier只能是 trace,abbrev,verbose,raw,signal,read,write其中之一.value是用来限定的符号或数字.默认的 qualifier是 trace.感叹号是否定符号.例如:
-eopen等价于 -e trace=open,表示只跟踪open调用.而-etrace!=open表示跟踪除了open以外的其他调用.有两个特殊的符号 all 和 none.
注意有些shell使用!来执行历史记录里的命令,所以要使用\\.
-e trace=set
只跟踪指定的系统 调用.例如:-e trace=open,close,rean,write表示只跟踪这四个系统调用.默认的为set=all.
-e trace=file
只跟踪有关文件操作的系统调用.
-e trace=process
只跟踪有关进程控制的系统调用.
-e trace=network
跟踪与网络有关的所有系统调用.
-e strace=signal
跟踪所有与系统信号有关的 系统调用
-e trace=ipc
跟踪所有与进程通讯有关的系统调用
-e abbrev=set
设定 strace输出的系统调用的结果集.-v 等与 abbrev=none.默认为abbrev=all.
-e raw=set
将指 定的系统调用的参数以十六进制显示.
-e signal=set
指定跟踪的系统信号.默认为all.如 signal=!SIGIO(或者signal=!io),表示不跟踪SIGIO信号.
-e read=set
输出从指定文件中读出 的数据.例如:
-e read=3,5
-e write=set
输出写入到指定文件中的数据.
-o filename
将strace的输出写入文件filename
-p pid
跟踪指定的进程pid.
-s strsize
指定输出的字符串的最大长度.默认为32.文件名一直全部输出.
-u username
以username 的UID和GID执行被跟踪的命令
```

命令实例

```sh
strace -tt -T -f -o stracelog -s 1024  -p `pidof httpd | tr ' ' ','`
```

上面的含义是跟踪httpd进程的所有系统调用，并统计系统调用的花费时间，以及开始时间（并以可视化的时分秒格式显示）。输出中，第一列显示的是进程的pid, 接着是毫秒级别的时间，这个是-tt 选项的效果。每一行的最后一列，显示了该调用所花的时间，是-T选项的结果。跟踪日志记录到文件stracelog中。

```
➜  extra tail stracelog
186695 13:55:33.476641 select(0, NULL, NULL, NULL, {0, 776734}) = 0 (Timeout) <0.778002>
186695 13:55:34.255379 wait4(-1, 0x7fff0f2dfcbc, WNOHANG|WSTOPPED, NULL) = 0 <0.000045>
186695 13:55:34.255581 select(0, NULL, NULL, NULL, {1, 0}%
```

对strace的记录排序

```sh
cat stracelog.72585 |awk -F '\<' '{OFS="]"}{print $1,$2}'|awk -F '\>' '{print $1}'|sort -b -t ']' -k 2 -nr
```

- [Linux strace命令](http://www.cnblogs.com/ggjucheng/archive/2012/01/08/2316692.html)
- [硬件·内核·Shell·监测 » strace](http://man.linuxde.net/strace)
- [How to use strace for a daemon with multiple processes, including children](https://baheyeldin.com/technology/linux/how-use-strace-daemon-multiple-processes-including-children.html)
- [运维利器：万能的 strace](https://mp.weixin.qq.com/s?__biz=MzA4Nzg5Nzc5OA==&mid=2651659767&idx=1&sn=3c515cb32bcbcafe16c749024d1545ef&scene=0#wechat_redirect)

## gdb

- [Apache Debugging Guide](https://svn.apache.org/repos/asf/httpd/site/branches/ASF/docs/dev/debugging.html)
