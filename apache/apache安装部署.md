# 安装

## 下载

https://httpd.apache.org

```shell
wget http://apache.fayea.com//httpd/httpd-2.4.23.tar.gz
wget http://mirrors.cnnic.cn/apache//apr/apr-1.5.2.tar.gz
wget http://mirrors.cnnic.cn/apache//apr/apr-util-1.5.4.tar.gz
wget https://sourceforge.net/projects/pcre/files/pcre/8.39/pcre-8.39.tar.gz --no-check-certificate
```

## 编译安装

首先编译安装pcre

```shell
# compile and install pcre
cd ..
tar zxvf pcre-*
cd pcre-*
./configure --prefix=/home/`whoami`/local/pcre
make && make install
```
解压缩apache，然后解压缩apr和apr-util并拷贝到httpd的srclib文件夹

```shell
$ ll srclib/
total 32
drwxr-xr-x 28 zhuyin zhuyin 4096 Nov  4 10:54 apr
drwxr-xr-x 20 zhuyin zhuyin 4096 Nov  4 10:54 apr-util
-rw-rw-r--  1 zhuyin zhuyin  397 Nov  4 10:53 Makefile
-rw-r--r--  1 zhuyin zhuyin  121 Feb 11  2005 Makefile.in
```

之后对apache进行编译安装

```shell
make clean
./configure --with-layout=Apache --prefix=/home/`whoami`/local/apache --with-port=8001 --with-mpm=prefork --enable-modules=most --enable-module=so --enable-module=rewrite -with-included-apr --with-pcre=/home/`whoami`/local/pcre
make && make install
```

### 说明

- 在使用./configure 编译的时候，如果不指定某个模块为动态，即没有使用：enable-mods-shared=module或者enable-module=shared 这2个中的一个，那么所有的默认模块为静态。那么何谓静态？其实就是编译的时候所有的模块自己编译进 httpd 这个文件中（我们启动可以使用这个执行文件,如： ./httpd & ），启动的时候这些模块就已经加载进来了，也就是可以使用了， 通常为：`<ifmodule> </ifmodule>` 来配置。所以大家看到的配置都是 `<ifmodule  module.c>`  ，很显然，module.c这个东西已经存在 httpd这个文件中了。
- --with-layout 指定在编译 Apache 之后放置各个部分的位置。通过使用布局，可以在编译之前定义所有位置。布局是在 Apache 源代码根目录中的 config.layout 文件中定义的
- --enable-modules=most将一些不常用的，不在缺省常用模块中的模块编译进来.
- --enable-module 启用一个在默认情况下没有打开的模块，-disable-module 的作用正好相反。
- --enable-so  启动模块动态装卸载
- --enable-ssl 编译ssl模块
- --with-zlib  支持数据包压缩
- --with-pcre  支持正则表达式
- --enable-mpms-shared=all   以共享方式编译的模块
- --with-mpm=(worker|prefork|event) 指明httpd的工作
- --enable-cgi 支持cgi机制（能够让静态web服务器能够解析动态请求的一个协议）
- --enable-mime-magic
- –enable-mods-shared=most选项：告诉编译器将所有标准模块都动态编译为DSO模块。
- –enable-rewrite选项：支持地址重写功能，使用1.3版本的朋友请将它改为–enable-module=rewrite
- --with-mpm=worker

# 参考

- [Apache的静态编译与动态编译详解](http://www.ha97.com/2612.html)
- [httpd配置文件详解（上）](http://princepar.blog.51cto.com/1448665/1665008)
- [模块索引](http://httpd.apache.org/docs/current/mod/index.html)
- https://wiki.mikejung.biz/Apache
