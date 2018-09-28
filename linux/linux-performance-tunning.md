## 服务器内核优化

编辑文件`/etc/sysctl.conf`

```shell
# tcp_syncookies是一个开关，是否打开SYN Cookie功能，该功能可以防止部分SYN攻击
net.ipv4.tcp_syncookies = 1
# 设置保持在FIN_WAIT_2状态的时间。tcp4此挥手，正常的处理流程就是在FIN_WAIT_2情况下接收到FIN进入到TIME_WAIT的情况，tcp_fin_timeout参数对处于TIME_WAIT状态的时间没有任何影响。但是如果这个参数设的比较小，会缩短从FIN_WAIT_2到TIME_WAIT的时间，从而使连接更早地进入TIME_WAIT状态。状态开始的早，等待相同的时间，结束的也早，客观上也加速了TIME_WAIT状态套接字的清理速度。
net.ipv4.tcp_fin_timeout = 30
# 表示开启重用，允许将TIME-WAIT sockets重新用于新的TCP连接
net.ipv4.tcp_tw_reuse = 1
# 使用负载均衡时，不能开启tcp_tw_recycle
net.ipv4.tcp_tw_recycle = 0
# tcp支持的队列数，tcp 连接超过这个队列长度，就不允许连接了
net.ipv4.tcp_max_syn_backlog = 65535
# 每个网络接口接收数据包的速率比内核处理这些包的速率快时，允许送到队列的数据包的最大数目
net.core.netdev_max_backlog = 322768
# 设置最大TIME_WAIT缓冲池数量
net.ipv4.tcp_max_tw_buckets = 10000
```

- [服务器tcp连接timewait过多优化及详细分析](http://www.2cto.com/net/201503/381132.html)
