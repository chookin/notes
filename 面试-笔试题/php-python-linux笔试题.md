# 笔试题

## php（15分）

1. 表单中get与post提交方法的区别?（2分）


```
GET用于获取数据，POST用于提交数据；
GET请求能被浏览器缓存；
GET向URL 添加数据；URL的长度是受限制的，POST对数据长度无限制；
POST比GET 更安全，因为参数不会被保存在浏览器历史或 web 服务器日志中。

http://www.w3school.com.cn/tags/html_ref_httpmethods.asp
```


2. session与cookie的区别?（2分）


```
Session是在服务端保存的一个数据结构，用来跟踪用户的状态，这个数据可以保存在集群、数据库、文件中；
Cookie是客户端保存用户信息的一种机制，用来记录用户的一些信息;
```


3. require和include都可包含文件，二者的区别何在？（2）

```
使用require发生了不存在的文件，程序将输出Fatal error并停止运行
include只输出Warning，并继续执行
```
4. 写出PHP中常用的超全局变量(不少于5个)（2分）

```
$GLOBALS
$_SERVER
$_REQUEST
$_POST
$_GET
$_FILES
$_ENV
$_COOKIE
$_SESSION

https://www.w3cschool.cn/php/php-superglobals.html
```
5. 写出你常用的几个魔术常量（2分）

```
__LINE__	文件中的当前行号。
__FILE__	文件的完整路径和文件名。如果用在被包含文件中，则返回被包含的文件名。自 PHP 4.0.2 起，__FILE__ 总是包含一个绝对路径（如果是符号连接，则是解析后的绝对路径），而在此之前的版本有时会包含一个相对路径。
__DIR__	文件所在的目录。如果用在被包括文件中，则返回被包括的文件所在的目录。它等价于 dirname(__FILE__)。除非是根目录，否则目录中名不包括末尾的斜杠。（PHP 5.3.0中新增） =
__FUNCTION__	函数名称（PHP 4.3.0 新加）。自 PHP 5 起本常量返回该函数被定义时的名字（区分大小写）。在 PHP 4 中该值总是小写字母的。
__CLASS__	类的名称（PHP 4.3.0 新加）。自 PHP 5 起本常量返回该类被定义时的名字（区分大小写）。在 PHP 4 中该值总是小写字母的。类名包括其被声明的作用区域（例如 Foo\Bar）。注意自 PHP 5.4 起 __CLASS__ 对 trait 也起作用。当用在 trait 方法中时，__CLASS__ 是调用 trait 方法的类的名字。
__TRAIT__	Trait 的名字（PHP 5.4.0 新加）。自 PHP 5.4 起此常量返回 trait 被定义时的名字（区分大小写）。Trait 名包括其被声明的作用区域（例如 Foo\Bar）。
__METHOD__	类的方法名（PHP 5.0.0 新加）。返回该方法被定义时的名字（区分大小写）。
__NAMESPACE__	当前命名空间的名称（区分大小写）。此常量是在编译时定义的（PHP 5.3.0 新增）。

http://php.net/manual/zh/language.constants.predefined.php
```
6. 如何用php的环境变量得到一个网页地址？ip地址又要怎样得到？（2分）

```php
"http://".$_SERVER ['HTTP_HOST'].$_SERVER['PHP_SELF'] ;// 获取网页地址
 $_SERVER['REMOTE_ADDR'] //获取IP地址
```
7. PHP网站的主要攻击方式有哪些？（3分）

```
1、命令注入(Command Injection)
2、eval注入(Eval Injection)
3、客户端脚本攻击(Script Insertion)
4、跨网站脚本攻击(Cross Site Scripting, XSS)
5、SQL注入攻击(SQL injection)
6、跨网站请求伪造攻击(Cross Site Request Forgeries, CSRF)
7、Session 会话劫持(Session Hijacking)
8、Session 固定攻击(Session Fixation)
9、HTTP响应拆分攻击(HTTP Response Splitting)
10、文件上传漏洞(File Upload Attack)
11、目录穿越漏洞(Directory Traversal)
12、远程文件包含攻击(Remote Inclusion)
13、动态函数注入攻击(Dynamic Variable Evaluation)
14、URL攻击(URL attack)
15、表单提交欺骗攻击(Spoofed Form Submissions)
16、HTTP请求欺骗攻击(Spoofed HTTP Requests)

http://www.cnblogs.com/xiaomifeng/p/4655356.html
```

## python（15分）

1. 列表(list)和元组(tuple)的区别（2分）

```
元组是不可变的， 而列表是可变的
```
2. 输出1到100之和（2分）

```python
# 1. 使用内建函数range
print sum(range(1,101))

# 2. 使用函数reduce
print reduce(lambda a,b:a+b,range(1,101))

# 3. 使用循环
n = 0
for x in range(101):
   n = x + n
```

3. 请在下面的空白处填写运行结果（2分）

```
>>>seq = [1, 2, 3, 4]
>>>seq[:2]
[1, 2]___________________________
>>>seq[-2:]
[3, 4]___________________________
```

4. 函数参数`*args` 和 `**kwargs`的作用是？（3分）

```
*args是可变的positional arguments列表，**kwargs是可变的keyword arguments列表。并且，*args必须位于**kwargs之前，因为positional arguments必须位于keyword arguments之前
```
5. 以下的代码的输出将是什么? （3分）

```
class Parent(object):
    x = 1

class Child1(Parent):
    pass

class Child2(Parent):
    pass

print Parent.x, Child1.x, Child2.x

Child1.x = 2
print Parent.x, Child1.x, Child2.x

Parent.x = 3
print Parent.x, Child1.x, Child2.x

>>______1，1，1_______________________

>>______1，2，1_______________________

>>______3, 2，3_______________________

http://python.jobbole.com/86525/
```

6. 写出你认为最Pythonic的代码（3分）

**交互变量**

非Pythonic

```python
temp = a
a = b
b = temp
```
pythonic:

```python
a,b = b,a
```

http://wuzhiwei.net/be_pythonic/

## linux rhel6 （20分）

一、如下各题每题1分（11分）

1. 修改文件权限的命令是？`_chmod_________________________________________________`

2. 配置定时任务的命令是？`___crontab_______________________________________________`

3. 网络抓包的命令是？`___tcpdump_______________________________________________`

4. 你知道的vi命令有哪几个？`__:i :e :a :O :o :j :k________________________________________________`

5. 查看进程id为1553的进程信息，命令是？

   `_ps aux | grep 1553_________________________________________________`

6. 查看使用3306端口的进程，命令是？

   `netstat -lnap |grep 3306_________________________________________`

7. 防火墙的配置文件是？`___/etc/sysconfig/iptables_______________________________________________`

8. 域名解析的配置文件是？`__/etc/resolv.conf________________________________________________`

9. 操作系统的日志在哪个路径？`___/var/log/_______________________________________________`

10. 查看系统内核版本号及系统名称的命令是？

```shell
 uanme -a
 cat /etc/issue
 cat /proc/version
 ```

11. 若要获取上个命令的退出状态或函数的返回值，可使用哪个shell变量？`___#?____________________________`

二、如下各题每题3分（9分）

1. 写出可实现如下目的的命令：查找类型为文件，扩展名为“.sh"，并且文件内容包含”merged.data"的文件。

```shell
find  . -type f -name "*.sh" | xargs grep "merged.data"
```
2. 用于不同服务器间文件同步的命令有哪几个，你常用哪个，为什么？

```shell
rsync
scp
sftp
nc
rsync # 可用于增量更新
sersync # 可以记录下被监听目录中发生变化的（包括增加、删除、修改）具体某一个文件或者某一个目录的名字，然后使用rsync同步的时候，只同步发生变化的文件或者目录
rsync+sersync # 当同步的目录数据量很大时（几百G甚至1T以上）文件很多时，建议使用
```
3. 系统级环境变量的配置文件是，用户级环境变量的配置文件是，如何使环境变量配置文件的修改立即生效？

```shell
/etc/profile
~/.bashrc
~/.bash_profile
source
```
## 数据库（10分）

1. mysql忘记密码该如何操作呢？(2分)

```
修改配置文件，在[mysqld]的段中加上一句：skip-grant-tables 保存并且退出；
重启mysql;
登录并修改MySQL的root密码，执行`UPDATE user SET Password = password ( 'new-password' ) WHERE User = 'root';`设置密码；
修改配置文件，把刚才添加的skip-grant-tables删除.
重启mysql;
```
2. web网站，在用户登录环节，如何避免sql注入？（2分）

```
1，过滤特殊符号，正则校验
2，绑定变量，使用预编译语句

```
http://www.plhwin.com/2014/06/13/web-security-sql/

3. mysql主从的优缺点（3分）

```
可靠，查询性能提高；
写入性能下降，有延迟
```

4. sql之left join、right join、inner join的区别?（3分）

```
left join(左联接) 返回包括左表中的所有记录和右表中联结字段相等的记录
right join(右联接) 返回包括右表中的所有记录和左表中联结字段相等的记录
inner join(等值连接) 只返回两个表中联结字段相等的行
```
