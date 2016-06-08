[TOC]
# lftp

lftp 用户名:密码@ftp地址:端口
基本命令：
```shell
ls .
put file
rm file
```

# ftp连接非默认端口的
```
ftp
ftp> open 127.0.0.1 2000
Connected to 127.0.0.1.
220 Microsoft FTP Service
User (127.0.0.1:(none)): xxx
331 Password required for xxx.
Password:
230 User xxx logged in.

# change user
ftp> user
```

# 搭建ftp服务器
采用vsftp创建虚拟账户来解决多用户共享目录的问题。

## 安装
检查vsftpd是否安装 `ps -ef |grep vsftpd`
若未安装，安装之
```shell
yum install vsftpd ftp lftp -y
```

## 添加账户

```shell
#添加一个不能登录系统的用户，用来做虚拟用户映射
useradd -s /sbin/nologin -d /var/ftp/admn admn
passwd admn

# 生成虚拟用户口令库文件。为了建立此口令库文件，先要生成一个文本文件。该文件的格式如下，单数行为用户名，偶数行为口令
touch /etc/vsftpd/vu_list.txt
echo -e 'virtual_user\her_password'>> /etc/vsftpd/vu_list.txt

#保存虚拟帐号和密码的文本文件无法被系统帐号直接调用，需要创建用于系统认证的db文件
db_load -T -t hash -f /etc/vsftpd/vu_list.txt /etc/vsftpd/vu_list.db
#创建db文件需要db4支持，如果系统没安装请安装
yum -y install db4 db4-devel db4-utils

# 以后再要添加虚拟用户的时候，只需要按照“一行用户名，一行口令”的格式将新用户名和口令添加进虚拟用户名单文件。
# 但是光这样做还不够，不会生效的哦！还要再执行一遍“ db_load -T -t hash -f 虚拟用户名单文件 虚拟用户数据库文件.db ”的命令使其生效才可以！

#修改db文件的权限，以免被非法用户修改
chmod 600 /etc/vsftpd/vu_list.db
```

## 配置PAM文件
由于服务器通过调用系统PAM模块来对客户端进行身份验证，因此需要修改指定的配置文件来调整认证方式。PAM模块的配置文件路径为：`/etc/pam.d/`。
编辑文件`/etc/pam.d/vsftpd`，添加以下内容到文件开头处。

- 32位系统添加：
```
auth       sufficient     /lib/security/pam_userdb.so     db=/etc/vsftpd/vu_list
account    sufficient     /lib/security/pam_userdb.so     db=/etc/vsftpd/vu_list
```

- 64位系统添加：
```
auth       sufficient     /lib64/security/pam_userdb.so   db=/etc/vsftpd/vu_list
account    sufficient     /lib64/security/pam_userdb.so   db=/etc/vsftpd/vu_list
```

这里的auth是指对用户的用户名口令进行验证。
这里的accout是指对用户的帐户有哪些权限哪些限制进行验证。
其后的sufficient表示充分条件，也就是说，一旦在这里通过了验证，那么也就不用经过下面剩下的验证步骤了。相反，如果没有通过的话，也不会被系统立即挡之门外，因为sufficient的失败不决定整个验证的失败，意味着用户还必须将经历剩下来的验证审核。
再后面的/lib/security/pam_userdb.so表示该条审核将调用pam_userdb.so这个库函数进行。
最后的db=/etc/vsftpd/virtusers则指定了验证库函数将到这个指定的数据库中调用数据进行验证。

查看os版本的命令`uname -a`

添加后的示例：
```shell
$ cat /etc/pam.d/vsftpd
#%PAM-1.0
auth       sufficient   /lib64/security/pam_userdb.so   db=/etc/vsftpd/vu_list
account    sufficient   /lib64/security/pam_userdb.so   db=/etc/vsftpd/vu_list
session    optional     pam_keyinit.so    force revoke
auth       required     pam_listfile.so item=user sense=deny file=/etc/vsftpd/ftpusers onerr=succeed
auth       required     pam_shells.so
auth       include      password-auth
account    include      password-auth
session    required     pam_loginuid.so
session    include      password-auth
```

## 创建虚拟用户配置文件
```shell
#创建虚拟用户liangyudong的配置文件
mydir=/etc/vsftpd/conf
mkdir $mydir
cd $mydir
# 权限说明：可以上传、下载、新建文件夹、删除和更改文件和文件夹名
cat >>liangyudong<< EOF
write_enable=YES
EOF
```

## 配置vsftpd.conf
vsftpd 默认端口是TCP / UDP – 21 and 20

```shell
# 禁用匿名访问
anonymous_enable=NO
# 允许本地用于使用其口令登录ftp,登录后，可以在其路径下读写操作；也可切换到有权限访问的其他目录，并在权限允许的情况下进行上传/下载
local_enable=YES
# 设定可以进行写操作。
write_enable=YES
# 本地用户新增档案时的umask值;umask设置权限的补码（或掩码），umask为022时，对应的权限值为077。
local_umask=022
# 设定开启目录标语功能。
dirmessage_enable=YES
# 设定开启日志记录功能。
xferlog_enable=YES
# 日志文件保存路径
xferlog_file=/var/log/vsftpd.log
# 设定日志使用标准的记录格式
xferlog_std_format=YES
# 设定UDP端口20进行数据连接。
connect_from_port_20=YES

# 禁止用户登陆FTP后使用"ls -R"的命令。该命令会对服务器性能造成巨大开销。如果该项被允许，那么挡多用户同时使用该命令时将会对该服务器造成威胁。
ls_recurse_enable=NO

# 设定支撑Vsftpd服务的宿主用户为手动建立的Vsftpd用户
nopriv_user=admn

# 用户只能访问自己的home directories.
chroot_local_user=YES

# 若设为YES，则必须配置chroot_list_file
chroot_list_enable=NO
# 配置例外用户
# chroot_list_file=/etc/vsftpd/chroot_list

# 设定user_list文件中的用户将不得使用FTP
userlist_enable=YES
# 设定支持TCP Wrappers
tcp_wrappers=YES

# 指定这个虚拟用户的FTP主路径
local_root=/home/admn
#表示启用虚拟用户
guest_enable=YES
#将虚拟用户映射为本地用户
guest_username=admn
#指定PAM的配置文件为/etc/pam.d/下的vsftp
pam_service_name=vsftp
# 设定虚拟用户个人Vsftp的配置文件存放路径。也就是说，这个被指定的目录里，将存放每个Vsftp虚拟用户个性的配置文件，一个需要注意的地方就是这些配置文件名必须和虚拟用户名相同
user_config_dir=/etc/vsftpd/vconf
```

对于chroot_local_user与chroot_list_enable的组合效果，可以参考下表：

chroot_list_enable=YES chroot_local_user=YES
1. 所有用户都被限制在其主目录下
2. 使用chroot_list_file指定的用户列表，这些用户作为“例外”，不受限制

chroot_list_enable=YES chroot_local_user=NO
1. 所有用户都不被限制其主目录下
2. 使用chroot_list_file指定的用户列表，这些用户作为“例外”，受到限制

chroot_list_enable=NO chroot_local_user=YES
1. 所有用户都被限制在其主目录下
2. 不使用chroot_list_file指定的用户列表，没有任何“例外”用户

chroot_list_enable=NO chroot_local_user=NO
1. 所有用户都不被限制其主目录下
2. 不使用chroot_list_file指定的用户列表，没有任何“例外”用户

##其他 配置

配置开机自启动
```
chkconfig --level 35 vsftpd on
```

配置防火墙

- 编辑`/etc/sysconfig/iptables`,在最终的LOG和DROP行之前添加如下规则：
```
-A INPUT -p tcp -m tcp --dport 21 -j ACCEPT
```

- 编辑`/etc/sysconfig/iptables-config`，确保FTP connection tracking module存在.若没配置，那么当使用虚拟ftp用户登录时，将无法连接。
```
IPTABLES_MODULES="ip_conntrack_ftp"
```

- 保存更改，重启防火墙
```
service iptables restart
```

## 调试
编辑配置文件`/etc/vsftpd/vsfpd.conf`，配置记录所有ftp事件

- xferlog_std_format=NO Turn off standard ftpd xferlog log format
- log_ftp_protocol=YES Turn on verbose vsftpd log format.

## 启动

service vsftpd start

## 测试
```shell
lftp liangyudong:C16mri_Ftp_lyd_MkJ@lab170:21
lftp liangyudong@1ab170:~> ls .
```

## 常见问题

- 530 Login incorrect.
查看`/var/log/secure`日志：
```
Jun  8 22:34:27 localhost vsftpd[140750]: pam_unix(vsftpd:auth): check pass; user unknown
Jun  8 22:34:27 localhost vsftpd[140750]: pam_unix(vsftpd:auth): authentication failure; logname= uid=0 euid=0 tty=ftp ruser=liangyudong rhost=223.69.29.173
Jun  8 22:34:27 localhost vsftpd[140750]: pam_succeed_if(vsftpd:auth): error retrieving information about user liangyudong
```

解决办法：核对`/etc/pam.d/vsftpd`的配置。

- Login failed: 500 OOPS: cannot change directory
禁用selinux
setenforce 0 可以临时关闭
再编辑文件`/etc/sysconfig/selinux`
把里边的一行改为`SELINUX=disabled`

# 参考
- [Red Hat / CentOS VSFTPD FTP Server Configuration](http://www.cyberciti.biz/tips/rhel-fedora-centos-vsftpd-installation.html)
- [让Vsftp支持虚拟用户 ](http://blog.chinaunix.net/uid-317994-id-2133014.html)
- [vsftp 多用户不同访问权限配置](http://centilinux.blog.51cto.com/1454781/1241768)
- [vsftpd 配置:chroot_local_user与chroot_list_enable详解](http://blog.csdn.net/bluishglc/article/details/42398811)
