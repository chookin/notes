## buffer cache

```sh
➜  ~ free -g
             total       used       free     shared    buffers     cached
Mem:           189        155         33          0          0        143
-/+ buffers/cache:         11        177
Swap:            3          0          3
```

A buffer is something that has yet to be "written" to disk. A cache is something that has been "read" from the disk and stored for later use.
buffer与cache 两者都是RAM中的数据。简单来说，buffer是即将要被写入磁盘的，cache是被从磁盘中读出来的。这二者是为了提高IO性能的，并由OS管理，并非应用自己分配的内存，而是OS自己根据需要对空闲内存进行的额外利用。因为这部分只是缓存，降低IO，提升性能，只要应用程序有需要，OS可以直接将buffer写入磁盘，将cache删掉来得到空闲内存给应用程序使用。

-/+ buffers/cache的含义即:使用内存是实际当前使用内存减去buffers/cache之和;空闲内存是实际空闲内存加上buffers/cache之和。 所以是-/+
查看空闲内存，确定应用是否有内存泄漏时，只能以Free的第三行为依据，第二行其实作用不大，只是可以看到OS当前的buffer和cache大小。

## 查看内存信息

```shell
cat /proc/meminfo
```

htop命令显示了每个进程的内存实时使用率。它提供了所有进程的常驻内存大小、程序总内存大小、共享库大小等的报告。列表可以水平及垂直滚动。

## htop

## vmstat
vmstat--虚拟内存统计
vmstat(VirtualMeomoryStatistics,虚拟内存统计) 是Linux中监控内存的常用工具,可对操作系统的虚拟内存、进程、CPU等的整体情况进行监视。

vmstat的常规用法

```
vmstat interval times
即每隔interval秒采样一次，共采样times次，如果省略times,则一直采集数据，直到用户手动停止为止。
```

```sh
➜  ~ vmstat 5 3
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 0  0      0 5705996 402364 182570432    0    0     0     1    0    0  0  0 100  0  0
 1  0      0 5715192 402364 182570688    0    0     0    12 9424 4842  2  1 98  0  0
 0  0      0 5724816 402364 182570880    0    0     0     6 7878 3891  1  0 98  0  0
```


第一行显示了系统自启动以来的平均值，第二行开始显示现在正在发生的情况，接下来的行会显示每5秒间隔发生了什么，每一列的含义在头部，如下所示：

- procs：r这一列显示了多少进程在等待cpu，b列显示多少进程正在不可中断的休眠（等待IO）。
- memory：swapd列显示了多少块被换出了磁盘（页面交换），剩下的列显示了多少块是空闲的（未被使用），多少块正在被用作缓冲区，以及多少正在被用作操作系统的缓存。
- swap：显示交换活动：每秒有多少块正在被换入（从磁盘）和换出（到磁盘）。
- io：显示了多少块从块设备读取（bi）和写出（bo）,通常反映了硬盘I/O。
- system：显示每秒中断(in)和上下文切换（cs）的数量。
- cpu：显示所有的cpu时间花费在各类操作的百分比，包括执行用户代码（非内核），执行系统代码（内核），空闲以及等待IO。

内存不足的表现：free  memory急剧减少，回收buffer和cacher也无济于事，大量使用交换分区（swpd）,页面交换（swap）频繁，读写磁盘数量（io）增多，缺页中断（in）增多，上下文切换（cs）次数增多，等待IO的进程数（b）增多，大量CPU时间用于等待IO（wa）

## Top命令监控某个进程的资源占有情况

下面是各种内存：

VIRT：virtual memory usage

    1、进程“需要的”虚拟内存大小，包括进程使用的库、代码、数据等
    2、假如进程申请100m的内存，但实际只使用了10m，那么它会增长100m，而不是实际的使用量

RES：resident memory usage 常驻内存

    1、进程当前使用的内存大小，但不包括swap out
    2、包含其他进程的共享
    3、如果申请100m的内存，实际使用10m，它只增长10m，与VIRT相反
    4、关于库占用内存的情况，它只统计加载的库文件所占内存大小

SHR：shared memory

    1、除了自身进程的共享内存，也包括其他进程的共享内存
    2、虽然进程只使用了几个共享库的函数，但它包含了整个共享库的大小
    3、计算某个进程所占的物理内存大小公式：RES – SHR
    4、swap out后，它将会降下来

DATA

    1、数据占用的内存。如果top没有显示，按f键可以显示出来。
    2、真正的该程序要求的数据空间，是真正在运行中要使用的。
