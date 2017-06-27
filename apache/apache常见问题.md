# 常见问题

## 错误日志

apache的错误日志，默认配置是`ErrorLog "logs/error_log"`，但是具体某个监听具有自己的日志文件，例如：

```shell
Listen 80
NameVirtualHost *:80
<VirtualHost *:80>
DocumentRoot "/home/work/www/admonitor/webapp"
ServerName admonitor.cm-analysis.com
KeepAlive On
RewriteEngine on
CustomLog "|/home/work/local/apache/bin/rotatelogs -l /home/work/local/apache/logs/%Y%m%d%H-admonitor.log 3600" combined
ErrorLog "|/home/work/local/apache/bin/rotatelogs -l /home/work/local/apache/logs/%Y%m%d-admonitor-error.log 86400"
ServerSignature Off
SetEnv APPLICATION_ENV "production"

<Directory "/home/work/www/admonitor/webapp">
    Options FollowSymLinks  -Indexes -MultiViews
    AllowOverride All
    Order allow,deny
    Allow from all
</Directory>
</VirtualHost>

<IfModule log_config_module>
    #
    # The following directives define some format nicknames for use with
    # a CustomLog directive (see below).
    #
    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %D" combined
    LogFormat "%h %l %u %t \"%r\" %>s %b" common

    <IfModule logio_module>
      # You need to enable mod_logio.c to use %I and %O
      LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %O %D" combinedio
    </IfModule>

    #
    # The location and format of the access logfile (Common Logfile Format).
    # If you do not define any access logfiles within a <VirtualHost>
    # container, they will be logged here.  Contrariwise, if you *do*
    # define per-<VirtualHost> access logfiles, transactions will be
    # logged therein and *not* in this file.
    #
    CustomLog "logs/access_log" common

    #
    # If you prefer a logfile with access, agent, and referer information
    # (Combined Logfile Format) you can use the following directive.
    #
    #CustomLog "logs/access_log" combined
</IfModule>
```

## 启动报错

>  undefined symbol: apr_array_clear

需要下载apr和apr-utils 并解压到./srclib/，然后在编译时指定` --with-included-apr `

## 启动告警

> AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 192.168.110.107. Set the 'ServerName' directive globally to suppress this message

将 apache 的配置文件httpd.conf中的 ServerName 改成可用域名。

## Options must start with +

apache httpd 2.2的配置放到apache httpd 2.4下就出现了这个错误

> apache httpd Either all Options must start with + or -, or no Option may.

出现错误的行内容为：

```
Options FollowSymLinks  -Indexes -MultiViews
```

解决办法：

修改为：

```
Options +FollowSymLinks  -Indexes -MultiViews
```

## NameVirtualHost

`AH00548: NameVirtualHost has no effect and will be removed in the next release`

去掉 NameVirtualHost 这一行，就行了

## 403 Forbidden

启动报错`HTTP request sent, awaiting response... 403 Forbidden`

查看apache日志

```
AH01630: client denied by server configuration: /home/zhuyin/www/admonitor/webapp/
```

权限问题。请监测默认的网页资源是否放开了读权限。
例如，apache以`Daemon`用户运行，而默认资源文件`index.html`没有放开读权限。

```
-rw-r-----  1 work work    6 May 26 18:16 index.html
```
放开权限，`chmod 644 index.html`
若非该种情况，可能是`Selinux`的问题，或者是apache的权限规则发生了变化。

> The new directive is Require:
>
> 2.2 configuration:
>
> ```
> Order allow,deny
> Allow from all
> ```
>
> 2.4 configuration:
>
> ```shell
> Require all granted
> ```
>
> Also don't forget to restart the apache server after these changes

## No matching DirectoryIndex

apache重启继续报错

```
AH01276: Cannot serve directory /home/zhuyin/www/admonitor/webapp/: No matching DirectoryIndex (index.html) found, and server-generated directory index forbidden by Options directive
```

解决办法，在web文档根路径下创建文件index.html

```shell
echo 'hello' > /home/zhuyin/www/admonitor/webapp/index.html
```

## 忽略文件扩展名

apache的url rewrite规则不能正常工作。访问http://117.136.183.146:21008/sv/77/325/9999，报错”找不到http://117.136.183.146:21008/sv.gif/77/325/9999“，其中，在DocumentRoot下存在`sv.gif`文件。

问题原因：multiviews选项与rewrite规则冲突。 multiviews，允许访问页面时不需要文件的扩展名。

## Invalid command 'Require'

配置出错`Invalid command 'Require', perhaps misspelled or defined by a module not included in the server configuration`

> The Require directive is supplied by mod_authz_core. If the module has not been compiled into your Apache binary, you will need to add an entry to your configuration file to load it manually.
>
> 在配置文件中添加该module即可
>
> ```
> LoadModule authz_core_module modules/mod_authz_core.so
> ```

## Invalid command 'CustomLog'

配置出错`Invalid command 'CustomLog', perhaps misspelled or defined by a module not included in the server configuration`

引入模块log_config `LoadModule log_config_module modules/mod_log_config.so`

## exceeds ServerLimit

启动报错`MaxClients exceeds ServerLimit value…see the ServerLimit directive`

配置`ServerLimit`的值即可。

## awaiting response

访问卡住，如下示例。

```
$ wget localhost:8001
--2017-05-26 18:22:06--  http://localhost:8001/
Resolving localhost... ::1, 127.0.0.1
Connecting to localhost|::1|:8001... connected.
HTTP request sent, awaiting response...
```

问题原因：业务逻辑存在问题。

## next

