# php7

## 安装php

```sh
yum -y install gcc gcc-c++ cmake libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel pcre-devel libmcrypt libmcrypt-devel libxslt-devel

version=7.1.6
wget http://cn2.php.net/distributions/php-$version.tar.xz
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
zend_extension="/home/zhuyin/local/php-7.1.6/lib/php/extensions/no-debug-zts-20160303/opcache.so"
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
# 需要先安装libevent
wget https://launchpad.net/libmemcached/1.0/1.0.18/+download/libmemcached-1.0.18.tar.gz
tar xvf libmemcached-1.0.18.tar.gz
cd libmemcached-1.0.18
./configure --prefix=$HOME/local/libmemcached
make && make install

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

## 测试

写测试文件test.php，放到apache的DocumentRoot路径下。

```php
# test.php
<?php
phpinfo();
?>
```
在浏览器地址栏中输入http://localhost/test.php，正常情况下，页面中出现php的版本信息。

# 参考

- [Linux环境安装PHP7](http://blog.csdn.net/u013474436/article/details/52838496)
- [PHP 7安装使用体验，升级PHP要谨慎](http://www.phpxs.com/j/php7/1001234/)
