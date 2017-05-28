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

说明：ustc 中国科学技术大学（University of Science and Technology of China）

# 其他
## 配置本地源

```shell
cd /etc/yum.repos.d/ && vi rhel-source.repo
```

```shell
[rhel6.5-iso]
name=rhel6.5
baseurl=file:///data/repos/rhel6.5/

#是否用该yum源，0为禁用，1为使用
enabled=1

#检查GPG-KEY，0为不检查，1为检查
gpgcheck=0
```

## 下载epel源

```shell
mkdir -p epel/6/x86_64

nohup wget -e robots=off -r -p -k -np --proxy=off -nc -P epel/6/x86_64 http://mirrors.yun-idc.com/epel/6/x86_64/ &

mkisofs -o epel-6-x86_64.iso epel/6/x8664
```

## 下载centos updates源

```shell
mkdir -p centos/6/updates/x86_64

nohup wget -e robots=off -r -p -k -np --proxy=off -nc -P centos/6/updates/x86_64 http://mirrors.163.com/centos/6/updates/x86_64/ &
```

测试

```shell
wget http://mirrors.163.com/centos/6/updates/x86_64/Packages/ImageMagick-doc-6.7.2.7-4.el6_7.x86_64.rpm
```

## 下载redhat6.5

http://rhnproxy1.uvm.edu/pub/redhat/rhel6-x86_64/isos/

## 163的yum源

 http://mirrors.163.com/.help/centos.html

## 其他源

centos5
http://centos.ustc.edu.cn/centos/5/updates/x86_64/

rhel5 的iso
http://mirror.corbina.net/pub/Linux/redhat/5Server/x86_64/
