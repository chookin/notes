# 磁盘

Q: 提示 readonly file system
A: 重新挂载为读写

```shell
/bin/mount -o remount,rw /
```

# 软件

**Q: 编译jpeg-6b时，在`./configure` 时发生错误**

> ****checking host system type... Invalid configuration `x86_64-unknown-linux-gnu': machine `x86_64-unknown' not recognized

A: 下载`http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD `并重命名为`config.sub`

    chmod + config.sub
**Q: freetype2安装出错**

> ****rmdir: failed to remove `/usr/local/include/freetype2/freetype/internal': No such file or directory

A: 创建文件夹

    mkdir -p /usr/local/include/freetype2/freetype/internal
**Q: rz命令找不到**

```shell
bash: rz: command not found
```

A: 安装`lrzsz`包。

    yum install lrzsz
**Q: 编译openssh 6.9 p1时报错**

> configure: error: *** zlib.h missing
>
> configure: error: *** OpenSSL headers missing

A: 安装zlib和openssl的开发包
    yum install -y zlib-devel openssl-devel
**Q: 报错`GLIBC_2.10` 找不到**

> /lib64/libc.so.6: version `GLIBC_2.10' not found

A: 查看系统glibc支持的版本：

```shell
strings /lib64/libc.so.6 |grep GLIBC_
```

到 http://www.gnu.org/software/libc/ 下载最新版本

注意，不要随便升级glibc，否则可能将造成系统崩溃。

参考：

- [解决libc.so.6: version `GLIBC_2.14' not found问题](http://blog.csdn.net/cpplang/article/details/8462768)

# 网络

**Q: 服务器可ping，但无法ssh**

****20160909，lab11服务器系统出问题，服务器可ping，但无法ssh
重启服务器，服务器恢复连接。该系统版本是rhel5.5，查看系统日志/var/log/messages，发现错误信息如下：

```
Sep  9 03:18:21 lab11 kernel: INFO: task irqbalance:7294 blocked for more than 120 seconds.
Sep  9 03:18:21 lab11 kernel: "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Sep  9 03:18:21 lab11 kernel: irqbalance    D ffff81010e794cb0     0  7294      1          7324  7048 (NOTLB)
Sep  9 03:18:21 lab11 kernel:  ffff8104112cdc58 0000000000000086 0000000100000000 ffff8104112cdc38
Sep  9 03:18:21 lab11 kernel:  00000000242f54e8 0000000000000007 ffff81041fd35820 ffff81101ff1e100
Sep  9 03:18:21 lab11 kernel:  000037b405bd91e1 0000000000008830 ffff81041fd35a08 000000088000f380
Sep  9 03:18:21 lab11 kernel: Call Trace:
Sep  9 03:18:21 lab11 kernel:  [<ffffffff8012ac81>] avc_has_perm+0x46/0x58
Sep  9 03:18:21 lab11 kernel:  [<ffffffff80064c6f>] __mutex_lock_slowpath+0x60/0x9b
Sep  9 03:18:21 lab11 kernel:  [<ffffffff80064cb9>] .text.lock.mutex+0xf/0x14
```


解决办法：

> This is a know bug. By default Linux uses up to 40% of the available memory for file system caching. After this mark has been reached the file system flushes all outstanding data to disk causing all following IOs going synchronous. For flushing out this data to disk this there is a time limit of 120 seconds by default. In the case here the IO subsystem is not fast enough to flush the data withing 120 seconds. This especially happens on systems with a lof of memory.
> The problem is solved in later kernels and there is not “fix” from Oracle. I fixed this by lowering the mark for flushing the cache from 40% to 10% by setting “vm.dirty_ratio=10″ in /etc/sysctl.conf. This setting does not influence overall database performance since you hopefully use Direct IO and bypass the file system cache completely.
> linux会设置40%的可用内存用来做系统cache，当flush数据时这40%内存中的数据由于和IO同步问题导致超时（120s），所将40%减小到10%，避免超时。

具体是，修改内核参数`vi /etc/sysctl.conf`：

```
vm.dirty_background_ratio = 5
vm.dirty_ratio = 10
```

然后执行：

```shell
# use sysctl -p after modifying the sysctl.conf file to make the changes permanent, there is no need to reboot the system!
sysctl -p
```

https://www.blackmoreops.com/2014/09/22/linux-kernel-panic-issue-fix-hung_task_timeout_secs-blocked-120-seconds-problem/
http://www.ttlsa.com/linux/kernel-blocked-for-more-than-120-seconds/


