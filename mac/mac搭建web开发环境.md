# web

## brew

This process relies heavily on the macOS package manager called **Homebrew**. Using the `brew` command you can easily add powerful functionality to your mac, but first we have to install it. This

```shell
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

Just follow the terminal prompts and enter your password where required. This will install Homebrew and also install the required **XCode Command Line Tools** if you don't already have XCode installed. This may take a few minutes, but when complete, a quick way to ensure you have installed `brew` correctly, simply type:

```shell
$ brew --version
Homebrew 1.0.6
Homebrew/homebrew-core (git revision 1b10; last commit 2016-10-04)
```

You should probably also run the following command to ensure everything is configured correctly:

```shell
$ brew doctor
```

It will instruct you if you need to correct anything.



We are going to use some brews that require some external **taps**:

```shell
$ brew tap homebrew/dupes
$ brew tap homebrew/versions
$ brew tap homebrew/php
$ brew tap homebrew/apache
```

If you already have brew installed, make sure you have the all the latest available brews:

```shell
$ brew update
```

Now you are ready to brew!

## apache

### 安装

The latest **macOS 10.12 Sierra** comes with Apache 2.4 pre-installed, however, it is no longer a simple task to use this version with Homebrew because Apple has removed some required scripts in this release. However, the solution is to install Apache 2.4 via Homebrew and then configure it to run on the standard ports (80/443).

```shell
$ sudo apachectl stop
$ sudo launchctl unload -w /System/Library/LaunchDaemons/org.apache.httpd.plist 2>/dev/null
$ brew install httpd24 --with-privileged-ports --with-http2
```

在安装的最后会看到

```
To have launchd start homebrew/apache/httpd24 now and restart at startup:
  sudo brew services start homebrew/apache/httpd24
Or, if you don't want/need a background service you can just run:
  apachectl start
==> Summary
🍺  /usr/local/Cellar/httpd24/2.4.25: 214 files, 4.5MB, built in 3 minutes 4 seconds
```

This is important because you will need that path in the next step.

```shell
sudo cp -v /usr/local/Cellar/httpd24/2.4.25/homebrew.mxcl.httpd24.plist /Library/LaunchDaemons
sudo chown -v root:wheel /Library/LaunchDaemons/homebrew.mxcl.httpd24.plist
sudo chmod -v 644 /Library/LaunchDaemons/homebrew.mxcl.httpd24.plist
sudo launchctl load /Library/LaunchDaemons/homebrew.mxcl.httpd24.plist
```

You now have installed Homebrew's Apache, and configured it to auto-start with a privileged account. It should already be running, so you can try to reach your server in a browser by pointing it at your localhost, you should see a simple header that says **"It works!"**.

启动：`sudo apachectl start`

重启：`sudo apachectl -k restart`

日志文件：`/usr/local/var/log/apache2/error_log`



> **系统自带的apache**
>
> 配置文件： `/etc/apache2/httpd.conf`
>
> 默认 `DocumentRoot "/Library/WebServer/Documents"`
>
> 查看http状态 http://127.0.0.1/server-status
> 若提示找不到，`The requested URL /server-status was not found on this server.`
> 则检查配置文件,确保配置文件mod_status.so被加载，httpd-info.conf被引入。

### 配置

配置文件：`/usr/local/etc/apache2/2.4/httpd.conf`

Search for the term `DocumentRoot`, and you should see the following line:

```
DocumentRoot "/usr/local/var/www/htdocs"
```

### 操作

```sh
sudo /usr/local/opt/httpd24/bin/apachectl -k start
sudo /usr/local/opt/httpd24/bin/apachectl -k stop
```

### 测试

访问 http://127.0.0.1

## php

### 安装

先搜索有哪些php版本。
`brew search php`

We will proceed by installing **PHP 5.3**, **PHP 5.6** and using a simple script to switch between them as we need.

> You can get a full list of available options to include by typing `brew options php55`, for example. In this example we are just including Apache support via `--with-httpd24` to build the required PHP modules for Apache.

```
$ brew install php53 --with-httpd24
$ brew unlink php53
$ brew install php56 --with-httpd24
$ brew unlink php56
```

This may take some time as your computer is actually compiling PHP from source.

> You must **reinstall** each PHP version with `reinstall` command rather than `install` if you have previously installed PHP through Brew.

Also, you may have the need to tweak configuration settings of PHP to your needs. A common thing to change is the memory setting, or the `date.timezone` configuration. The `php.ini` files for each version of PHP are located in the following directories:

```
/usr/local/etc/php/5.3/php.ini
/usr/local/etc/php/5.6/php.ini
```

### 配置

You have successfully installed your PHP versions, but we need to tell Apache to use them. You will again need to edit the `/usr/local/etc/apache2/2.4/httpd.conf` file and search for `#LoadModule php5_module`.

```shell
LoadModule php5_module        /usr/local/Cellar/php55/5.5.38_11/libexec/apache2/libphp5.so
LoadModule php5_module        /usr/local/Cellar/php56/5.6.26_3/libexec/apache2/libphp5.so
LoadModule php7_module        /usr/local/Cellar/php70/7.0.11_5/libexec/apache2/libphp7.so
LoadModule php7_module        /usr/local/Cellar/php71/7.1.0-rc.3_8/libexec/apache2/libphp7.so
```

Modify the paths as follows:

```shell
LoadModule php5_module    /usr/local/opt/php55/libexec/apache2/libphp5.so
LoadModule php5_module    /usr/local/opt/php56/libexec/apache2/libphp5.so
LoadModule php7_module    /usr/local/opt/php70/libexec/apache2/libphp7.so
LoadModule php7_module    /usr/local/opt/php71/libexec/apache2/libphp7.so
```

We can only have one module processing PHP at a time, so for now, comment out all but the `php56` entry:

```shell
#LoadModule php5_module    /usr/local/opt/php55/libexec/apache2/libphp5.so
LoadModule php5_module    /usr/local/opt/php56/libexec/apache2/libphp5.so
#LoadModule php7_module    /usr/local/opt/php70/libexec/apache2/libphp7.so
#LoadModule php7_module    /usr/local/opt/php71/libexec/apache2/libphp7.so
```

This will tell Apache to use PHP 5.6 to handle PHP requests.

Also you must set the Directory Indexes for PHP explicitly, so search for this block:

```
<IfModule dir_module>
    DirectoryIndex index.html
</IfModule>
```

and replace it with this:

```
<IfModule dir_module>
    DirectoryIndex index.php index.html
</IfModule>
```

在配置文件末尾追加，否则无法正常

```
<IfModule php7_module>
  AddType application/x-httpd-PHP .PHP
  AddType application/x-httpd-PHP-source .phps
  <FilesMatch \.php$>
      SetHandler application/x-httpd-php
  </FilesMatch>
</IfModule>
```

站点配置示例

```shell
Listen 80
NameVirtualHost *:80
<VirtualHost *:80>
  DocumentRoot "/home/work/www/newadm"
  ServerName admonitor.cm-analysis.com
  KeepAlive On
  RewriteEngine on
  CustomLog "|/home/work/local/apache/bin/rotatelogs -l /home/work/local/apache/logs/%Y%m%d%H-admonitor.log 3600" combined
  ErrorLog "|/home/work/local/apache/bin/rotatelogs -l /home/work/local/apache/logs/%Y%m%d-admonitor-error.log 86400"
  ServerSignature Off
  SetEnv APPLICATION_ENV "production"

  <Directory "/home/work/www/newadm">
      Options FollowSymLinks Indexes MultiViews
      AllowOverride All
      Order allow,deny
      Allow from all
  </Directory>
</VirtualHost>
```

或者在httpd-vhosts.conf中配置，并在httpd.conf中include.

```
Include /usr/local/etc/apache2/2.4/extra/httpd-vhosts.conf
```

```xml
Listen 8001
<VirtualHost *:8001>
  DocumentRoot "/usr/local/var/www/htdocs/test"
  ServerName localhost
  KeepAlive On
  RewriteEngine on
  ServerSignature Off
  SetEnv APPLICATION_ENV "production"

  <Directory "/usr/local/var/www/htdocs/test">
      Options FollowSymLinks Indexes MultiViews
      AllowOverride All
      Order allow,deny
      Allow from all
      Require all granted
  </Directory>
</VirtualHost>
```

说明，若要实现rewite，需要：
1，apache配置文件中加载

```
LoadModule rewrite_module libexec/mod_rewrite.so
```
2，站点配置开启`AllowOverride`
3，站点项目中创建`.htaccess`，内容示例

```
<IfModule mod_rewrite.c>
  Options +FollowSymlinks
  RewriteEngine On

  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteRule ^(.*)$ index.php/$1 [QSA,PT,L]
</IfModule>
```

配置启动用户

```shell
#
# If you wish httpd to run as a different user or group, you must run
# httpd as root initially and it will switch.
#
# User/Group: The name (or #number) of the user/group to run httpd as.
# It is usually good practice to create a dedicated user and group for
# running httpd, as with most system services.
#
User chookin
Group staff
```

**Save** the file and **restart Apache again**, now that we have installed PHP:

```shell
$ sudo apachectl -k restart
```

### 测试

写测试文件test.php，放到apache的DocumentRoot路径下。

```php
# test.php
<?php
phpinfo();
?>
```
在浏览器地址栏中输入http://localhost/test.php，正常情况下，页面中出现php的版本信息。

若不能，则是apache没有正常加载php，则检查php模块的加载。例如对于php5是

```
LoadModule php5_module libexec/apache2/libphp5.so
```

### 常见问题

## memcached

```
brew install homebrew/php/php53-memcached
php -i "(command-line 'phpinfo()')" | grep mem
```

## redis

```
brew install homebrew/php/php53-redis

redis: stable 4.0.0 (bottled), HEAD
Persistent key-value database, with built-in net interface
https://redis.io/
/usr/local/Cellar/redis/3.2.9 (13 files, 1.7MB)
  Poured from bottle on 2017-05-31 at 18:12:24
/usr/local/Cellar/redis/4.0.0 (13 files, 2.8MB) *
  Poured from bottle on 2017-07-24 at 09:44:57
From: https://github.com/Homebrew/homebrew-core/blob/master/Formula/redis.rb
==> Options
--with-jemalloc
	Select jemalloc as memory allocator when building Redis
--HEAD
	Install HEAD version
==> Caveats
To have launchd start redis now and restart at login:
  brew services start redis
Or, if you don't want/need a background service you can just run:
  redis-server /usr/local/etc/redis.conf
```

## xdebug

```
$ brew install php53-xdebug
==> Installing php53-xdebug from homebrew/php
==> Downloading http://xdebug.org/files/xdebug-2.2.7.tgz
==> Downloading from https://xdebug.org/files/xdebug-2.2.7.tgz
######################################################################## 100.0%
==> /usr/local/opt/php53/bin/phpize
==> ./configure --prefix=/usr/local/Cellar/php53-xdebug/2.2.7 --with-php-config=/usr/local/opt/php53/bin/php-config --enable-xdebug
==> make
==> Caveats
To finish installing xdebug for PHP 5.3:
  * /usr/local/etc/php/5.3/conf.d/ext-xdebug.ini was created,
    do not forget to remove it upon extension removal.
  * Validate installation via one of the following methods:
  *
  * Using PHP from a webserver:
  * - Restart your webserver.
  * - Write a PHP page that calls "phpinfo();"
  * - Load it in a browser and look for the info on the xdebug module.
  * - If you see it, you have been successful!
  *
  * Using PHP from the command line:
  * - Run `php -i "(command-line 'phpinfo()')"`
  * - Look for the info on the xdebug module.
  * - If you see it, you have been successful!
==> Summary
🍺  /usr/local/Cellar/php53-xdebug/2.2.7: 3 files, 175.4KB, built in 26 seconds
```

`vi /usr/local/etc/php/5.3/conf.d/ext-xdebug.ini`

```ini
[Xdebug]
zend_extension_ts ="/usr/local/opt/php53-xdebug/xdebug.so"
zend_extension="/usr/local/opt/php53-xdebug/xdebug.so"
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
xdebug.remote_host=localhost/127.0.0.1
xdebug.remote_port=9000
xdebug.remote_handler=dbgp
xdebug.idekey="PHPSTORM"
```

## phpstorm

采用phpstorm开发php web程序。

### IDE配置

- Preferences | Languages & Frameworks | PHP
  - 配置`PHP language level`
  - 配置`Interpreter`。
    - 若需新建解释器，则进一步配置php executable路径，如`/usr/local/Cellar/php53/5.3.29_7/bin/php`；
- Preferences | Languages & Frameworks | PHP | Debug
  - 核查Xdebug的Debug port与xdebug配置文件中`remote_port`的一致，默认9000。
- Preferences | Languages & Frameworks | PHP | Debug | DBGpProxy
  - 配置IDE key 与xdebug配置文件中的`idekey`一致
  - 配置Host为localhost
  - 配置Port ，默认9001
- Preferences | Languages & Frameworks | PHP | Servers
  - 若不存在，新建一个，配置Host为`localhosthost`，Port为80，Debugger选`Xdebug`，不用勾选`Use path mappings`

### 项目调试

配置软链接，映射项目根路径到apache document root。

配置Run/Debug Configuations，新建`PHP Web Application`

- 选择可用的Server
- 配置Start URL，默认`/`
- 配置浏览器为`Chrome`。

点击电话图片使其变为绿色，Start Listening for PHP Debug Connections.

点击爬虫图标，则开始调试，可在php 脚本中插入断点进行跟踪调试。

## phpmyadmin

### 安装

phpmyadmin要求php5.5+，因此选择安装phpmyadmin3.

```
chookin:opdir chookin$ brew install phpmyadmin3
```

之后，配置apache，添加如下内容到配置文件的末尾处。

```shell
  Alias /phpmyadmin3 /usr/local/share/phpmyadmin3
  <Directory /usr/local/share/phpmyadmin3/>
    Options Indexes FollowSymLinks MultiViews
    AllowOverride All
    <IfModule mod_authz_core.c>
      Require all granted
    </IfModule>
    <IfModule !mod_authz_core.c>
      Order allow,deny
      Allow from all
    </IfModule>
  </Directory>
```

修改httpd.conf，找到`#LoadModule php5_module libexec/apache2/libphp5.so`，把前面的#号去掉，以使得apache能处理php页面。

### 配置

`/usr/local/etc/phpmyadmin3.config.inc.php`

文档 http://localhost/phpmyadmin3/Documentation.html

```
/* Authentication type */
# 配置phpmyadmin web页面的登录机制，若是cookie，则新的登录需要输入用户名和密码
#$cfg['Servers'][$i]['auth_type'] = 'cookie';
$cfg['Servers'][$i]['auth_type'] = 'config';

/* Server parameters */
# 配置数据库的地址及连接信息
# $cfg['Servers'][$i]['host'] = 'localhost';
$cfg['Servers'][$i]['host'] = '127.0.0.1';
$cfg['Servers'][$i]['port'] = '23306';
#$cfg['Servers'][$i]['socket'] = '/Users/chookin/data/mysql/var/mysqld.sock';
$cfg['Servers'][$i]['connect_type'] = 'tcp';
$cfg['Servers'][$i]['compress'] = false;
/* Select mysql if your server does not have mysqli */
$cfg['Servers'][$i]['extension'] = 'mysqli';
$cfg['Servers'][$i]['AllowNoPassword'] = false;

$cfg['Servers'][$i]['user'] = 'root';
$cfg['Servers'][$i]['password'] = 'root';
```

### 测试

http://localhost/phpmyadmin3

### 常见问题

1. ` #2002 Cannot log in to the MySQL server`

> In config.inc.php change localhost to 127.0.0.1 for `$cfg['Servers'][$i]['host'] key`.

## PhantomJS

[PhantomJS](http://phantomjs.org/download.html) is a headless WebKit scriptable with a JavaScript API. It has fast and native support for various web standards: DOM handling, CSS selector, JSON, Canvas, and SVG.

下载解压缩，配置到PATH路径中即可。
https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-macosx.zip

## CasperJS

[CasperJS](http://casperjs.org/) is an open source navigation scripting & testing utility written in Javascript for the PhantomJS WebKit headless browser and SlimerJS (Gecko). It eases the process of defining a full navigation scenario and provides useful high-level functions, methods & syntactic sugar for doing common tasks such as:

- defining & ordering browsing navigation steps
- filling & submitting forms
- clicking & following links
- capturing screenshots of a page (or part of it)
- testing remote DOM
- logging events
- downloading resources, including binary ones
- writing functional test suites, saving results as JUnit XML
- scraping Web contents

Prerequisites

- PhantomJS 1.9.1 or greater. Please read the installation instructions for PhantomJS
- Python 2.6 or greater for casperjs in the bin/ directory

下载解压缩，配置到PATH路径中即可。

测试安装

    phantomjs --version
    casperjs
如果执行‘casperjs'命令时报错

```
Couldn't find nor compute phantom.casperPath, exiting.
```
问题原因是phantomjs2更改了casperjs所调用的接口.[http://qnalist.com/questions/5858081/casperjs-phantomjs-2-released-but-it-breaks-casperjs](http://qnalist.com/questions/5858081/casperjs-phantomjs-2-released-but-it-breaks-casperjs)

To resolve this error , you need to insert following lines in bootsrap.js in your bin directory of casperjs .[how-to-install-casperjs-on-windows](http://www.javaroots.com/2015/03/how-to-install-casperjs-on-windows.html)

```javascript
var system = require('system');
var argsdeprecated = system.args;
argsdeprecated.shift();
phantom.args = argsdeprecated;
```

Now , try to run again , and you will not see this error .


## Node.js
[Node.js](https://nodejs.org/en/) is a JavaScript runtime built on Chrome's V8 JavaScript engine. Node.js uses an event-driven, non-blocking I/O model that makes it lightweight and efficient. Node.js' package ecosystem, npm, is the largest ecosystem of open source libraries in the world.

从Node.js官网下载安装包，下载之后点击安装即可。安装成功后，会提示：

```
Node.js was installed at

   /usr/local/bin/node

npm was installed at

   /usr/local/bin/npm

Make sure that /usr/local/bin is in your $PATH.
```

# 参考

- [macOS 10.12 Sierra Apache Setup: Multiple PHP Versions](https://getgrav.org/blog/macos-sierra-apache-multiple-php-versions)
