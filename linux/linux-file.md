
# 文件操作

## 文件内容添加行号

```shell
cat -n filename > newfile
```

## 权限

```shell
# 查找具有可执行权限的文件
find . -perm /u=x,g=x,o=x -type f

# 查找最新修改的文件
find . -type f -print0 | xargs -0 stat --format '%Y :%y %n' | sort -nr | cut -d: -f2- > files.log

# 移动文件，当文件中包含空格时
mdfind -name 管理平台bug -0 | xargs -0 -I '{}' mv {} .

# 批量修改文件权限
find /var/backup/db* -type f -exec chmod 400 {} \;
# 批量修改文件夹权限
find /var/backup/db* -type d -exec chmod 700 {} \;
```

目录属性为drwxrwxrwt drwxrwxrwt = 1777 任何人都可以在此目录拥有写权限，但是不能删除别人拥有的文件

```
d指的是目录
t是sticky bit.
t是设置了粘住位
chmod  +t  SOME_FILE
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
find . -type f -name "*.sh" -print0 | xargs -0 grep -r "merged.data"
```

## 文件删除
- 删除除指定文件外的其它文件
  `ls | grep -v jpg | xargs rm -rf`

说明：ls列出当前目录下的所有文件（不包括以 . 开头的隐含文件），然后是管道（|）传给过滤器，然后通过过滤器grep -v（-v表示反检索，只显示不匹配的行，类似windows下的反选，注意是小写的v），然后再是管道（|）传给xargs（xargs是给命令传递参数的一个过滤器），到这儿也就说，xargs会把前面管道传来输入作为后面rm -rf命令执行的参数。

- 删除svn文件
  `find . -name ".svn" -type d | xargs rm -rf`

执行命令`$ rm -rf *`时报错，`-bash: /bin/rm: Argument list too long`。解决办法：`find . -name "*" | xargs rm -rf '*'`


当文件名中存在特殊字符，导致不好删除时，可以使用inode信息进行删除

```shell
ll -i .
find . -inum [inode_num] | xargs -I '{}' mv {} ~/tmp
```

## 文件树
查看文件树使用命令`tree`.若系统中没有该命令，需要安装之 `yum install -y tree`

## 转变文件编码

使用iconv命令，例如把文件从utf8转为GB18030格式：

```shell
iconv  -f UTF-8 -t GB18030 apps_2016-06-04.csv  > apps.csv
```

iconv有如下选项可用:
```
    -f, --from-code=名称 原始文本编码
    -t, --to-code=名称 输出编码
    -l, --list 列举所有已知的字符集
    -c 从输出中忽略无效的字符
    -o, --output=FILE 输出文件
    -s, --silent 关闭警告
    --verbose 打印进度信息
```

## 挂载iso

```shell
mount -o loop filename.iso /cdrom
```

## gz文件解压缩

```shell
gzip -d back.sql.gz
```

不解压缩的情况查看

```shell
zcat back.sql.gz
```

# grep

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

参数解释: s
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
sed -i "s/^Server=.*/Server=172.31.167.159/g" /usr/local/webserver/zabbix/etc/zabbix_agentd.conf

sed -i "s/home\/work/home\/${username}/g" `grep home/work -rl ${SRC_PATH}`

sed -i 's#".#"com.xjkj.psyassess.#g' `grep "\"\." -rl --include="*.xml" src`

# 使用分隔符‘#’替换'/'
sed -i 's#".#"com.xjkj.psyassess.#g' `find src -name *.xml | xargs grep "\"\." -rl`

sed -i "s/user\/hadoop/user\/chama/g" `grep user/hadoop -rl .`

sed -i "s/wom-collector-1.0.jar/${wom_jar}/g" `find src -name *.sh | xargs grep "wom-collector-1.0.jar" -rl`
```

# 压缩

## tar

-c: 建立压缩档案
-x：解压
-t：查看内容
-r：向压缩归档文件末尾追加文件
-u：更新原压缩包中的文件

这五个是独立的命令，压缩解压都要用到其中一个，可以和别的命令连用但只能用其中一个。下面的参数是根据需要在压缩或解压档案时可选的。

-z：gzip压缩
-j：bz2压缩
-Z：有compress属性的
-v：显示所有过程
-O：将文件解开到标准输出

- 创建压缩包

```
tar czvf  xxx.tar.gz  要打包的目录  --exclude=dir1   --exclude=file1  ......

# 这条命令是列出all.tar包中所有文件，-t是列出文件的意思
tar -tf all.tar
```

```shell
$ tar -czvf test.gz test
$ tar -cjvf test.bz2 test
$ zip test.zip test
$ ll
-rw-rw-r-- 1 zhuyin zhuyin   1811603 Jun  5 16:55 test
-rw-rw-r-- 1 zhuyin zhuyin   1015385 Jun  5 16:55 test.gz
-rw-rw-r-- 1 zhuyin zhuyin    895720 Jun  5 16:55 test.bz2
-rw-rw-r-- 1 zhuyin zhuyin   1015313 Jun  5 16:56 test.zip
```

# 时间信息

所有Unix 文件系统中的文件或文件夹有三个时间戳，分别为atime、ctime和mtime。

1. atime 表示最后一次访问（仅仅访问，没有改动）文件的时间；
2. mtime 表示最后一次修改文件的时间；
3. ctime 表示最后一次对文件属性改变的时间，包括权限、大小、属性等。

| 区别                    | atime              | mtime | ctime |
| --------------------- | ------------------ | ----- | ----- |
| 仅读取或访问文件（cat）         | 改变                 | 不变    | 不变    |
| 修改文件内容                | 不一定（vim 与echo就不一样） | 改变    | 改变    |
| 修改文件权限属性（chmod，chown） | 不变                 | 不变    | 改变    |
如何查看这些时间信息?
```sh
[ubak@ad-manage1 ~]$ file 2017_07_15.tar.gz
2017_07_15.tar.gz: gzip compressed data, from Unix, last modified: Sat Jul 15 16:51:42 2017
[ubak@ad-manage1 ~]$ stat 2017_07_15.tar.gz
  File: `2017_07_15.tar.gz'
  Size: 30825158        Blocks: 60208      IO Block: 4096   regular file
Device: fc01h/64513d    Inode: 169645      Links: 1
Access: (0644/-rw-r--r--)  Uid: (  504/    ubak)   Gid: (  504/    ubak)
Access: 2017-07-19 15:28:38.979000777 +0800
Modify: 2017-07-15 16:48:36.297000776 +0800
Change: 2017-07-15 16:48:36.297000776 +0
```

修改mtime

```
# touch 命令的默认行为就是更新一个文件的atime和mtime，改变到当前的系统时间。
[ubak@ad-manage1 ~]$ touch -mt 1602241622 2017_07_15.tar.gz
[ubak@ad-manage1 ~]$ stat 2017_07_15.tar.gz
  File: `2017_07_15.tar.gz'
  Size: 30825158        Blocks: 60208      IO Block: 4096   regular file
Device: fc01h/64513d    Inode: 169645      Links: 1
Access: (0644/-rw-r--r--)  Uid: (  504/    ubak)   Gid: (  504/    ubak)
Access: 2017-07-19 15:28:38.979000777 +0800
Modify: 2016-02-24 16:22:00.000000000 +0800
Change: 2017-07-19 15:33:56.578000776 +0800
[ubak@ad-manage1 ~]$
```

-m 参数指mtime，接下来的t和一串数字指我们想要更改成的timestamp
　
```
1602241622 代表：

　16 ---> 2016年
　02 ---> 2月
　24 ---> 24号
　1622 --->时间16:22
```

# 权限

## chattr

有时候你发现用root权限都不能修改某个文件，大部分原因是曾经用chattr命令锁定该文件了。chattr命令的作用很大，其中一些功能是由Linux内核版本来支持的，不过现在生产绝大部分跑的linux系统都是2.6以上内核了。通过chattr命令修改属性能够提高系统的安全性，但是它并不适合所有的目录。chattr命令不能保护/、/dev、/tmp、/var目录。lsattr命令是显示chattr命令设置的文件属性。

这两个命令是用来查看和改变文件、目录属性的，与chmod这个命令相比，chmod只是改变文件的读写、执行权限，更底层的属性控制是由chattr来改变的。

chattr命令的用法：`chattr [ -RVf ] [ -v version ] [ mode ] files…`
最关键的是在[mode]部分，[mode]部分是由+-=和[ASacDdIijsTtu]这些字符组合的，这部分是用来控制文件的
属性。

```
+ ：在原有参数设定基础上，追加参数。
- ：在原有参数设定基础上，移除参数。
= ：更新为指定参数设定。
A：文件或目录的 atime (access time)不可被修改(modified), 可以有效预防例如手提电脑磁盘I/O错误的发生。
S：硬盘I/O同步选项，功能类似sync。
a：即append，设定该参数后，只能向文件中添加数据，而不能删除，多用于服务器日志文件安全，只有root才能设定这个属性。
c：即compresse，设定文件是否经压缩后再存储。读取时需要经过自动解压操作。
d：即no dump，设定文件不能成为dump程序的备份目标。
i：设定文件不能被删除、改名、设定链接关系，同时不能写入或新增内容。i参数对于文件 系统的安全设置有很大帮助。
j：即journal，设定此参数使得当通过mount参数：data=ordered 或者 data=writeback 挂 载的文件系统，文件在写入时会先被记录(在journal中)。如果filesystem被设定参数为 data=journal，则该参数自动失效。
s：保密性地删除文件或目录，即硬盘空间被全部收回。
u：与s相反，当设定为u时，数据内容其实还存在磁盘中，可以用于undeletion。
各参数选项中常用到的是a和i。a选项强制只可添加不可删除，多用于日志系统的安全设定。而i是更为严格的安全设定，只有superuser (root) 或具有CAP_LINUX_IMMUTABLE处理能力（标识）的进程能够施加该选项。
```

应用举例：

1、用chattr命令防止系统中某个关键文件被修改：
`# chattr +i /etc/resolv.conf`

然后用mv /etc/resolv.conf等命令操作于该文件，都是得到Operation not permitted 的结果。vim编辑该文件时会提示W10: Warning: Changing a readonly file错误。要想修改此文件就要把i属性去掉： chattr -i /etc/resolv.conf

`# lsattr /etc/resolv.conf`
会显示如下属性
`----i-------- /etc/resolv.conf`

2、让某个文件只能往里面追加数据，但不能删除，适用于各种日志文件：

```shell
chattr +a /var/log/messages
```

## 获取文件夹名称
使用`dirname`和`basename`

```shell
$ VAR=/home/me/mydir/file.c
$ DIR=$(dirname "${VAR}")
$ echo "${DIR}"
/home/me/mydir
$ basename "${VAR}"
file.c
```
