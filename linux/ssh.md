[TOC]

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
ssh lab09 'su - work -c "/home/work/local/mfs/sbin/mfschunkserver stop"'
```

# 无密码访问
<b>配置ssh使得服务器A的用户user_a1可以无密码访问服务器B的用户user_b1</b>

采用rsa方式。

```
https://www.gentoo.org/support/news-items/2015-08-13-openssh-weak-keys.html

Starting with the 7.0 release of OpenSSH, support for ssh-dss keys has
been disabled by default at runtime due to their inherit weakness.  If
you rely on these key types, you will have to take corrective action or
risk being locked out.

Your best option is to generate new keys using strong algos such as rsa
or ecdsa or ed25519.  RSA keys will give you the greatest portability
with other clients/servers while ed25519 will get you the best security
with OpenSSH (but requires recent versions of client & server).

If you are stuck with DSA keys, you can re-enable support locally by
updating your sshd_config and ~/.ssh/config files with lines like so:
    PubkeyAcceptedKeyTypes=+ssh-dss

Be aware though that eventually OpenSSH will drop support for DSA keys
entirely, so this is only a stop gap solution.
```

## 前提条件

确保配置文件/etc/ssh/sshd_config中的`RSAAuthentication`和`PubkeyAuthentication`的值必须是yes（默认值即使yes，除非配置文件中明确设定了这两个参数的值，否则不用修改）。

```shell
# 启用 RSA 认证
RSAAuthentication yes
# 启用公钥私钥配对认证方式
PubkeyAuthentication yes
# 公钥文件路径
AuthorizedKeysFile .ssh/authorized_keys
```

如果修改了配置文件，需重启ssh.

```shell
service sshd restart
```


## 具体操作
1）在A服务器的用户user_a1上执行如下命令，将在.ssh路径下自动生成id_dsa.pub文件

```shell
cd && ssh-keygen -b 4096 -t rsa -P '' -f ~/.ssh/id_rsa && chmod 700 ~/.ssh && chmod 600 ~/.ssh/id_rsa
```

2）配置B服务器
登录B服务器的用户user_b1。
如果路径~/.ssh/不存在，则执行命令

```shell
cd && ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && chmod 700 ~/.ssh
```

拷贝步骤1生成的`id_dsa.pub`文件内容并追加到服务器B的`.ssh/authorized_keys`文件中（如果`.ssh/authorized_keys`不存在，创建之），并执行如下命令

```shell
chmod 600 $HOME/.ssh/authorized_keys
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

# 简单操作

Simple method
Note: This method might fail if the remote server uses a non-sh shell such as tcsh as default and uses OpenSSH older than 6.6.1p1. See this bug report.

```sh
➜  ~ ssh -V
OpenSSH_7.5p1, OpenSSL 1.0.2l  25 May 2017
```

If your key file is ~/.ssh/id_rsa.pub you can simply enter the following command.

```shssh
$ ssh-copy-id remote-server.org
```

If your username differs on remote machine, be sure to prepend the username followed by @ to the server name.

```sh
$ ssh-copy-id username@remote-server.org
```

- [SSH keys](https://wiki.archlinux.org/index.php/SSH_keys)
## 常见问题

若无密码登录配置不成功，请检查：

1. ssh配置文件
2. .ssh相关文件权限
3. `/home/whomai`文件夹权限，建议该文件夹权限为755.

# ssh登录慢

使用ssh客户端（如：putty）连接Linux服务器，可能会等待10-30秒才有提示输入密码，严重影响工作效率。登录很慢，登录上去后速度正常，这种情况主要有两种可能的原因：

1) DNS反向解析问题

OpenSSH在用户登录的时候会验证ip，它根据用户的IP使用反向DNS找到主机名，再使用DNS找到IP地址，最后匹配一下登录的IP是否合法。如果客户机的IP没有域名，或者DNS服务器很慢或不通，那么登录就会很花时间。

例如：在如下消息处等待时间过长`debug1: SSH2_MSG_SERVICE_ACCEPT received`

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
Unknown code krb5 195

debug1: Unspecified GSS failure.  Minor code may provide more information
Unknown code krb5 195

debug1: Unspecified GSS failure.  Minor code may provide more information
Unknown code krb5 195

debug1: Next authentication method: publickey
```

注：`ssh -vvv user@server`可以看到更细的debug信息

解决办法：

修改sshd服务器端配置

```shell
vi /etc/ssh/ssh_config


# GSSAPI options
GSSAPIAuthentication no
#GSSAPIAuthentication yes
GSSAPICleanupCredentials no
#GSSAPICleanupCredentials yes
```

可以使用ssh -o GSSAPIAuthentication=no user@server登录

GSSAPI ( Generic Security Services Application Programming Interface) 是一套类似Kerberos 5的通用网络安全系统接口，该接口是对各种不同的客户端服务器安全机制的封装，以消除安全接口的不同，降低编程难度，但该接口在目标机器无域名解析时会有问题,使用strace查看后发现，ssh在验证完key之后，进行authentication gssapi-with-mic，此时先去连接DNS服务器，在这之后会进行其他操作。

参考

- [ssh登录很慢解决方法](https://blog.linuxeye.com/420.html)
- [ssh 配置讲解大全](http://blog.chinaunix.net/uid-20395453-id-3264845.html)

# 禁止root登录

2016.07.21下午发现183服务器的`/var/log/secure`文件中有大量的登录错误信息。

```
Jul 17 04:25:21 DATIBA-001 unix_chkpwd[139897]: password check failed for user (root)
Jul 17 04:25:23 DATIBA-001 sshd[139894]: Failed password for root from 222.186.130.243 port 3557 ssh2
Jul 17 04:25:23 DATIBA-001 unix_chkpwd[139898]: password check failed for user (root)
Jul 17 04:25:25 DATIBA-001 sshd[139894]: Failed password for root from 222.186.130.243 port 3557 ssh2
Jul 17 04:25:25 DATIBA-001 unix_chkpwd[139899]: password check failed for user (root)
Jul 17 04:25:27 DATIBA-001 sshd[139894]: Failed password for root from 222.186.130.243 port 3557 ssh2
```

服务器被暴力ssh尝试了，解决办法：

1，修改ssh端口，禁止root登录，然后重新启动ssh服务

```shell
vi /etc/ssh/sshd_config
Port 4484 #一个别人猜不到的端口号
PermitRootLogin no
```

2，限制登录ip，即ssh登录必须通过指定服务器跳转登录。这需要配置防火墙，示例：

```shell
-A INPUT -s 218.206.179.52 -p tcp -m tcp --dport 22 -j ACCEPT
-A INPUT -s 218.206.179.52 -p tcp -m tcp --dport 21022 -j ACCEPT
```

3，安装denyhosts

# 启用pam后，不需密码就能登录
问题原因是`ChallengeResponseAuthentication`的值设置为了yes，设置为no后，就可以了。
