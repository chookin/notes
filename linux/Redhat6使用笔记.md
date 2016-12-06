## 单用户模式启动

当出现系统启动界面的时候，按`e`键，进入编辑模式；
再按`e`，进入编辑页面，在出现的`kernel`行的最后加上`single`或`1`，点击回车（或者是键入`b`,`Press 'b' to boot`）。

单用户进入系统，默认磁盘是只读挂载。

将根目录重新挂载成为可擦写:

```shell
mount -o remount,rw /
```

`mount -a`则是参考 /etc/fstab 的内容重新挂载文件系统。

## 忘记root密码

首先单用户模式进入系统。

然后执行`passwd`命令.

若执行没有反应，则检查是否SELinux在搞怪。

```shell
[root@lab07 /]# getenforce
Enforcing
```

关闭SELinux.

```shell
[root@lab07 /]# setenforce 0
[root@lab07 /]# getenforce
Permissive
```

然后再次执行`passwd`命令。

## 安装中文包

需要使用centos的yum源

```shell
yum groupinstall Chinese-support
```

编辑文件 /etc/sysconfig/i18n，配置语言为中文

```shell
LANG="zh_CN.utf8"
```

## 图形界面切换到命令行

从图形界面切换到命令界面可以按`Ctrl+Alt+Fn`（n=1,2,3,4,5,6）
从命令介面切换到图形界面可以按`Alt+F1`(或者F1--F7,根据个人电脑设置不同.可能不一样)(也可以输入命令startx进入图形界面)。