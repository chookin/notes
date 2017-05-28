# 基本环境准备
```shell
yum install gcc gcc-c++ cmake zlib-devel openssl-devel
```

# 查看服务器信息

```shell
[root@localhost ~]# dmidecode |grep -A4 'System Information'
System Information
        Manufacturer: HP
        Product Name: ProLiant DL585 G5
        Version: Not Specified
        Serial Number:
```


## wget

```shell
# 递归下载
wget --level=inf  --adjust-extension --span-hosts --domains=qcloud.com -r -p -np -k -nc --no-check-certificate -e robots=off -e http_proxy=http://proxy.cmcc:8080 -e https_proxy=http://proxy.cmcc:8080 -o down.log -U "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_2) AppleWebKit/602.3.12 (KHTML, like Gecko) Version/10.0.2 Safari/602.3.12" https://www.qcloud.com/document/product/269/2560

wget --mirror --convert-links --adjust-extension --page-requisites --no-parent https://www.qcloud.com/document/product/269
```

```
-r,  --recursive 下载指定网页某一目录下（包括子目录）的所有文件
-k,  --convert-links 将绝对链接转为相对链接，下载整个站点后脱机浏览网页，最好加上这个参数files.（将下载的HTML页面中的链接转换为相对链接即本地链接）
-L 递归时不进入其它主机，如wget -c -r www.xxx.org/ 如果网站内有一个这样的链接： www.yyy.org，不加参数-L，就会像大火烧山一样，会递归下载www.yyy.org网站
-o, –output-file=FILE 把记录写到FILE文件中
-a, –append-output=FILE 把记录追加到FILE文件中
-d, –debug 打印调试输出
-q, –quiet 安静模式(没有输出)
-v, –verbose 冗长模式(这是缺省设置)
-nv, –non-verbose 关掉冗长模式，但不是安静模式
-i, –input-file=FILE 下载在FILE文件中出现的URLs
-F, –force-html 把输入文件当作HTML格式文件对待
-B, –base=URL 将URL作为在-F -i参数指定的文件中出现的相对链接的前缀
–sslcertfile=FILE 可选客户端证书
–sslcertkey=KEYFILE 可选客户端证书的KEYFILE
–egd-file=FILE 指定EGD socket的文件名
-p, --page-requisites（页面必需元素）get all images, etc. needed to display HTML page.（下载所有的图片等页面显示所需的内容）
-c, –continue 接着下载没下载完的文件
-nc, –no-clobber 不要覆盖存在的文件或
-nd, -–no-directories 不递归下载时不创建一层一层的目录，把所有的文件下载到当前目录
-np, --no-parent（不追溯至父级）don't ascend to the parent directory.
-e robots=off  让wget耍流氓无视robots.txt协议
-e use_proxy=yes 设置使用代理
-e http_proxy=http://proxy.cmcc:8080 设置http代理
-e https_proxy=http://proxy.cmcc:8080 设置https代理
--no-check-certificate可以不检查服务器的证书
--html-extention 只下载html相关的文件
--domains qcloud.com 不要下载该qcloud.com以外的链接地址
--adjust-extension 为下载的文件追加后缀'.html'
```

参考

- [wget 下载整个网站，或者特定目录](http://www.cnblogs.com/lidp/archive/2010/03/02/1696447.html)
- [wget命令](http://man.linuxde.net/wget)


# alias

> I'd like to define an alias that runs the following two commands consecutively.
>
> gnome-screensaver
> gnome-screensaver-command --lock

Try:

```shell
alias lock='gnome-screensaver; gnome-screensaver-command --lock'
```

or

```shell
lock() {
    gnome-screensaver
    gnome-screensaver-command --lock
}
```


in your .bashrc

The second solution allows you to use arguments.

[Multiple commands in an alias for bash](http://stackoverflow.com/questions/756756/multiple-commands-in-an-alias-for-bash)


# 切换用户
切换用户执行命令
```shell
su --session-command="/home/mfs/local/mfs/sbin/mfschunkserver start &" work
su - root -c 'ls /var/root'
```

# 开机自启动
把操作命令写到`/etc/rc.local`文件。
该脚本是在系统初始化级别脚本运行之后再执行的，因此可以安全地在里面添加你想在系统启动之后执行的脚本。



# 安全
查看历史登录`last -n 10`
查看系统日志 `cat /var/log/messages`

# 系统配置
## 配置最多打开的文件数

编辑文件`/etc/security/limits.conf`，在尾部添加:
```
chookin - nofile 655360
```
就配置了用户chookin最多打开的文件数。到用户chookin环境下执行`ulimit -n`校验该配置是否生效。

若操作出现错误：`-bash: fork: Resource temporarily unavailable`
则编辑文件`/etc/security/limits.conf`，在尾部添加:

```
chookin           -       noproc          65536
```

## 修改用户名

```shell
# 修改用户名称
usermod -l login-name old-name
# change HOME folder
usermod -d /home/newjames -m newjames
```

# mail
清空mail消息

```shell
echo '' > /var/spool/mail/`whoami`
```



# 其他

```
linux常用命令
系统信息
#uname -a
#查看内核/操作系统/CPU信息
#head -n 1 /etc/issue
#查看操作系统版本
#cat /proc/interrupts
#显示中断
#hostname
#显示计算机名
#lsmod
#显示加载的内核模块
#env
#显示环境变量
系统资源信息
#free -m
#查看内存使用量和交换区使用量
#df -h
#查看各分区使用情况
#du -sh <目录名>
#查看指定目录的大小
#uptime
#查看系统运行时间、用户数、负载
#cat /proc/loadavg
#查看系统负载
硬盘和分区
#mount|column -t
#查看挂载的分区状态
#fdisk -l
#查看所有分区
#swapon -s
#查看所有交换分区
#dmesg
#查看启动时设备检测情况
网络相关
#ifconfig
#查看所有网络接口的属性
#iptables -L
#查看防火墙规则
#route -n
#查看路由表
#netstat -lntp
#查看所有监听端口
#netstat -antp
#查看所有已经建立的连接
进程相关
#ps -ef
#查看所有进程
#top
#实时进程状态
#kill 1024
#正常结束1024进程
用户相关
#w
#查看活动用户
#id <用户名>
#查看指定用户信息
#last
#查看用户登录日志
#crontab -l
#查看当前用户的计划任务
服务相关
#chkconfig --list
#列出所有系统服务
#chkconfig sshd on
#将sshd服务列为开机启动
目录相关
#mkdir dirname
#创建一个目录
#touch filename
#创建一个文件
#rm filename
#删除一个文件
#mv filename /root/filename
#移动或者重命名文件
#cp filename1 filename2
#复制文件
```
