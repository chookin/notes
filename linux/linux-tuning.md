# tuned

**tuned** is a daemon that monitors the use of system components and dynamically tunes system settings based on that monitoring information.

安装

```sh
yum install tuned
```

配置文件 `/etc/tuned.conf`

配置示例

```sh
[main]
interval=10
pidfile=/var/run/tuned.pid
logging=info
logging_disable=notset

# Disk monitoring section

[DiskMonitor]
enabled=True
logging=debug

# Disk tuning section

[DiskTuning]
enabled=True
hdparm=False
alpm=False
logging=debug

# Net monitoring section

[NetMonitor]
enabled=True
logging=debug

# Net tuning section

[NetTuning]
enabled=True
logging=debug

# CPU monitoring section

[CPUMonitor]
# Enabled or disable the plugin. Default is True. Any other value
# disables it.
enabled=True

# CPU tuning section

[CPUTuning]
# Enabled or disable the plugin. Default is True. Any other value
# disables it.
enabled=True
```

日志文件 `/var/log/tuned/tuned.log`

启动

```sh
service tuned start
```

- [tuned and ktune](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Power_Management_Guide/Tuned.html)

# sysctl.conf

```sh
# Kernel sysctl configuration file for Linux
#
# Version 1.12 - 2015-09-30
# Michiel Klaver - IT Professional
# http://klaver.it/linux/ for the latest version - http://klaver.it/bsd/ for a BSD variant
#
# This file should be saved as /etc/sysctl.conf and can be activated using the command:
# sysctl -e -p /etc/sysctl.conf
#
# For binary values, 0 is disabled, 1 is enabled.  See sysctl(8) and sysctl.conf(5) for more details.
#
# Tested with: Ubuntu 14.04 LTS kernel version 3.13
#              Debian 7 kernel version 3.2
#              CentOS 7 kernel version 3.10

#
# Intended use for dedicated server systems at high-speed networks with loads of RAM and bandwidth available
# Optimised and tuned for high-performance web/ftp/mail/dns servers with high connection-rates
# DO NOT USE at busy networks or xDSL/Cable connections where packetloss can be expected
# ----------

# Credits:
# http://www.enigma.id.au/linux_tuning.txt
# http://www.securityfocus.com/infocus/1729
# http://fasterdata.es.net/TCP-tuning/linux.html
# http://fedorahosted.org/ktune/browser/sysctl.ktune
# http://www.cymru.com/Documents/ip-stack-tuning.html
# http://www.kernel.org/doc/Documentation/networking/ip-sysctl.txt
# http://www.frozentux.net/ipsysctl-tutorial/chunkyhtml/index.html
# http://knol.google.com/k/linux-performance-tuning-and-measurement
# http://www.cyberciti.biz/faq/linux-kernel-tuning-virtual-memory-subsystem/
# http://www.redbooks.ibm.com/abstracts/REDP4285.html
# http://www.speedguide.net/read_articles.php?id=121
# http://lartc.org/howto/lartc.kernel.obscure.html
# http://en.wikipedia.org/wiki/Sysctl



###
### GENERAL SYSTEM SECURITY OPTIONS ###
###

# Controls the System Request debugging functionality of the kernel
# 如果该文件指定的值为非零，则激活 System Request Key
kernel.sysrq = 0

# Controls whether core dumps will append the PID to the core filename.
# Useful for debugging multi-threaded applications.
kernel.core_uses_pid = 1

#Allow for more PIDs
kernel.pid_max = 196608

# The contents of /proc/<pid>/maps and smaps files are only visible to
# readers that are allowed to ptrace() the process
kernel.maps_protect = 1

#Enable ExecShield protection
kernel.exec-shield = 1
kernel.randomize_va_space = 2

# Controls the maximum size of a message, in bytes
# 该文件指定在一个消息队列中最大的字节数。
kernel.msgmnb = 65536

# Controls the default maxmimum size of a mesage queue
# 该文件指定了从一个进程发送到另一个进程的消息的最大长度。进程间的消息传递是在内核的内存中进行，不会交换到磁盘上，所以如果增加该值，则将增加操作系统所使用的内存数量。
kernel.msgmax = 65536

# Restrict core dumps
fs.suid_dumpable = 0

# Hide exposed kernel pointers
kernel.kptr_restrict = 1



###
### IMPROVE SYSTEM MEMORY MANAGEMENT ###
###

# Increase size of file handles and inode cache, chookin
# fs.file-max = 209708
fs.file-max = 13129638

# Do less swapping
# swappiness=0的时候表示最大限度使用物理内存，然后才是swap空间，swappiness＝100的时候表示积极的使用swap分区，并且把内存上的数据及时的搬运到swap空间里面。
vm.swappiness = 30
# 指定了当文件系统缓存脏页数量达到系统内存百分之多少时（如10%），系统不得不开始处理缓存脏页（因为此时脏页数量已经比较多，为了避免数据丢失需要将一定脏页刷入外存）；在此过程中很多应用进程可能会因为系统转而处理文件IO而阻塞。
vm.dirty_ratio = 30
# 指定了当文件系统缓存脏页数量达到系统内存百分之多少时（如5%）就会触发pdflush/flush/kdmflush等后台回写进程运行，将一定缓存的脏页异步地刷入外存
vm.dirty_background_ratio = 5

# specifies the minimum virtual address that a process is allowed to mmap
vm.mmap_min_addr = 4096

# 50% overcommitment of available memory
vm.overcommit_ratio = 50
vm.overcommit_memory = 0

# Set maximum amount of memory allocated to shm to 256MB
# 指定内核所允许的最大共享内存段的大小(以字节为单位)
kernel.shmmax = 68719476736
# 在任何给定时刻系统上可以使用的共享内存的总量(以字节为单位)。
kernel.shmall = 4294967296

# Keep at least 88MB of free RAM space available
vm.min_free_kbytes = 90112



###
### GENERAL NETWORK SECURITY OPTIONS ###
###

#Prevent SYN attack, enable SYNcookies (they will kick-in when the max_syn_backlog reached)
net.ipv4.tcp_syncookies = 1
# 提供限制在建立连接时重新发送回应的SYN包的次数；
net.ipv4.tcp_syn_retries = 2
# 这个是三次握手中，服务器回应ACK给客户端里，重试的次数。默认是5。对于正常的客户端，如果它接收不到服务器回应的ACK包，它会再次发送SYN包，客户端还是能正常连接的，只是可能在某些情况下建立连接的速度变慢了一点。
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_max_syn_backlog = 8192

# Disables packet forwarding
# 接口是否可以转发包，缺省为0，设置为1时允许网络进行包转发；
##net.ipv4.ip_forward = 0
net.ipv4.conf.all.forwarding = 0
net.ipv4.conf.default.forwarding = 0
net.ipv6.conf.all.forwarding = 0
net.ipv6.conf.default.forwarding = 0

# Disables IP source routing
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0

# Enable IP spoofing protection, turn on source route verification
net.ipv4.conf.all.rp_filter = 1
# 启用源路由核查功能
net.ipv4.conf.default.rp_filter = 1

# Disable ICMP Redirect Acceptance
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0

# Enable Log Spoofed Packets, Source Routed Packets, Redirect Packets
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1

# Decrease the time default value for tcp_fin_timeout connection
net.ipv4.tcp_fin_timeout = 7

# Decrease the time default value for connections to keep alive
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_keepalive_probes = 5
net.ipv4.tcp_keepalive_intvl = 15

# Don't relay bootp
net.ipv4.conf.all.bootp_relay = 0

# Don't proxy arp for anyone
net.ipv4.conf.all.proxy_arp = 0

# Turn on the tcp_timestamps, accurate timestamp make TCP congestion control algorithms work better
net.ipv4.tcp_timestamps = 1

# Don't ignore directed pings
# 设置内核是否应答icmp echo包，值为0是允许回应
net.ipv4.icmp_echo_ignore_all = 0

# Enable ignoring broadcasts request
# 设置内核是否指定的广播，值为0是允许回应
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Enable bad error message Protection
net.ipv4.icmp_ignore_bogus_error_responses = 1

# Allowed local port range
# 当本地需要端口时指定TCP或UDP端口范围。第一数为低端口，第二个数为高端口；
net.ipv4.ip_local_port_range = 16384 65535

# Enable a fix for RFC1337 - time-wait assassination hazards in TCP
net.ipv4.tcp_rfc1337 = 1

# Do not auto-configure IPv6
net.ipv6.conf.all.autoconf=0
net.ipv6.conf.all.accept_ra=0
net.ipv6.conf.default.autoconf=0
net.ipv6.conf.default.accept_ra=0
net.ipv6.conf.eth0.autoconf=0
net.ipv6.conf.eth0.accept_ra=0



###
### TUNING NETWORK PERFORMANCE ###
###

# For high-bandwidth low-latency networks, use 'htcp' congestion control
# Do a 'modprobe tcp_htcp' first
net.ipv4.tcp_congestion_control = htcp

# For servers with tcp-heavy workloads, enable 'fq' queue management scheduler (kernel > 3.12)
net.core.default_qdisc = fq

# Turn on the tcp_window_scaling
net.ipv4.tcp_window_scaling = 1

# Increase the read-buffer space allocatable
net.ipv4.tcp_rmem = 8192 87380 16777216
net.ipv4.udp_rmem_min = 16384
# 接收套接字缓冲区大小的缺省值(以字节为单位)
# chookin net.core.rmem_default = 262144
net.core.rmem_default = 8388608
# 指定了接收套接字缓冲区大小的最大值(以字节为单位)
net.core.rmem_max = 16777216

# Increase the write-buffer-space allocatable
net.ipv4.tcp_wmem = 8192 65536 16777216
net.ipv4.udp_wmem_min = 16384
# 指定了发送套接字缓冲区大小的缺省值(以字节为单位)
net.core.wmem_default = 262144
# 指定了发送套接字缓冲区大小的最大值(以字节为单位)
net.core.wmem_max = 16777216

# Increase number of incoming connections
net.core.somaxconn = 32768

# Increase number of incoming connections backlog
# 在接口接收数据包的速率比内核处理这些包的速率快时，允许送到队列的数据包的最大数目
net.core.netdev_max_backlog = 16384
net.core.dev_weight = 64

# Increase the maximum amount of option memory buffers
# 该文件指定了每个套接字所允许的最大缓冲区的大小
net.core.optmem_max = 65535

# Increase the tcp-time-wait buckets pool size to prevent simple DOS attacks
# 最大TIME_WAIT缓冲池数量
# chookin net.ipv4.tcp_max_tw_buckets = 1440000
net.ipv4.tcp_max_tw_buckets = 10000

# try to reuse time-wait connections, but don't recycle them (recycle can break clients behind NAT)
net.ipv4.tcp_tw_recycle = 0
net.ipv4.tcp_tw_reuse = 1

# Limit number of orphans, each orphan can eat up to 16M (max wmem) of unswappable memory
# 系统所能处理不属于任何进程的TCP sockets最大数量（主动关闭端发送了FIN后转到FIN_WAIT_1，这时TCP连接就不属于某个进程了）
# net.ipv4.tcp_max_orphans = 262144
net.ipv4.tcp_max_orphans = 16384
net.ipv4.tcp_orphan_retries = 0

# Increase the maximum memory used to reassemble IP fragments
# When ipfrag_high_thresh bytes of memory is allocated for this purpose, the fragment handler will toss packets until ipfrag_low_thresh is reached.
# 用于IP分片汇聚的最大内存用量。分配了这么多字节的内存后，一旦用尽，分片处理程序就会丢弃分片
net.ipv4.ipfrag_high_thresh = 4194304
# 用于IP分片汇聚的最小内存用量
net.ipv4.ipfrag_low_thresh = 3145728

# don't cache ssthresh from previous connection
# 一个tcp连接关闭后,把这个连接曾经有的参数比如慢启动门限snd_sthresh,拥塞窗口snd_cwnd 还有srtt等信息保存到dst_entry中, 只要dst_entry 没有失效,下次新建立相同连接的时候就可以使用保存的参数来初始化这个连接.
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_moderate_rcvbuf = 1

# Increase size of RPC datagram queue length
net.unix.max_dgram_qlen = 50

# Don't allow the arp table to become bigger than this
# 保存在 ARP 高速缓存中的最多记录的硬限制，一旦高速缓存中的数目高于此，垃圾收集器将马上运行。缺省值是1024。
net.ipv4.neigh.default.gc_thresh3 = 2048

# Tell the gc when to become aggressive with arp table cleaning.
# Adjust this based on size of the LAN. 1024 is suitable for most /24 networks
# 保存在 ARP 高速缓存中的最多的记录软限制。垃圾收集器在开始收集前，允许记录数超过这个数字 5 秒。缺省值是 512。
net.ipv4.neigh.default.gc_thresh2 = 1024

# Adjust where the gc will leave arp table alone.
# 存在于ARP高速缓存中的最少层数，如果少于这个数，垃圾收集器将不会运行。缺省值是128
net.ipv4.neigh.default.gc_thresh1 = 128

# Adjust to arp table gc to clean-up more often
net.ipv4.neigh.default.gc_interval = 30

# Increase TCP queue length
net.ipv4.neigh.default.proxy_qlen = 96
net.ipv4.neigh.default.unres_qlen = 6

# Enable Explicit Congestion Notification (RFC 3168), disable it if it doesn't work for you
net.ipv4.tcp_ecn = 1
net.ipv4.tcp_reordering = 3

# How many times to retry killing an alive TCP connection
# 设置允许重送的TCP包的次数，缺省为15。
net.ipv4.tcp_retries2 = 15
# 设置回应连入重送的次数，缺省为3；
net.ipv4.tcp_retries1 = 3

# Avoid falling back to slow start after a connection goes idle
# keeps our cwnd large with the keep alive connections (kernel > 3.6)
net.ipv4.tcp_slow_start_after_idle = 0

# Allow the TCP fastopen flag to be used, beware some firewalls do not like TFO! (kernel > 3.7)
net.ipv4.tcp_fastopen = 3

# This will enusre that immediatly subsequent connections use the new values
net.ipv4.route.flush = 1
net.ipv6.route.flush = 1



###
### Comments/suggestions/additions are welcome!
###
# to fix "nf_conntrack: table full, dropping packet", 加大防火墙跟踪表的大小，优化对应的系统参数
net.netfilter.nf_conntrack_max = 1048576
net.netfilter.nf_conntrack_tcp_timeout_established = 3600
net.netfilter.nf_conntrack_tcp_timeout_close_wait = 60
net.netfilter.nf_conntrack_tcp_timeout_fin_wait = 120
net.netfilter.nf_conntrack_tcp_timeout_time_wait = 120
```



## 参考

- https://klaver.it/linux/sysctl.conf
- [Linux TCP/IP调优参数 /proc/sys/net/目录](http://www.cnblogs.com/yzpopulation/p/4919039.html)
- [Improving Network Performance](https://pubs.vmware.com/continuent/tungsten-replicator-3.0/performance-networking.html)
- [Performance Tuning - Networking](https://oxnz.github.io/2016/05/03/performance-tuning-networking/)
- [sysctl.conf](https://easyengine.io/tutorials/linux/sysctl-conf/)
- [SLES 11/12: Network, CPU Tuning and Optimization – Part 2](https://www.suse.com/communities/blog/sles-1112-network-cpu-tuning-optimization-part-2/)
- [解决系统丢包问题](http://blog.csdn.net/anghlq/article/details/17302151)
- [超全整理！Linux性能分析工具汇总合集](http://rdc.hundsun.com/portal/article/731.html)
- [零零散散整理的一些linux内核参数和说明](http://storysky.blog.51cto.com/628458/774164/)
- [Using netstat and dropwatch to observe packet loss on Linux servers](http://prefetch.net/blog/index.php/2011/07/11/using-netstat-and-dropwatch-to-observe-packet-loss-on-linux-servers/)
- [Performance_Tuning_Guide/index.html#main-network](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html-single/Performance_Tuning_Guide/index.html#main-network)
- [谁偷走了你的服务器性能——Strace & Ltrace篇](http://rdcqii.hundsun.com/portal/article/597.html)
- [nf_conntrack: table full, dropping packet. 终结篇](http://www.cnblogs.com/higkoo/articles/iptables_tunning_for_conntrack.html)
- [Hadoop运维记录系列(八)](http://slaytanic.blog.51cto.com/2057708/1251531/)

> nginx单台并发最高暴过80万，平时基本就是二三十万的并发，php并发最高到过8000/秒。别问我怎么做到的，我的确已经尽力了
- [Linux tuning](https://docs.pingidentity.com/bundle/pa_sm_PerformanceTuning_pa41/page/pa_c_LinuxTuning.html)

> This section describes tuning recommendations for the Linux operating system environment. Implement these recommendations to prevent deployment issues, particularly in high capacity environments. The following settings will increase the performance and capacity of the networking (particularly TCP) stack and file descriptor usage, respectively, enabling PingAccess to handle a high volume of concurrent requests.

