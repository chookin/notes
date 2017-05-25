# 简介

整个mfs共计四种角色：master、metalogger、chunk和client

1、master：在整个体系中负责管理管理文件系统，目前MFS只支持一个元数据服务器master，这是一个单点故障，需要一个性能稳定的服务器来充当。希望今后MFS能支持多个master服务器，进一步提高系统的可靠性。。

2、metalogger：可以有多台。它负责定期从master下载metadata，并实时同步changelog。当master挂了的时候，metalogger利用下载下来的metadata和实时同步的changelog来恢复master挂掉时候的metadata。并且接管master的功能。

3、chunk：提供存储的服务器，可以有多台。这些服务器负责提供存储，它可以自由的启动和停止。在chunk启动后，会主动与master联系，master知道有多少chunk在网络中，并且会定期检查chunk的状态。

4、client：使用mfs的服务器，可以有多台。它需要运行mfsmount命令，将网络上的存储挂载到本地，看起来类似nfs。client就像读写本地磁盘那样读写mfsmount挂载的网络存储。

# 部署

**软件版本**

fuse 2.8.4

moosefs 1.6.20

## 基本流程

mfs安装到用户work，路径是`/home/work/local/mfs`.

安装的基本流程如下。

- 在集群各节点安装基础组件及配置打开文件数
- 在cm01编译安装fuse（包括配置/etc/profile）
- 在cm01编译安装mfs，并配置
- 把cm01 fuse的编译后的文件同步到其余的服务器，并远程执行make && make install
- 把cm01 /etc/profile同步其他节点以及`source /etc/profile`
- 把cm01编译生成并配置后的文件同步到其他节点
- master节点启动mfsmaster
- meta节点启动metalogger
- chunk各节点启动chunkserver
- 创建挂载映像文件夹，并mfsmount挂载
- 配置文件的备份数

## 前提条件

### 安装基础组件

在集群各机器上安装如下组件。

```shell
yum install -y zlib-devel
```

### 配置打开文件数

配置打开文件数，否则报错：

```
Nov 24 10:36:20 JXNC-BD-PageCode-002 mfsmetalogger[7221]: can't change open files limit to 5000
Nov 24 10:36:20 JXNC-BD-PageCode-002 mfsmetalogger[7221]: connecting ...
Nov 24 10:36:20 JXNC-BD-PageCode-002 mfsmetalogger[7221]: open files limit: 1024
```



```shell
vi /etc/security/limits.conf
```



```shell
# Username type    item           value
work       -    nofile         655360
```

文件修改后，__重新打开shell__,执行命令`ulimit -a`，可发现配置已生效。

```shell
[root@PZMG-WB01-VAS ~]# su - work
[work@PZMG-WB01-VAS ~]$ ulimit -a
core file size          (blocks, -c) 0
data seg size           (kbytes, -d) unlimited
scheduling priority             (-e) 0
file size               (blocks, -f) unlimited
pending signals                 (-i) 257569
max locked memory       (kbytes, -l) 64
max memory size         (kbytes, -m) unlimited
open files                      (-n) 65536
pipe size            (512 bytes, -p) 8
POSIX message queues     (bytes, -q) 819200
real-time priority              (-r) 0
stack size              (kbytes, -s) 10240
cpu time               (seconds, -t) unlimited
max user processes              (-u) 1024
virtual memory          (kbytes, -v) unlimited
file locks                      (-x) unlimited
```

## 安装fuse

对于client端，需要安装fuse程序后，才可以编译mfsmount程序；并且需要加载fuse.ko内核模块后才能正确运行mfsmount命令。

若不安装，mfs编译将报错“mfsmount build was forced, butfuse library is too old or not installed”。

> Using a version of FUSE higher than version 2.8.4 on CentOS 5 will resultin the following error:
>
> /bin/mount: unrecognized option`--no-canonicalize'

 fuse-2.8.4.tar.gz在http://sourceforge.net/projects/fuse/中下载

```shell
tar xvzf fuse-2.8.4.tar.gz

cd fuse-2.8.4
./configure
make
make install
```

添加如下内容到`/etc/profile`

```shell
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
```

然后执行

```shell
source /etc/profile
```

## 编译安装mfs

http://moosefs.org/download.html

```shell
wget http://pro.hit.gemius.pl/hitredir/id=.WCbG2t.7Ln5k1s3Q9xPg8cPfX.wVMc5kyXfrKcJTDH.c7/url=moosefs.org/tl_files/mfscode/mfs-1.6.27-1.tar.gz
...

./configure --prefix=/home/work/local/mfs --with-default-user=work  --with-default-group=work --enable-mfsmount
make && make install
```

### metalogger

metalogger有一个配置文件，mfsmetalogger.cfg

```shell
cd /home/work/local/mfs/etc
cp mfsmetalogger.cfg.dist mfsmetalogger.cfg
```

### master

master有两个配置文件，mfsmaster.cfg、mfsexports.cfg.

```shell
cp mfsexports.cfg.dist mfsexports.cfg
cp mfsmaster.cfg.dist mfsmaster.cfg
```

通过在`mfsexports.cfg`中如下配置，可使得任何账户均可读写mfs中的共享文件。（如果已经挂载，请在各chunkserver重新挂载）

```shell
# Allow everything but "meta".
#*                       /       rw,alldirs,maproot=0
*                       /       rw,alldirs,mapall=work:work
```

### chunkserver

 chunkserver有两个配置文件，mfschunkserver.cfg、mfshdd.cfg

```shell
cp mfschunkserver.cfg.dist mfschunkserver.cfg
cp mfshdd.cfg.dist mfshdd.cfg
```

mfshdd.cfg说明chunk服务器贡献出来的存储的路径，比如贡献出/data/mfs这个目录，则在mfshdd.cfg文件中增加如下行：

```shell
/data/mfs
```



若`/home`路径的分区更大一些，则可把数据放在`/home/data/mfs`，并通过软链接的方式映射到`/data/mfs`。

```shell
[root@PZMG-WB01-VAS ~]# df -h
Filesystem                    Size  Used Avail Use% Mounted on
/dev/mapper/VolGroup-lv_root   50G   34G   13G  73% /
tmpfs                          16G  308K   16G   1% /dev/shm
/dev/xvda1                    485M   51M  409M  12% /boot
/dev/mapper/VolGroup-lv_home  140G   42G   92G  32% /home
```



```shell
 mkdir -p /home/data/mfs
 chown -R work.work /home/data/mfs
 mkdir /data
 chmod 755 /data/
 ln -s /home/data/mfs /data/mfs
```

###

### 同步

同步配置信息到其他服务器：

进入到mfs安装路径的上级目录，之后执行

```shell
rsync -av /home/work/local/mfs root@${host}:/home/work/local/ --exclude=mfs/var/mfs/*
```

## 启停



### master

 mfs首次编译安装结束后，在启动mfsmaster之前，需要建立一个初始的metadata文件，否则报错。

```
$ sbin/mfsmaster start
working directory: /home/work/local/mfs/var/mfs
lockfile created and locked
initializing mfsmaster modules ...
loading sessions ... file not found
if it is not fresh installation then you have to restart all active mounts !!!
exports file has onbeen loaded
loading metadata ...
can't open metadata file
if this is new instalation then rename /home/work/local/mfs/var/mfs/metadata.mfs.empty as /home/work/local/mfs/var/mfs/metadata.mfs
init: file system manager failed !!!
error occured during initialization - exiting
```

使用自带文件即可：

```shell
cd /home/work/local/mfs/var/mfs && cp metadata.mfs.empty metadata.mfs
```

启动

```shell
$ mfsmaster start
working directory: /home/work/local/mfs/var/mfs
lockfile created and locked
initializing mfsmaster modules ...
loading sessions ... ok
sessions file has been loaded
exports file has been loaded
loading metadata ...
create new empty filesystemmetadata file has been loaded
no charts data file - initializing empty charts
master <-> metaloggers module: listen on *:9419
master <-> chunkservers module: listen on *:9420
main master server module: listen on *:9421
mfsmaster daemon initialized properly
```

 停止

```shell
mfsmaster stop
```

 vi日志：

/var/log/messages

### chunkserver

```
$ mfschunkserver start
cannot load config file: /home/work/local/mfs/etc/mfschunkserver.cfg
can't load config file: /home/work/local/mfs/etc/mfschunkserver.cfg - using defaults
working directory: /home/work/local/mfs/var/mfs
lockfile created and locked
initializing mfschunkserver modules ...
hdd space manager: scanning folder /data/mfs/ ...
hdd space manager: scanning complete
hdd space manager: /data/mfs/: 0 chunks found
hdd space manager: scanning complete
main server module: listen on *:9422
no charts data file - initializing empty charts
mfschunkserver daemon initialized properly
```

### metalogger

```shell
$ mfsmetalogger start
working directory: /home/work/local/mfs/var/mfs
lockfile created and locked
initializing mfsmetalogger modules ...
mfsmetalogger daemon initialized properly
```



### mfscgiserv

 mfscgiserv是python写的简易的webserver，mfs的web端监控系统的应用程序。可以通过它供使用者使用。它需要在master服务器中运行，因为监控程序是监控本地启动的mfsmaster程序。

1、命令：

```shell
$ python sbin/mfscgiserv

starting simple cgiserver (host: any , port: 9425 , rootpath: /home/work/local/mfs/share/mfscgi)
```

2、访问：

在浏览器地址栏中输入：

http://mfscgiserv_host:9425 

这里面mfscgiserv的默认端口是9425

### client挂载网络文件系统

mfsmount因为是挂在文件系统，因此需要root用户运行。

#### 挂载

client端使用mfsmount命令挂载mfs，这个过程与nfs的挂载类似。这里client挂载时使用master的IP地址或者机器名。

```shell
mkdir /home/work/share && chown -R work.work /home/work/share
/home/work/local/mfs/bin/mfsmount /home/work/share/ -H mfsmaster

mfsmaster accepted connection with parameters: read-write,restricted_ip,map_all ; root mapped to work:work ; users mapped to work:work
```

/home/work/share/是本地挂载点，需手工创建。

若如下报错，则fuse没有安装，或者安装的版本不对。

```
/home/work/local/mfs/bin/mfsmount: error while loading shared libraries: libfuse.so.2: cannot open shared object file: No such file or directory
```

#### 取消挂载

```shell
[root@JXNC-BD-PageCode-002 ~]# umount /home/work/share
umount: /home/work/share: device is busy.
        (In some cases useful info about processes that use
         the device is found by lsof(8) or fuser(1))
[root@JXNC-BD-PageCode-002 ~]# umount -l /home/work/share
```



### 设置文件备份数

设置

```shell
$ mfssetgoal -r 3 /home/work/share/
/home/work/share/:
 inodes with goal changed:                         2
 inodes with goal not changed:                     0
 inodes with permission denied:                    1
```

查看

```shell
# 查看文件备份数
$mfsgetgoal /home/work/share/
/home/work/share/: 3
# 查看文件具体信息
$ mfsfileinfo a
a:
        chunk 0: 0000000000000002_00000001 / (id:2 ver:1)
                copy 1: 10.176.215.177:9422
```

## 问题

Q: 挂载失败

```
mount: according to mtab, mfsmaster:9421 is already mounted on
```

A: 再次执行取消挂载

```shell
umount -l share
```

# 维护

## 移除磁盘

When you want to mark a disk for removal from a chunkserver, you need toedit the chunkserver's mfshdd.cfg configuration file and put anasterisk '*' at the start of the line with the disk that is to be removed. Forexample, in this mfshdd.cfg we have marked "/mnt/hdd"for removal:

```
/mnt/hda
/mnt/hdb
/mnt/hdc
*/mnt/hdd
/mnt/hde
```



After changing the mfshdd.cfg you need to reload chunkserver

```shell
mfschunkserver reload
```

or

```shell
mfschunkserver restart
```



## 移除chunkserver

You can add/remove chunk servers on the fly. But keep in mind that it is not wise to disconnect a chunk server if this server contains the only copy ofa chunk in the file system (the CGI monitor will mark these in orange). You canalso disconnect (change) an individual hard drive. The scenario for this operation would be:

1. Mark the disk(s) for removal (see How to mark a disk for removal?)
2. Reload the chunkserver process
3. Wait for the replication (there should be no "undergoal" or     "missing" chunks marked in yellow, orange or red in CGI monitor)
4. Stop the chunkserver process
5. Delete entry(ies) of the disconnected disk(s) in mfshdd.cfg
6. Stop the chunkserver machine
7. Remove hard drive(s)
8. Start the machine
9. Start the chunkserver process

## master的主备切换

master的主备切换分为两个步骤：一是由metalogger恢复master；二是chunk和client端进行响应的处理。

### metalogger恢复master

​1、metalogger定期从master下载metadata文件，并实时记录changelog，但是这个“实时”究竟有多么的实时，还得再看看。这个下载metadata和记录changelog的工作有点类似sfrd客户端每天下载基准和导入增量。

​2、master挂掉之后，使用metarestore命令将metalogger中的基准和增量变成master需要的metadata，然后启动mfsmaster。master和metalogger可以部署在同一台机器，也可以部署在不同机器。

​3、metalogger恢复master时使用的命令：

```shell
$ cd/home/work/local/mfs/sbin

$ ./metarestore –a

$ ./mfsmaster
```

​    4、说明：

​    (1)metalogger服务器中需要备份master的两个配置文件，由于配置文件不是经常变化，因此通过定时脚本进行文件同步即可。

​    (2)当metalogger没有下载metadata之前，不能使用期接管master。此时metarestore程序会运行失败。

​    (3)metarestore程序是根据metalogger中定期下载的metadata和changelog来恢复master挂掉时刻master所记录的整个mfs的信息。

​

### chunk和client相应的修改

​    1、对于client，需要umount掉mfs分区后，重启mfsmount新的master的IP地址。如果master挂掉之后，经过(1)重启服务器(2)使用同一台机器中metalogger恢复master数据(3)启动master；则client端不需要重新手动进行mfsmount，因为mfsmount会自动重试。

​    2、对于chunk，可以逐个chunk修改配置文件中master的IP地址，然后进行重启。如果master挂掉之后，经过(1)重启服务器(2)使用同一台机器中metalogger恢复master数据(3)启动master；则chunk不需要重启，master会在自动检测chunk的时候检测到它。

## metalogger的注意事项

​    1、metalogger在启动时不会下载metadata，而是等到第一个下载周期的下载时间点时再去下载，metalogger下载metadata的时间点是每小时的10分30秒，时间间隔是1小时的整数倍。

​    2、metalogger不是在启动的时候就取下载metadata，而是必须等到下载时间点(1中所述)才会去下载。也就是说，metalogger为确保正确性，要在启动后最少一个小时以内master和metalogger都要保持良好的状态。

## 端口使用

### mfschunkserver

mfschunkserver与master 9420建立连接使用的随机端口

```shell
[root@PZMG-WB02-VAS ~]# netstat -lanp |grep `ps aux |grep mfschunk |grep -v grep | awk '{print $2}'` |grep -v unix
tcp        0      0 0.0.0.0:9422                0.0.0.0:*                   LISTEN      64816/mfschunkserve
tcp        0      0 172.17.128.12:52799         172.17.128.16:9420          ESTABLISHED 64816/mfschunkserve
```

### mfsmaster

mfsmaster也是同样，与mfschunk，mfsmount，mfscgisvr通信均是与对方的随机端口通信。

```shell
[root@PZMG-WB06-VAS ~]# netstat -lanp |grep `ps aux |grep mfsmaster |grep -v grep |grep -v mfsmount | awk '{print $2}'` |grep -v unix
tcp        0      0 0.0.0.0:9419                0.0.0.0:*                   LISTEN      52488/mfsmaster
tcp        0      0 0.0.0.0:9420                0.0.0.0:*                   LISTEN      52488/mfsmaster
tcp        0      0 0.0.0.0:9421                0.0.0.0:*                   LISTEN      52488/mfsmaster
tcp        0      0 172.17.128.16:9420          172.17.128.24:41508         ESTABLISHED 52488/mfsmaster
tcp        0      0 172.17.128.16:9421          172.17.128.18:41230         ESTABLISHED 52488/mfsmaster
tcp        0      0 172.17.128.16:9421          172.17.128.16:36165         ESTABLISHED 52488/mfsmaster
tcp        0      0 172.17.128.16:9421          172.17.128.19:36499         ESTABLISHED 52488/mfsmaster
tcp        0      0 172.17.128.16:9420          172.17.128.26:57693         ESTABLISHED 52488/mfsmaster
tcp        0      0 172.17.128.16:9420          172.17.128.11:48688         ESTABLISHED 52488/mfsmaster
tcp        0      0 172.17.128.16:9421          172.17.128.13:55046         ESTABLISHED 52488/mfsmaster
tcp        0      0 172.17.128.16:9421          172.17.128.25:47478         ESTABLISHED 52488/mfsmaster
tcp        0      0 172.17.128.16:9420          172.17.128.12:52799         ESTABLISHED 52488/mfsmaster
tcp        0      0 172.17.128.16:9421          172.17.128.12:43058         ESTABLISHED 52488/mfsmaster
tcp        0      0 172.17.128.16:9420          172.17.128.22:58782         ESTABLISHED 52488/mfsmaster
tcp        0      0 172.17.128.16:9421          172.17.128.26:38437         ESTABLISHED 52488/mfsmaster
tcp        0      0 172.17.128.16:9421          172.17.128.22:55940         ESTABLISHED 52488/mfsmaster
tcp        0      0 172.17.128.16:9420          172.17.128.25:40195         ESTABLISHED 52488/mfsmaster
tcp        0      0 172.17.128.16:9421          172.17.128.14:35044         ESTABLISHED 52488/mfsmaster
tcp        0      0 172.17.128.16:9421          172.17.128.20:60832         ESTABLISHED 52488/mfsmaster
tcp        0      0 172.17.128.16:9420          172.17.128.20:38167         ESTABLISHED 52488/mfsmaster
tcp        0      0 172.17.128.16:9420          172.17.128.13:59243         ESTABLISHED 52488/mfsmaster
tcp        0      0 172.17.128.16:9420          172.17.128.17:43093         ESTABLISHED 52488/mfsmaster
tcp        0      0 172.17.128.16:9421          172.17.128.15:45446         ESTABLISHED 52488/mfsmaster
tcp        0      0 172.17.128.16:9421          172.17.128.21:37912         ESTABLISHED 52488/mfsmaster
tcp        0      0 172.17.128.16:9421          172.17.128.23:47543         ESTABLISHED 52488/mfsmaster
tcp        0      0 172.17.128.16:9420          172.17.128.19:42369         ESTABLISHED 52488/mfsmaster
tcp        0      0 172.17.128.16:9421          172.17.128.24:39155         ESTABLISHED 52488/mfsmaster
tcp        0      0 172.17.128.16:9420          172.17.128.18:42402         ESTABLISHED 52488/mfsmaster
tcp        0      0 172.17.128.16:9421          172.17.128.17:59846         ESTABLISHED 52488/mfsmaster
tcp        0      0 172.17.128.16:9420          172.17.128.21:38234         ESTABLISHED 52488/mfsmaster
tcp        0      0 172.17.128.16:9420          172.17.128.23:40484         ESTABLISHED 52488/mfsmaster
tcp        0      0 172.17.128.16:9419          172.17.128.19:57119         ESTABLISHED 52488/mfsmaster
tcp        0      0 172.17.128.16:9420          172.17.128.16:38175         ESTABLISHED 52488/mfsmaster
tcp        0      0 172.17.128.16:9420          172.17.128.14:42144         ESTABLISHED 52488/mfsmaster
tcp        0      0 172.17.128.16:9421          172.17.128.11:33112         ESTABLISHED 52488/mfsmaster
tcp        0      0 172.17.128.16:9420          172.17.128.15:34610         ESTABLISHED 52488/mfsmaster
```

### mfsmount

mfsmount使用的也是随机端口与master的9421端口通信

```shell
[root@PZMG-WB02-VAS ~]# netstat -lanp |grep `ps aux |grep mfsmount |grep -v grep | awk '{print $2}'` |grep -v unix
tcp        0      0 172.17.128.12:43058         172.17.128.16:9421          ESTABLISHED 67564/mfsmount
```

### mfsmetalogger

与master的9419

```shell
[root@PZMG-WB09-VAS ~]# netstat -lanp |grep `ps aux |grep mfsmeta |grep -v grep | awk '{print $2}'` |grep -v unix
tcp        0      0 172.17.128.19:57119         172.17.128.16:9419          ESTABLISHED 56907/mfsmetalogger
```

### mfscgisvr

向外提供端口为9425的web服务。

```shell
[root@PZMG-WB01-VAS ~]# netstat -lanp |grep `ps aux |grep mfscgi |grep -v grep | awk '{print $2}'` |grep -v unix
tcp        0      0 0.0.0.0:9425                0.0.0.0:*                   LISTEN      26224/python
```

