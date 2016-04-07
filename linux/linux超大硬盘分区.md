# 超大硬盘分区

安装os完毕后，root登录linux。

## GPT
由于MBR分区表只支持2T磁盘，所以大于2T的磁盘必须使用GPT分区表。

```
# parted
GNU Parted 2.1
Using /dev/sda
Welcome to GNU Parted! Type 'help' to view a list of commands.
(parted) select /dev/sdb # 假定硬盘为/dev/sdb
Using /dev/sdb
(parted) mklabel gpt # 将MBR硬盘格式化为GPT
Warning: The existing disk label on /dev/sdb will be destroyed and all data on this disk will be lost.
Do you want to continue?
Yes/No? yes                                                               
(parted) mkpart primary 0 -1 # 将整块硬盘分成一个分区                                          
Warning: The resulting partition is not properly aligned for best performance.
Ignore/Cancel? i                                                          
(parted) quit                                                             
Information: You may need to update /etc/fstab.
```

## xfs格式化
### 安装xfsprogs
挂载rhel的iso安装盘，从其中找到xfsprogs的安装包，安装即可。
或者直接从网络下载安装。

```shell
yum install -y http://mirrors.aliyun.com/centos/6/os/x86_64/Packages/xfsprogs-3.1.1-16.el6.x86_64.rpm
```

### 格式化
利用mkfs.xfs格式化硬盘，xfs格式化速度还是挺快的，稍等几分钟即可把30T的硬盘格式化完毕。

```shell
mkfs.xfs -f /dev/sdb1
```

### 挂载硬盘
创建数据文件夹，并挂载磁盘分区到此路径。

```shell
mkdir /data
mount /dev/sdb1 /data/
```

### 配置硬盘开机挂载
修改/etc/fstab，新增一行

```
/dev/sdb1       /data           xfs     defaults        0 0
```
之后，执行如下命令测试是否配置正确，如果报错，请一定检查。

```shel
mount -a
```
或者，一步到位执行如下命令：

```shell
cp /etc/fstab /etc/fstab.bak && echo '/dev/sdb1               /data                   xfs     defaults        0 0'>> /etc/fstab && mount -a
```

