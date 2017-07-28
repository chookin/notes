# CodeIgniter

[CodeIgniter](https://codeigniter.org.cn/) 是一个小巧但功能强大的 PHP 框架，作为一个简单而“优雅”的工具包，它可以为开发者们建立功能完善的 Web 应用程序。

# [安装](https://codeigniter.org.cn/user_guide/installation/index.html)
通过下面四步来安装 CodeIgniter：

1. [下载](https://github.com/bcit-ci/CodeIgniter/archive/3.1.4.zip)，解压缩安装包；
2. 将 CodeIgniter 文件夹及里面的文件上传到服务器，通常 index.php 文件将位于网站的根目录；
3. 使用文本编辑器打开 application/config/config.php 文件设置你网站的根 URL，如果你想使用加密或会话，在这里设置上你的加密密钥；
4. 如果你打算使用数据库，打开 application/config/database.php 文件设置数据库参数。

如果你想通过隐藏 CodeIgniter 的文件位置来增加安全性，你可以将 system 和 application 目录修改为其他的名字，然后打开主目录下的 index.php 文件将 `$system_path` 和 `$application_folder`两个变量设置为你修改的名字。

# 概览
## [应用程序流程](https://codeigniter.org.cn/user_guide/overview/appflow.html)

1. index.php 文件作为前端控制器，初始化运行 CodeIgniter 所需的基本资源；
2. router 检查 HTTP 请求，以确定如何处理该请求；
3. 如果存在缓存文件，将直接输出到浏览器，不用走下面正常的系统流程；
4. 在加载应用程序控制器之前，对 HTTP 请求以及任何用户提交的数据进行安全检查；
5. 控制器加载模型、核心类库、辅助函数以及其他所有处理请求所需的资源；
6. 最后一步，渲染视图并发送至浏览器，如果开启了缓存，视图被会先缓存起来用于 后续的请求。

## MVC
- 模型 代表你的数据结构。通常来说，模型类将包含帮助你对数据库进行增删改查的方法。
- 视图 是要展现给用户的信息。一个视图通常就是一个网页，但是在 CodeIgniter 中， 一个视图也可以是一部分页面（例如页头、页尾），它也可以是一个 RSS 页面， 或其他任何类型的页面。
- 控制器 是模型、视图以及其他任何处理 HTTP 请求所必须的资源之间的中介，并生成网页。

## 调试 v2.1.4
在`index.php`中，配置

```php
define('ENVIRONMENT', 'development');
```

在`application/config/config.php`中配置

```php
$config['log_threshold'] = 4;
```

# 常见问题
1，怎么查看CI的版本信息？想看某个项目中使用的CI具体是哪个版本，怎么查看？
system\core\codeigniter.php中可以查看版本常量

```php
define('CI_VERSION', '2.1.4');
```

# 参考

- [数据库配置](http://codeigniter.org.cn/user_guide/database/configuration.html)
- [【ci框架】codeigniter中如何记录错误日志](http://blog.csdn.net/yanhui_wei/article/details/21183905)
