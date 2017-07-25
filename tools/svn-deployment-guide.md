# 安装subversion

## 编译安装subversion

http://subversion.apache.org/download.cgi#recommended-release

### 安装apr及apr-utils

http://apr.apache.org/download.cgi
下载、编译、安装http://mirror.bit.edu.cn/apache//apr/apr-util-1.5.4.tar.gz

```shell
./configure --prefix=/usr/local/apr
make & make install
./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr
make & make install
```

### 安装serf

Subversion 1.8开始，http客户端基于neon已经被移除，改用self。如果要支持`svn co http://...`方式，需要在安装svn前安装serf。

```shell
wget http://serf.googlecode.com/files/serf-1.2.1.tar.bz2 #serf-1.2.1.zip是win版有问题
tar xjf serf-1.2.1.tar.bz2
cd serf-1.2.1
base_dir=/home/`whoami`/local
./configure --prefix=$base_dir/serf --with-apr=$base_dir/apr --with-apr-util=$base_dir/apr-util
make && make install
```

```sh
wget https://www.apache.org/dist/serf/serf-1.3.9.zip --no-check-certificate
# 请先阅读serf源码包中的README
# 需要先安装scons
# wget http://prdownloads.sourceforge.net/scons/scons-local-2.3.0.tar.gz
base_dir=/home/`whoami`/local
scons APR=$base_dir/apr PREFIX=$base_dir/serf
scons install
```

### 安装svn

```shell
wget http://mirrors.tuna.tsinghua.edu.cn/apache/subversion/subversion-1.9.6.zip

base_dir=/usr/local
base_dir=$HOME/local
./configure --prefix=$base_dir/subversion --with-apxs=$base_dir/apache/bin/apxs --with-apr=$base_dir/apr --with-apr-util=$base_dir/apr-util --with-zlib --with-openssl --enable-maintainer-mode --enable-shared=yes
make && make install
```

### 配置apache

拷贝`dav_svn_module`和`authz_svn_module`到apache的`modules`文件夹

```sh
~ cp ~/local/subversion/libexec/mod_* ~/local/apache/modules/
```

配置apache的`httpd.conf`，增加引用subversion.conf

```
Include conf/extra/subversion.conf
```

之后，重启apache

```sh
apachectl -k restart
```

### 常见问题

```sh
➜  ~ apachectl -k restart
httpd: Syntax error on line 576 of /home/zhuyin/local/apache-2.4.26/conf/httpd.conf: Syntax error on line 2 of /home/zhuyin/local/apache-2.4.26/conf/extra/subversion.conf: Cannot load modules/mod_dav_svn.so into server: /home/zhuyin/local/apache-2.4.26/modules/mod_dav_svn.so: undefined symbol: dav_register_provider
```

从网上找了原因，是因为编译apache的时候没有加上`--enable-dav --enable-so`参数。重新编译apache，检查编译安装生成的apache的modules文件夹是否包含`mod_dav.so`文件。之后，配置httpd.conf

```sh
LoadModule dav_module modules/mod_dav.so
```

### 检查svn支持的模式

```
# svn --version
svn, version 1.8.1 (r1503906)
   compiled Aug  2 2013, 11:36:48 on x86_64-unknown-linux-gnu
Copyright (C) 2013 The Apache Software Foundation.This software consists of contributions made by many people;
see the NOTICE file for more information.Subversion is open source software, see http://subversion.apache.org/
The following repository access (RA) modules are available:
* ra_svn : Module for accessing a repository using the svn network protocol.
  - with Cyrus SASL authentication
  - handles 'svn' scheme
* ra_local : Module for accessing a repository on local disk.
  - handles 'file' scheme
* ra_serf : Module for accessing a repository via WebDAV protocol using serf.
  - handles 'http' scheme
  - handles 'https' scheme
```

## 通过yum安装Subversion

### 安装apache

```shell
yum install httpd
```

启动并配置开机自启动

```shell
service httpd start
chkconfig httpd on
```

### 安装Subversion

```shell
yum install subversion mod_dav_svn
```

安装完毕后，在` /etc/httpd/module`下面生成两个关于 svn的mod.

```
ll modules/ | grep svn
-rwxr-xr-x 1 root root   12704 Apr 12  2012 mod_authz_svn.so
-rwxr-xr-x 1 root root  146928 Apr 12  2012 mod_dav_svn.so
```

在`/etc/httpd/conf.d/`文件下生成`subversion.conf`。
