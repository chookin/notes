
## 防火墙

```shell
[root@lab50 ~]# vi /etc/sysconfig/iptables
# Firewall configuration written by system-config-firewall
# Manual customization of this file is not recommended.
*filter
# the default rule for input is ACCEPT
:INPUT ACCEPT [0:0]
# the default rule for forward is ACCEPT
:FORWARD ACCEPT [0:0]
# the default rule for output is ACCEPT
:OUTPUT ACCEPT [0:0]
# accept input of established connections
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
# open to sub network
-A INPUT -s 192.168.110.0/24 -p tcp -j ACCEPT
-A INPUT -s 172.31.167.0/24 -p tcp -j ACCEPT
-A INPUT -s 117.136.183.0/24 -p tcp -j ACCEPT
#-A INPUT -s 172.17.128.0/24 -p tcp -j ACCEPT
#-A INPUT -s 172.17.128.0/24 -p udp -j ACCEPT
-A INPUT -m iprange --src-range 172.17.128.11-172.17.128.26 -j ACCEPT

# accept loop access
-A INPUT -s 127.0.0.1 -d 127.0.0.1 -j ACCEPT
# open port 22
-A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
# -A INPUT -p icmp -j ACCEPT
# reject other packets, and send a message of 'host prohibited' to the rejected host.
-A INPUT -j REJECT --reject-with icmp-host-prohibited

# if reject forward, lvs nat cannot work
# -A FORWARD -j REJECT --reject-with icmp-host-prohibited
-A OUTPUT -j ACCEPT
COMMIT
```

- [iptables 详细的使用指南](http://www.linuxde.net/2013/06/14620.html)
