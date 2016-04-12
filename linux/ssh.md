# 远程执行命令
```shell
ssh -t -p $port $user@$ip 'cmd'
```

* $port : ssh连接端口号
* $user: ssh连接用户名
* $ip:ssh连接的ip地址
* cmd:远程服务器需要执行的操作
* t: 提供一个远程服务器的虚拟tty终端，加上这个参数我们就可以在远程服务器的虚拟终端上输入自己的提权密码了，非常安全 .

```shell
ssh -t -p 21022 lab08 'hostname > /home/mtag/share/`hostname`.txt'
```

# 无密码访问
<b>配置ssh使得服务器A的用户user_a1可以无密码访问服务器B的用户user_b1</b>

操作：
1）在A服务器的用户user_a1上执行如下命令，将在.ssh路径下自动生成id_dsa.pub文件
```shell
cd && ssh-keygen -t dsa -P '' -f ~/.ssh/id_dsa && chmod 700 ~/.ssh
```

2）配置B服务器
登录B服务器的用户user_b1。
如果路径~/.ssh/不存在，则执行命令
```shell
cd && ssh-keygen -t dsa -P '' -f ~/.ssh/id_dsa && chmod 700 ~/.ssh
```

拷贝步骤1生成的`id_dsa.pub`文件内容并追加到服务器B的`.ssh/authorized_keys`文件中（如果`.ssh/authorized_keys`不存在，创建之），并执行如下命令
```shell
chmod 600 $HOME/.ssh/authorized_keys;
```

如果步骤1生成的id_dsa.pub文件内容是以hostname结尾，那么还需要把服务器A的ip与hostname配置到服务器B的/etc/hosts文件中。

3）配置B服务器防火墙
开放A的ssh访问。
```shell
iptables -I INPUT -p tcp -s hostname_A --dport 22 -j ACCEPT
```

注意，避免使用iptables -A，因为“iptables -A”会使得新添加的规则加入到防火墙链的尾部，可能会存在不可用的情况。
```shell
# iptables -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination
ACCEPT     tcp  --  anywhere             anywhere            tcp dpt:biimenu 
ACCEPT     tcp  --  218.206.179.52       anywhere            tcp dpt:ssh
ACCEPT     udp  --  anywhere             anywhere            udp dpt:ntp
DROP       tcp  --  anywhere             anywhere            tcp dpt:ssh
ACCEPT     tcp  --  upload@udbac.com     anywhere            tcp dpt:ssh
```

4）测试A对B的访问
在A上执行
```shell
ssh user_b1@hostname_B -v
```

如果可以成功访问，OK

# ssh登录慢
使用ssh客户端（如：putty）连接Linux服务器，可能会等待10-30秒才有提示输入密码，严重影响工作效率。登录很慢，登录上去后速度正常，这种情况主要有两种可能的原因：

1) DNS反向解析问题

OpenSSH在用户登录的时候会验证ip，它根据用户的IP使用反向DNS找到主机名，再使用DNS找到IP地址，最后匹配一下登录的IP是否合法。如果客户机的IP没有域名，或者DNS服务器很慢或不通，那么登录就会很花时间。

解决办法：

在目标服务器上修改sshd服务器端配置,并重启sshd
```shell
vi /etc/ssh/sshd_config
UseDNS no
```

2) 关闭ssh的gssapi认证

用`ssh -v user@server`可以看到登录时有如下信息：
```
debug1: Next authentication method: gssapi-with-mic
debug1: Unspecified GSS failure. Minor code may provide more information
```

注：`ssh -vvv user@server`可以看到更细的debug信息

解决办法：

修改sshd服务器端配置
```shell
vi /etc/ssh/ssh_config
GSSAPIAuthentication no
```

可以使用ssh -o GSSAPIAuthentication=no user@server登录

GSSAPI ( Generic Security Services Application Programming Interface) 是一套类似Kerberos 5的通用网络安全系统接口，该接口是对各种不同的客户端服务器安全机制的封装，以消除安全接口的不同，降低编程难度，但该接口在目标机器无域名解析时会有问题,使用strace查看后发现，ssh在验证完key之后，进行authentication gssapi-with-mic，此时先去连接DNS服务器，在这之后会进行其他操作。

参考

- [ssh登录很慢解决方法](https://blog.linuxeye.com/420.html)
