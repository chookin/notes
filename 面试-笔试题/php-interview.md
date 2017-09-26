# 基本知识

### 单引号’’和””的区别

PHP不会检查单引号''字符串中变量内插或（几乎）任何转义序列，所以采用单引号这种方式来定义字符串相当简单快捷。但是，双引号""则不然，php会检查字符串中的变量或者转义序列，并输出变量和转义序列的值。

### 魔术方法

PHP中将所有__(两个下划线)开头的类方法作为魔术方法，这方法之所以称为魔术方法是因为其实现的功能就如变魔术一样感觉很神奇。

### include和require的区别

include() 、require()语句包含并运行指定文件。

require()语句在遇到包含文件不存在，或是出错的时候，就停止即行，并报错。
include()在遇到包含文件不存在的时候，只生成警告，并且脚本会继续。
换句话说，如果你想在丢失文件时停止处理页面，那就别犹豫了，用require()吧。include()就不是这样，脚本会继续运行。

include有返回值，而require没有。
### include_once 和 require_once

include_once()和require_once()一样，应该用于在脚本执行期间同一个文件有可能被包含超过一次的情况下，想确保它只被包含一次以避免函数重定义，变量重新赋值等问题。这就是include_once()和require_once()与include()和require()的主要区别。
require_once()、include_once()运行效率要比require()和include()低，因为前两者需要判断寻找引入的文件是否已经存在。

## 数组
http://www.w3school.com.cn/php/php_arrays.asp

在 PHP 中， array() 函数用于创建数组：

```php
array();
```
在 PHP 中，有三种数组类型：
索引数组 - 带有数字索引的数组
关联数组 - 带有指定键的数组
多维数组 - 包含一个或多个数组的数组

索引数组的索引是自动分配的（索引从 0 开始）：
$cars=array("Volvo","BMW","SAAB");

关联数组是使用您分配给数组的指定键的数组。
有两种创建关联数组的方法：
$age=array("Peter"=>"35","Ben"=>"37","Joe"=>"43");
或者：
$age['Peter']="35";
$age['Ben']="37";
$age['Joe']="43";

# 编程

怎么进行页面跳转？

```php
header("Location:$url");
```

# 进阶

## 框架

[Laravel](http://www.golaravel.com/)
为 WEB 艺术家创造的 PHP 框架。

[CodeIgniter](https://codeigniter.org.cn/)

[ThinkPHP](http://www.thinkphp.cn/)
你用的tk版本是？

[Swoole](http://www.swoole.com/)
PHP的异步、并行、高性能网络通信引擎，使用纯C语言编写，提供了PHP语言的异步多线程服务器，异步TCP/UDP网络客户端，异步MySQL，异步Redis，数据库连接池，AsyncTask，消息队列，毫秒定时器，异步文件读写，异步DNS查询。 Swoole内置了Http/WebSocket服务器端/客户端、Http2.0服务器端。

除了异步IO的支持之外，Swoole为PHP多进程的模式设计了多个并发数据结构和IPC通信机制，可以大大简化多进程并发编程的工作。其中包括了并发原子计数器，并发HashTable，Channel，Lock，进程间通信IPC等丰富的功能特性。

Swoole2.0支持了类似Go语言的协程，可以使用完全同步的代码实现异步程序。PHP代码无需额外增加任何关键词，底层自动进行协程调度，实现异步。

[yii](http://www.yiiframework.com/)
Yii is a high-performance PHP framework best for developing Web 2.0 applications.

Yii comes with rich features: MVC, DAO/ActiveRecord, I18N/L10N, caching, authentication and role-based access control, scaffolding, testing, etc. It can reduce your development time significantly.

## _POST
`_POST`用于获取以表单形式提交的数据。

```shell
curl -X POST -d  "ISAPI=yes&IMEI=abc" http://localhost/sc/18/294/991 \
  -H "Content-type: application/x-www-form-urlencoded" \
  -H 'cache-control: no-cache' \
  -H 'cm-adm-api: 20170918103124_CMRI' \
  -H 'Cookie: uuid=%7B08057CE2-C4FE-3060-D084-250575198463%7D%7C2017-08-24%7C06%3A22%3A27; XDEBUG_SESSION=11890; ad_session=9cc8508e30edee4bb808e5dc7146abec' \
  -H 'postman-token: 4b286605-4424-0712-85b8-a32007b2865f'
```

`_POST`不能获取以json字符串形式POST提交的数据。[reading-json-post-using-php](https://stackoverflow.com/questions/19004783/reading-json-post-using-php)
If your web-server wants see data in json-format you need to read the raw input and then parse it with JSON decode.

```php
$json = file_get_contents('php://input');
$obj = json_decode($json);

# 例如要访问参数`msg`
$msg = $obj->msg;
```

curl的post json示例。

```sh
curl -X POST -d '{"ISAPI":"yes"}' http://localhost/sv/18/294/991 \
  -H "Content-type: application/json" \
  -H 'cache-control: no-cache' \
  -H 'cm-adm-api: 20170918103124_CMRI' \
  -H 'Cookie: XDEBUG_SESSION=11890'
```

## PHP应用性能优化
### 代码层级

### 使用缓存技术

Memcache特别适用于减少数据库负载，而像APC或OPcache这样的字节码缓存引擎在脚本编译时可节省执行时间。

由于默认情况下，PHP代码在执行时都会重新编译为可执行的中间代码OPCode，因此可以及时看到修改的代码所带来的变化，而不必频繁的重启PHP服务。不幸的是，如果每次在你的网站上运行时，都重新编译相同的代码会严重影响服务器的性能，这就是为什么opcode缓存或OPCache 非常有用。

OPCache是一个将编译好的代码保存到内存中的扩展。因此，下一次代码执行时，PHP将检查时间戳和文件大小，以确定源文件是否已更改。如果没有，则直接运行缓存的代码。

## 性能测试

## 其他
正则表达式，验证邮箱。

# 参考

- [说说 PHP 的魔术方法及其应用](https://laravel-china.org/articles/4404/talking-about-the-magic-method-of-php-and-its-application?hmsr=toutiao.io&utm_medium=toutiao.io&utm_source=toutiao.io)
- [PHP那些琐碎的知识点](https://i6448038.github.io/2017/03/25/PHP%E9%82%A3%E4%BA%9B%E5%A5%87%E6%80%AA%E7%9A%84%E8%AF%AD%E6%B3%95/?hmsr=toutiao.io&utm_medium=toutiao.io&utm_source=toutiao.io)
-[PHP应用性能优化指南](http://blog.bestxtech.com/?hmsr=toutiao.io&p=93&utm_medium=toutiao.io&utm_source=toutiao.io)
- [八年phper的高级工程师面试之路](https://zhuanlan.zhihu.com/p/27493130?hmsr=toutiao.io&utm_medium=toutiao.io&utm_source=toutiao.io)
