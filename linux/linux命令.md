# 基本环境准备
yum install gcc gcc-c++ cmake zlib-devel openssl-devel

# 图形界面切换到命令行
从Linux的图形界面切换到命令界面可以按Ctrl+Alt+Fn（n=1,2,3,4,5,6）
从Linux的命令介面切换到图形界面可以按Alt+F1(或者F1--F7,根据个人电脑设置不同.可能不一样)(也可以输入命令startx进入图形界面)。

# 查看系统信息

## 查看物理CPU个数、核数、逻辑CPU个数
```shell
# 总核数 = 物理CPU个数 X 每颗物理CPU的核数 
# 总逻辑CPU数 = 物理CPU个数 X 每颗物理CPU的核数 X 超线程数

# 查看物理CPU个数
cat /proc/cpuinfo| grep "physical id"| sort| uniq| wc -l

# 查看每个物理CPU中core的个数(即核数)
cat /proc/cpuinfo| grep "cpu cores"| uniq

# 查看逻辑CPU的个数
cat /proc/cpuinfo| grep "processor"| wc -l

# 查看CPU信息（型号）
cat /proc/cpuinfo | grep name | cut -f2 -d: | uniq -c
```

## 查看内存信息
```shell
cat /proc/meminfo
```

# 文件操作

## 权限

```shell
find /var/backup/db* -type f -exec chmod 400 {} \;
find /var/backup/db* -type d -exec chmod 700 {} \;
```

## ls 排序

```shell
ls -lS                 按大小降序排列
ls -l | sort -n -k5    按大小升序
ls -lrt                按时间降序
ls -lnt                按时间升序
ls -l | sort -k9       按文件名升序（这是ls的默认输出方式）
ls -lr                 按文件名降序
ls -l | sort -rk9      按文件名降序
ls -l -d */            只显示目录
ls -l |grep -v "^d"    只显示文件
```

## 文件查找
查找指定类型的文件，并进而查找包含指定字符的
```shell
find . -type f -name *.java | xargs grep -r common.Logger
find . -type f -name "*.sh" | xargs grep -r "merged.data"
```

## 文件删除
- 删除除指定文件外的其它文件
  `ls | grep -v jpg | xargs rm -rf`

说明：ls列出当前目录下的所有文件（不包括以 . 开头的隐含文件），然后是管道（|）传给过滤器，然后通过过滤器grep -v（-v表示反检索，只显示不匹配的行，类似windows下的反选，注意是小写的v），然后再是管道（|）传给xargs（xargs是给命令传递参数的一个过滤器），到这儿也就说，xargs会把前面管道传来输入作为后面rm -rf命令执行的参数。

- 删除svn文件
  `find . -name ".svn" -type d | xargs rm -rf`

执行命令`$ rm -rf *`时报错，`-bash: /bin/rm: Argument list too long`。解决办法：`find . -name "*" | xargs rm -rf '*'`

## 文件树
查看文件树使用命令`tree`.若系统中没有该命令，需要安装之 `yum install -y tree`

## 常见问题

提示 readonly file system
解决办法：
/bin/mount -o remount,rw /

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

# grep常用用法

```shell
$ grep [-acinv] [--color=auto] '搜寻字符串' filename
选项与参数：
-a ：将 binary 文件以 text 文件的方式搜寻数据
-c ：计算找到 '搜寻字符串' 的次数
-i ：忽略大小写的不同，所以大小写视为相同
-n ：顺便输出行号
-v ：反向选择，亦即显示出没有 '搜寻字符串' 内容的那一行！
--color=auto ：可以将找到的关键词部分加上颜色的显示喔！
```

# sed
grep和sed配合替换文件中的字串

命令：
```shell
sed -i s/yyyy/xxxx/g `grep yyyy -rl --include="*.txt" ./`
```
作用：将当前目录(包括子目录)中所有txt文件中的yyyy字符串替换为xxxx字符串

参数解释: 
sed:

```
-i 表示操作的是文件，``括起来的grep命令，表示将grep命令的的结果作为操作文件
s/yyyy/xxxx/表示查找yyyy并替换为xxxx，后面跟g表示一行中有多个yyyy的时候，都替换，而不是仅替换第一个
```

grep:

```
-r表示查找所有子目录
-l表示仅列出符合条件的文件名，用来传给sed命令做操作
--include="*.txt" 表示仅查找txt文件
./ 表示要查找的根目录为当前目录
```

示例：

```shell
sed -i "s/home\/work/home\/${username}/g" `grep home/work -rl ${SRC_PATH}`

sed -i 's#".#"com.xjkj.psyassess.#g' `grep "\"\." -rl --include="*.xml" src`

sed -i s#".#"com.xjkj.psyassess.#g `find src -name *.xml | xargs grep "\"\." -rl`
```

# 压缩

- 创建压缩包
```
tar czvf  xxx.tar.gz  要打包的目录  --exclude=dir1   --exclude=file1  ......
```

# 切换用户
切换用户执行命令
```shell
su --session-command="/home/mfs/local/mfs/sbin/mfschunkserver start &" work
su - root -c 'ls /var/root'
```

# 开机自启动
/etc/rc.local
该脚本是在系统初始化级别脚本运行之后再执行的，因此可以安全地在里面添加你想在系统启动之后执行的脚本。

# 进程
## 结束进程

```shell
jps | grep appname | awk '{print $1}' | xargs kill -9
ps axu |grep gradle |grep -v grep |  awk '{print $2}' | xargs kill -9
pgrep appname | xargs kill -9
```

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

# mail
清空mail消息

```shell
echo '' > /var/spool/mail/`whoami` 
```

# 网络

多次连接测指定url的可访问性

```shell
httping -c10000 -g  http://111.13.47.169:8001/sv/24/316/1241/6?v=1 
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
