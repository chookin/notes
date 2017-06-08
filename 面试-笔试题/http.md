# HTTP

## 一次完整的HTTP事务是怎样的一个过程？

基本流程：
a. 域名解析
b. 发起TCP的3次握手
c. 建立TCP连接后发起http请求
d. 服务器端响应http请求，浏览器得到html代码
e. 浏览器解析html代码，并请求html代码中的资源
f. 浏览器对页面进行渲染呈现给用户

## HTTP的状态码有哪些


## HTTP和HTTPS

HTTP协议通常承载于TCP协议之上，在HTTP和TCP之间添加一个安全协议层（SSL或TSL），这个时候，就成了我们常说的HTTPS。

默认HTTP的端口号为80，HTTPS的端口号为443。

为什么HTTPS安全

因为网络请求需要中间有很多的服务器路由器的转发。中间的节点都可能篡改信息，而如果使用HTTPS，密钥在你和终点站才有。https之所以比http安全，是因为他利用ssl/tls协议传输。它包含证书，卸载，流量转发，负载均衡，页面适配，浏览器适配，refer传递等。保障了传输过程的安全性

## 锚点
一、#的涵义
　　#代表网页中的一个位置。其右面的字符，就是该位置的标识符。比如，http://www.example.com/index.html#print就代表网页index.html的print位置。浏览器读取这个URL后，会自动将print位置滚动至可视区域。
　　为网页位置指定标识符，有两个方法。一是使用锚点，比如<a name="print"></a>，二是使用id属性，比如<div id="print">。
二、HTTP请求不包括#
　　#是用来指导浏览器动作的，对服务器端完全无用。所以，HTTP请求中不包括#。
比如，访问下面的网址，http://www.example.com/index.html#print，浏览器实际发出的请求是这样的：

```
GET /index.html HTTP/1.1
Host: www.example.com
```

> You want to get the #hash in PHP JUST from requested URL?
    YOU CAN'T !

- https://stackoverflow.com/questions/2317508/get-fragment-value-after-hash-from-a-url-in-php
