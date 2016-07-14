# yum
安装epel
```shell
yum install -y http://mirrors.yun-idc.com/epel/6/x86_64/epel-release-6-8.noarch.rpm
```
不能仅仅拷贝epel.repo,否则安装epel中的package时会报错。

# 常用仓库
在`/etc/yum.repos.d`文件夹创建`centos.repo`文件，文件内容如下：

```
[centos6-iso]
name=centos6-iso
baseurl=http://centos.ustc.edu.cn/centos/6/os/x86_64/
enabled=1
gpgcheck=0

[centos6-updates]
name=centos6-updates
baseurl=http://centos.ustc.edu.cn/centos/6/updates/x86_64/
enabled=1
gpgcheck=0
```
