# reviewboard部署

## 基本流程

- 安装apache
- 安装及配置mysql
- 安装python
- 安装setuptools
- 安装pip
- 安装mysql驱动 `pip install MySQL-python`
- 安装mod_wsgi
- 安装ReviewBoard `pip install ReviewBoard`
- 安装memcached
- 部署网站 `rb-site install  /home/zhuyin/www/reviewboard`

## 安装apache

## 安装及配置mysql

创建reviewboard存放数据的数据库reviewboard并赋予权限和密码

```
vim /etc/my.cnf
[client]
default-character-set=utf8
[mysqld]
character-set-server=utf8

ln -s /usr/local/mysql/lib/libmysqlclient.so.18 /usr/lib/libmysqlclient.so.18
ln -s /usr/local/mysql/lib/libmysqlclient.so.18 /usr/lib64/libmysqlclient.so.18
ln -s /usr/local/mysql/bin/* /usr/local/bin/

mysql -uroot -p
     create database reviewboard default charset utf8 collate utf8_general_ci;
     grant all on reviewboard.* to 'reviewboard'@'%' identified by 'reviewboard';
     FLUSH PRIVILEGES;
```



## 安装python

### 安装基础组件

```
yum install gcc zlib zlib-devel openssl-devel
```
### 下载

```sh
version=2.7.13
wget https://www.python.org/ftp/python/$version/Python-$version.tgz --no-check-certificate
```
### 编译安装
```shell
username=`whoami`
mkdir ~/local
./configure --prefix=/home/${username}/local/python
make
make install
```
### 配置环境变量
```shell
echo -e 'export PYTHON_HOME=$HOME/local/python\nexport PATH=${PYTHON_HOME}/bin:$PATH' >> ~/.bash_profile && source ~/.bash_profile
```
### 常见问题

`easy_install ReviewBoard`报错

> relocation R_X86_64_32 against `.rodata.str1.8' can not be used when making a shared object;

因此，需使用`CFLAGS="-fPIC"`配置编译选项安装python。
`CFLAGS="-fPIC" ./configure --prefix=/home/${username}/local/python `

## 安装setuptools
https://pypi.python.org/pypi/setuptools

```sh
wget https://pypi.python.org/packages/source/s/setuptools/setuptools-7.0.tar.gz --no-check-certificate
tar zxvf setuptools-7.0.tar.gz
cd setuptools-7.0
python setup.py build
python setup.py install
```
## 安装pip

```sh
easy install pip
```

## 安装mysql驱动 

`pip install MySQL-python`

## 安装memcached

下载最新的memcached程序到本地

```sh
version=1.4.39
wget http://www.memcached.org/files/memcached-$version.tar.gz
```

完成后，解压并准备编译安装。

```
./configure --prefix=/home/`whoami`/local/memcached/
make && make install
```
指定监听端口，启动memcached实例：

```shell
nohup bin/memcached -m 2048 -c 8192 -p 21211 >/dev/null 2>> logs/memcached21211.log &
```
## 安装mod_wsgi

### 安装基础组件

```sh
yum install -y libffi-devel
```

### 编译安装

```sh
wget https://pypi.python.org/packages/c8/d5/c2dc3bab16cc6cf56b7545819be4bc8b647d2a9d2f701fdf38e0c4574b20/mod_wsgi-4.5.17.tar.gz
tar xvf mod_wsgi-4*
cd mod_wsgi-4*
./configure --with-apxs=/home/`whoami`/local/apache/bin/apxs
pip install mod_wsgi
```

### 常见问题

> 1, error: ‘FFI_DEFAULT_ABI’ undeclared
> https://stackoverflow.com/questions/23722678/command-gcc-failed-with-exit-status-1-error-while-installing-scrapy

```sh
yum install -y libffi-devel
```

> 2, error: [SSL: DECRYPTION_FAILED_OR_BAD_RECORD_MAC] decryption failed or bad record mac (_ssl.c:1864)

多试几次。

## 创建站点

创建站点资源，配置

- domain name
- domain path
- database type
- database connection string
- memcached connection string
- administrator account

```sh
rb-site install  /home/zhuyin/www/reviewboard #ReviewBoard-1.7.* 系列的版本需要加上参数 –console 
```

```
➜  ~ rb-site install  /home/zhuyin/www/reviewboard
* Welcome to the Review Board site installation wizard
    This will prepare a Review Board site installation in:
    /home/zhuyin/www/reviewboard
    We need to know a few things before we can prepare your site for
    installation. This will only take a few minutes.
* What's the host name for this site?
    This should be the fully-qualified host name without the http://,
    port or path.
Domain Name: 223.105.1.80
Root Path [/]: reviewboard

* What database type will you be using?
    You can type either the name or the number from the list below.
    (1) mysql
    (2) sqlite3 (not supported for production use)
Database Type: 1
Database Name [reviewboard]:
Database Server [localhost]: 127.0.0.1
Database Username: reviewboard
Database Password:reviewboard
Confirm Database Password:reviewboard
Memcache Server [localhost:11211]: localhost:21211

* Create an administrator account

    To configure Review Board, you'll need an administrator account.
    It is advised to have one administrator and then use that account
    to grant administrator permissions to your personal user account.

    If you plan to use NIS or LDAP, use an account name other than
    your NIS/LDAP account so as to prevent conflicts.

    The default is admin

Username [admin]: admin
Password: admin20170712
Confirm Password: admin20170712
E-Mail Address: zhuyin@chinamobile.com
Company/Organization Name (optional): cmri
Allow us to collect support data? [Y/n]: y

* Installing the site...
Building site directories ... OK
Building site configuration files ... OK
Creating database ... Creating tables ...
Installing custom SQL ...
Installing indexes ...
Installed 0 object(s) from 0 fixture(s)
OK
Performing migrations ... No evolution required.
OK
Creating administrator account ... OK
Saving site settings ... Saving site /home/zhuyin/www/reviewboard to the sitelist /etc/reviewboard/sites

OK

Setting up support ... OK


* The site has been installed

    The site has been installed in /home/zhuyin/www/reviewboard

    Sample configuration files for web servers and cron are available
    in the conf/ directory.

    You need to modify the ownership of the following directories and
    their contents to be owned by the web server:
        * /home/zhuyin/www/reviewboard/htdocs/media/uploaded
        * /home/zhuyin/www/reviewboard/htdocs/media/ext
        * /home/zhuyin/www/reviewboard/htdocs/static/ext
        * /home/zhuyin/www/reviewboard/data

    For more information, visit:

    https://www.reviewboard.org/docs/manual/2.5/admin/installation/creating-sites/


* Get more out of Review Board

    To enable PDF document review, enhanced scalability, GitHub
    Enterprise support, and more, download Power Pack at:

    https://www.reviewboard.org/powerpack/

    Your install key for Power Pack is:
    d48c89d801690e3cf65f51a96412c6b3d7ac68ce

    Support contracts for Review Board are also available:

    https://www.beanbaginc.com/support/contracts/
```

## 配置apache

将生成的reviewboard的apache配置文件拷贝到apache的extra文件夹。

```sh
cp www/reviewboard/conf/apache-wsgi.conf local/apache/conf/extra
```

配置`extra/apache-wsgi.conf`文件中的apache端口，该文件中内容如下：

```xml
<VirtualHost *:21889>
        ServerName 223.105.1.80
        DocumentRoot "/home/zhuyin/www/reviewboard/htdocs"

        # Error handlers
        ErrorDocument 500 /errordocs/500.html

        WSGIPassAuthorization On
        WSGIScriptAlias "/reviewboard" "/home/zhuyin/www/reviewboard/htdocs/reviewboard.wsgi/reviewboard"

        <Directory "/home/zhuyin/www/reviewboard/htdocs">
                AllowOverride All
                Options -Indexes +FollowSymLinks
                Require all granted
        </Directory>

        # Prevent the server from processing or allowing the rendering of
        # certain file types.
        <Location "/reviewboard/media/uploaded">
                SetHandler None
                Options None

                AddType text/plain .html .htm .shtml .php .php3 .php4 .php5 .phps .asp
                AddType text/plain .pl .py .fcgi .cgi .phtml .phtm .pht .jsp .sh .rb

                <IfModule mod_php5.c>
                        php_flag engine off
                </IfModule>
        </Location>

        # Alias static media requests to filesystem
        Alias /reviewboard/media "/home/zhuyin/www/reviewboard/htdocs/media"
        Alias /reviewboard/static "/home/zhuyin/www/reviewboard/htdocs/static"
        Alias /reviewboard/errordocs "/home/zhuyin/www/reviewboard/htdocs/errordocs"
        Alias /reviewboard/favicon.ico "/home/zhuyin/www/reviewboard/htdocs/static/rb/images/favicon.png"
</VirtualHost>
```

配置`httpd.conf`

```xml
LoadModule wsgi_module modules/mod_wsgi.so
Include conf/extra/apache-wsgi.conf

User zhuyin
Group zhuyin
ServerName localhost
```

## 页面访问

http://223.105.1.80:21889/reviewboard/account/login/

## 升级站点

访问`http://223.105.1.80:21889/reviewboard/account/login/`时报错。

> The version of Review Board running does not match the version the site was last upgraded to. You are running 2.5.13.1 and the site was last upgraded to 1.7.27.
>
> Please upgrade your site to fix this by running:
> `$ rb-site upgrade /home/zhuyin/www/reviewboard`
> Then restart the web server.

为此，升级站点，ok