# php7

## 前言
[What is no-debug-non-zts-20090626?](https://stackoverflow.com/questions/14414551/what-is-no-debug-non-zts-20090626)

> It's an extension directory for PHP, named after some factors that influence extension compatibility: thread safety (non-zts), debug (no-debug), and engine version (20090626).

Different web servers implement different techniques for handling incoming HTTP requests in parallel. A pretty popular technique is using threads -- that is, the web server will create/dedicate a single thread for each incoming request. The Apache HTTP web server supports multiple models for handling requests, one of which (called the worker MPM) uses threads. But it supports another concurrency model called the prefork MPM which uses processes -- that is, the web server will create/dedicate a single process for each request.

Since with mod_php, PHP gets loaded right into Apache, if Apache is going to handle concurrency using its Worker MPM (that is, using Threads) then PHP must be able to operate within this same multi-threaded environment -- meaning, PHP has to be thread-safe to be able to play ball correctly with Apache!

In case you are wondering, my personal advice would be to not use PHP in a multi-threaded environment if you have the choice!

Speaking only of Unix-based environments, I'd say that fortunately, you only have to think of this if you are going to use PHP with Apache web server, in which case you are advised to go with the prefork MPM of Apache (which doesn't use threads, and therefore, PHP thread-safety doesn't matter)

## 安装php

```sh
yum -y install gcc gcc-c++ cmake libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel pcre-devel libmcrypt libmcrypt-devel libxslt-devel libcurl-devel

version=7.1.8
wget http://cn2.php.net/distributions/php-$version.tar.xz
tar xvf php-$version.tar.xz
cd php-$version
TARGET_PATH=/home/`whoami`/local/php-$version
./configure --prefix=$TARGET_PATH  \
 --with-apxs2=/home/`whoami`/local/apache/bin/apxs \
 --with-curl \
 --with-mcrypt \
 --with-jpeg-dir \
 --with-zlib-dir \
 --with-freetype-dir \
 --with-gd \
 --with-gettext \
 --with-iconv-dir \
 --with-kerberos \
 --with-libdir=lib64 \
 --with-libxml-dir \
 --with-mysqli \
 --with-openssl \
 --with-pcre-regex \
 --with-pdo-mysql \
 --with-pdo-sqlite \
 --with-pear \
 --with-png-dir \
 --with-xmlrpc \
 --with-xsl \
 --with-zlib \
 --enable-fpm \
 --enable-bcmath \
 --enable-ftp \
 --enable-libxml \
 --enable-inline-optimization \
 --enable-gd-native-ttf \
 --enable-mbregex \
 --enable-mbstring \
 --enable-opcache \
 --enable-pcntl \
 --enable-shmop \
 --enable-soap \
 --enable-sockets \
 --enable-sysvsem \
 --enable-wddx \
 --enable-xml \
 --enable-zip
make && make install
ln -fsv /home/`whoami`/local/php-$version /home/`whoami`/local/php
```

## 配置

### apache

```sh
LoadModule php7_module        modules/libphp7.so
<IfModule php7_module>
  AddType application/x-httpd-PHP .PHP
  AddType application/x-httpd-PHP-source .phps
  <FilesMatch \.php$>
      SetHandler application/x-httpd-php
  </FilesMatch>
</IfModule>
<IfModule dir_module>
    DirectoryIndex index.php index.html
</IfModule>
```

### php

配置文件`lib/php.ini`.

启用opcache. 参考http://www.php.net/manual/zh/opcache.configuration.php

```ini
[Zend]
zend_extension="/home/zhuyin/local/php/lib/php/extensions/no-debug-zts-20160303/opcache.so"
opcache.enable=1
opcache.enable_cli=1
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.fast_shutdown=1
opcache.enable_file_override=0
opcache.force_restart_timeout=180
opcache.validate_timestamps=1
opcache.revalidate_freq=60
```

## 安装扩展

扩展
https://github.com/gophp7/gophp7-ext/wiki/extensions-catalog
http://curl.haxx.se/
https://pecl.php.net/package/memcache
https://pecl.php.net/package/redis
https://pecl.php.net/package/xdebug

### memcached

注意`https://pecl.php.net/get/memcache-2.2.7.tgz`是2013年发布的，不支持php7。因此，选择从github获取支持php7的。

#### 编译安装

```sh
# 需要先安装libmemcached
wget https://launchpad.net/libmemcached/1.0/1.0.18/+download/libmemcached-1.0.18.tar.gz
tar xvf libmemcached-1.0.18.tar.gz
cd libmemcached-1.0.18
./configure --prefix=$HOME/local/libmemcached
make && make install

# wget https://pecl.php.net/get/memcached-3.0.3.tgz
git clone -b php7  https://github.com/php-memcached-dev/php-memcached.git --depth=1
cd php-memcached
phpize
./configure --disable-memcached-sasl --with-libmemcached-dir=$HOME/local/libmemcached --with-php-config=$HOME/local/php/bin/php-config
make && make install
# Installing shared extensions:     /home/zhuyin/local/php-7.1.6/lib/php/extensions/no-debug-zts-20160303/
```

#### 配置

```ini
[PHP]
; ...
; Directory in which the loadable extensions (modules) reside.
extension_dir = "/home/zhuyin/local/php/lib/php/extensions/no-debug-zts-20160303/"
extension=memcached.so
```
### xdebug

https://pecl.php.net/get/xdebug-2.5.5.tgz

```ini
[Xdebug]
zend_extension_ts ="/home/zhuyin/local/php-7.1.6/lib/php/extensions/no-debug-zts-20160303/xdebug.so"
zend_extension="/home/zhuyin/local/php-7.1.6/lib/php/extensions/no-debug-zts-20160303/xdebug.so"
xdebug.auto_trace = on 
xdebug.auto_profile = on
xdebug.collect_params = on 
xdebug.collect_return = on 
xdebug.profiler_enable = on 
xdebug.trace_output_dir = "/tmp" 
xdebug.profiler_output_dir = "/tmp"
xdebug.remote_log="/tmp/xdebug.log"
xdebug.dump.GET = * 
xdebug.dump.POST = * 
xdebug.dump.COOKIE = * 
xdebug.dump.SESSION = * 
xdebug.var_display_max_data = 4056 
xdebug.var_display_max_depth = 5
xdebug.remote_autostart=on
xdebug.remote_enable=true
;xdebug.remote_host=localhost/127.0.0.1
;xdebug.remote_port=9000
xdebug.remote_handler=dbgp
xdebug.idekey="PHPSTORM"
```

### redis
#### 编译安装
```sh
# https://pecl.php.net/package/redis
wget https://pecl.php.net/get/redis-3.1.3.tgz
tar xvf redis-3.1.3.tgz
cd redis-3.1.3
phpize
./configure
make && make install
# Installing shared extensions:     /home/zhuyin/local/php-7.1.7/lib/php/extensions/no-debug-zts-20160303/
```

#### 配置
```ini
; Directory in which the loadable extensions (modules) reside.
extension_dir = "/home/zhuyin/local/php/lib/php/extensions/no-debug-zts-20160303/"
extension=redis.so
```

#### 校验安装

```
➜  redis-3.1.3 php -i "(command-line 'phpinfo()')" | grep Redis
Redis Support => enabled
Redis Version => 3.1.3
```

## 测试

写测试文件info.php，放到apache的DocumentRoot路径下。

```php
// info.php
<?php
phpinfo();
?>
```
在浏览器地址栏中输入http://localhost/info.php，正常情况下，页面中出现php的版本信息。

测试数据库连接

```php
// test.php
<?php
echo "php version=";
echo phpversion();

echo "<br>";
echo "mysqli connect:";
$link=mysqli_connect('mysqlmaster','root','root','admonitor','23306');
if(!$link) echo '<p>failed.</p>';
else echo '<p>successed.</p>';
mysqli_close($link);

echo "mysql-pdo connect:";
$pdo = new PDO("mysql:host=mysqlmaster;dbname=admonitor",'root','root');
$pdo->exec("set names 'utf8'");
$sql = "select * from userinfo where uid = ?";
$stmt = $pdo->prepare($sql);
$stmt->bindValue(1, '1', PDO::PARAM_STR);
$rs = $stmt->execute();
if ($rs) {
    // PDO::FETCH_ASSOC 关联数组形式
    // PDO::FETCH_NUM 数字索引数组形式
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        var_dump($row);
    }
}
$pdo = null;//关闭连接
?>
```

# 常见问题

1，Autoconf version 2.59 or higher is required for this script

```
➜  redis-3.1.3 phpize
Configuring for:
PHP Api Version:         20160303
Zend Module Api No:      20160303
Zend Extension Api No:   320160303
Autoconf version 2.59 or higher is required for this script
```

删除旧版本：
`rpm -e --nodeps autoconf`
安装新版本autoconf

```sh
wget http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz
tar -xzf autoconf-2.69.tar.gz
cd autoconf-2.69
./configure
make && make install
```



# 参考

- [Linux环境安装PHP7](http://blog.csdn.net/u013474436/article/details/52838496)
- [PHP 7安装使用体验，升级PHP要谨慎](http://www.phpxs.com/j/php7/1001234/)
