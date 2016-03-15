# yum
安装epel http://mirrors.yun-idc.com/epel/6/x86_64/epel-release-6-8.noarch.rpm
不能仅仅拷贝epel.repo,否则从epel安装包时会报错。

# 常用仓库
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
