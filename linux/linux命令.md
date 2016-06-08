# 基本环境准备
yum install gcc gcc-c++ cmake zlib-devel openssl-devel

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
ps aux | grep appname | awk '{print $2}' | xargs kill -9
pgrep appname | xargs kill -9
```

# 安全
查看历史登录`last -nx 10`
查看系统日志 `cat /var/log/messages`
# 系统配置
## 配置最多打开的文件数

编辑文件`/etc/security/limits.conf`，在尾部添加:
```
chookin - nofile 655360
```
就配置了用户chookin最多打开的文件数。到用户chookin环境下执行`ulimit -n`校验该配置是否生效。

# mail
清空mail消息

```shell
echo '' > /var/spool/mail/`whoami` 
```
