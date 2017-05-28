# htaccess
.htaccess文件是Apache服务器中的一个配置文件，它负责相关目录下的网页配置。通过htaccess文件，可以帮我们实现：网页301重定向、自定义404错误页面、改变文件扩展名、封禁特定IP地址的用户、只允许特定IP地址的用户、禁止目录列表、配置默认文档等功能。

启用.htaccess，需要修改httpd.conf，启用AllowOverride，并可以用AllowOverride限制特定命令的使用。如果需要使用.htaccess以外的其他文件名，可以用AccessFileName指令来改变。例如，需要使用.config ，则可以在服务器配置文件中按以下方法配置：AccessFileName .config 。

一般情况下，不应该使用.htaccess文件，除非你对主配置文件没有访问权限。
避免使用.htaccess文件有两个主要原因。

- 首先是性能。如果AllowOverride启用了.htaccess文件，则Apache对每一个请求，都需要读取一次.htaccess文件。还有，Apache必须在所有上级的目录中查找.htaccess文件，以使所有有效的指令都起作用(参见指令的生效)，所以，如果请求/www/htdocs/example中的页面，Apache必须查找以下文件：`/.htaccess /www/.htaccess /www/htdocs/.htaccess /www/htdocs/example/.htaccess`,总共要访问4个额外的文件，即使这些文件都不存在。
- 其次是安全。这样会允许用户自己修改服务器的配置，这可能会导致某些意想不到的修改。

把配置放在主配置文件中更加高效，因为只需要在Apache启动时读取一次，而不是在每次文件被请求时都读取。
将AllowOverride设置为none可以完全禁止使用.htaccess文件：

```
AllowOverride None
```

# 示例

```shell
# 用于开启或关闭之后的语句
RewriteEngine on
# RewriteCond  重写条件，通常会跟随一句类似下面的语句 `RewriteRule index.php`

# # 前面%{HTTP_HOST}表示当前访问的网址，只是指前缀部分，格式是www.xxx.com不包括“http://”和“/”，^表示 字符串开始，$表示字符串结尾，\.表示转义的. ，如果不转义也行，推荐转义，防止有些服务器不支持，?表示前面括号www\.出现0次或1次，这句规则的意思就是如果访问的网址是xxx.com或者 www.xxx.com就执行以下的语句，不符合就跳过
## 不能保证输入的网址都是小写的，而Linux系统是区分大小写的，所以应该在RewriteCond后添加`[NC]`，以忽略大小写
# RewriteCond %{HTTP_HOST} ^(www\.)?xxx\.com$ [NC]

# # %{REQUEST_URI}表示访问的相对地址，就是相对根目录的地址，就是域名/后面的成分，格式上包括最前面的“/”
# # !表示非，这句语句表示，访问的地址不以/blog/开头，只是开头^，没有结尾$
# RewriteCond %{REQUEST_URI} !^/blog/

# %{REQUEST_FILENAME}    由Apache服务器解析成文件名
# 这句语句表示，如果访问的文件不存在
RewriteCond %{REQUEST_FILENAME} !-f
# 这句语句表示，如果访问的路径不存在
RewriteCond %{REQUEST_FILENAME} !-d

# $1代表引用RewriteRule中的第一个正则(.*)代表的字符
RewriteCond $1 !^(index\.php|images|robots\.txt|getconfig\.xml)

# ^(.*)$是一个正则表达的 匹配，匹配的是当前请求的URL，^(.*)$意思是匹配当前URL任意字符，.表示任意单个字符，*表示匹配0次或N次（N>0），后面 /index.php/$1是重写成分，意思是将前面匹配的字符重写成/index.php/$1，这个$1表示反向匹配，引用的是前面第一个圆括号的成分，即^(.*)$中 的.*
# `[L]`表示最后一条语句
RewriteRule ^(.*)$ /index.php/$1 [L]
```

# 参考

- [服务器.htaccess 详解，最新最全的 .htaccess 参数说明](http://www.cnblogs.com/engeng/articles/5951462.html)
- [利用apache的mod_rewrite做URL规则重写](http://www.cnblogs.com/miketwais/p/mod_rewrite.html)
