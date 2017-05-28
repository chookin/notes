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

Subversion 1.8中http客户端基于neon已经被移除，改用self。如果要支持http方式需要在安装svn前安装serf，安装serf推荐用serf-1.2.1

```shell
wget http://serf.googlecode.com/files/serf-1.2.1.tar.bz2 #serf-1.2.1.zip是win版有问题
tar xjf serf-1.2.1.tar.bz2
cd serf-1.2.1./configure --prefix=/usr/local/serf --with-apr=/usr/local/apache --with-apr-util=/usr/local/apache
make && make install
```

### 安装svn

```shell
tar xzf subversion-1.8.1.tar.gz
cd subversion-1.8.1./get-deps.sh
./configure --prefix=/usr/local/subversion --with-apxs=/usr/local/apache/bin/apxs \
--with-apr=/usr/local/apache --with-apr-util=/usr/local/apache --with-zlib \
--with-openssl --enable-maintainer-mode --with-serf=/usr/local/serf --enable-mod-activation
make && make install
```

### 检查是否安装成功

安装成功会在`/usr/local/apache/conf/httpd.conf`自己加入下面2行

```
LoadModule dav_svn_module     /usr/local/subversion/libexec/mod_dav_svn.so
LoadModule authz_svn_module   /usr/local/subversion/libexec/mod_authz_svn.so
```

检查svn是否支持http方式：

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
