# 常见问题

1，启动报错

>  undefined symbol: apr_array_clear

需要下载apr和apr-utils 并解压到./srclib/，然后在编译时指定` --with-included-apr `

2，启动告警

> AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 192.168.110.107. Set the 'ServerName' directive globally to suppress this message

将 apache 的配置文件httpd.conf中的 ServerName 改成可用域名。

3，apache httpd 2.2的配置放到apache httpd 2.4下就出现了这个错误

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

4，`AH00548: NameVirtualHost has no effect and will be removed in the next release`

去掉 NameVirtualHost 这一行，就行了

5，启动报错`HTTP request sent, awaiting response... 403 Forbidden`

查看apache日志

```
AH01630: client denied by server configuration: /home/zhuyin/www/admonitor/webapp/
```

问题原因是apache的权限规则发生了变化。

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

apache重启继续报错

```
AH01276: Cannot serve directory /home/zhuyin/www/admonitor/webapp/: No matching DirectoryIndex (index.html) found, and server-generated directory index forbidden by Options directive
```

解决办法，在web文档根路径下创建文件index.html

```shell
echo 'hello' > /home/zhuyin/www/admonitor/webapp/index.html
```

6，配置出错`Invalid command 'Require', perhaps misspelled or defined by a module not included in the server configuration`

> The Require directive is supplied by mod_authz_core. If the module has not been compiled into your Apache binary, you will need to add an entry to your configuration file to load it manually.
>
> 在配置文件中添加该module即可
>
> ```
> LoadModule authz_core_module modules/mod_authz_core.so
> ```

7，配置出错`Invalid command 'CustomLog', perhaps misspelled or defined by a module not included in the server configuration`

引入模块log_config `LoadModule log_config_module modules/mod_log_config.so`

8，启动报错`MaxClients exceeds ServerLimit value…see the ServerLimit directive`

配置`ServerLimit`的值即可。
