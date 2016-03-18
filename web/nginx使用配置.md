Nginx是俄罗斯人编写的十分轻量级的HTTP服务器,Nginx，它的发音为“engine X”，是一个高性能的HTTP和反向代理服务器，同时也是一个IMAP/POP3/SMTP 代理服务器。Nginx是由俄罗斯人 Igor Sysoev为俄罗斯访问量第二的 Rambler.ru站点开发的，它已经在该站点运行超过两年半了。Igor Sysoev在建立的项目时,使用基于BSD许可。

# nginx部署

```shell
wget http://nginx.org/download/nginx-1.9.12.tar.gz
```
解压并编译安装
```shell
./configure --prefix=/home/`whoami`/local/nginx
make
make install
```
报错：
./configure: error: the HTTP rewrite module requires the PCRE library.
解决办法：

    yum -y install pcre-devel

# nginx 配置    
linux服务器的默认位置是/etc/nginx/nginx.conf

## 基本配置
```shell
#  运行 nginx 的所属组和所有者
user www-data;
pid /var/run/nginx.pid;
worker_processes auto;
# worker_processes 8;
# worker_cpu_affinity 00000001 00000010 00000100 00001000 00010000 00100000 01000000 10000000;
worker_rlimit_nofile 100000;
```

- worker_processes 定义了nginx对外提供web服务时的worder进程数。最优值取决于许多因素，包括（但不限于）CPU核的数量、存储数据的硬盘数量及负载模式。不能确定的时候，将其设置为可用的CPU内核数将是一个好的开始（设置为“auto”将尝试自动检测它）。
- worker_cpu_affinity Nginx 默认没有开启利用多核 cpu,配置该参数以充分利用多核cpu的性能，cpu有多少个核，就有几位数，1代表内核开启，0代表内核关闭
- worker_rlimit_nofile 更改worker进程的最大打开文件数限制。如果没设置的话，这个值为操作系统的限制。设置后你的操作系统和Nginx可以处理比“ulimit -a”更多的文件，所以把这个值设高，这样nginx就不会有“too many open files”问题了。

## Events模块

events模块中包含nginx中所有处理连接的设置。
```
events {
worker_connections 2048;
multi_accept on;
use epoll;
}
```

- worker_connections设置可由一个worker进程同时打开的最大连接数。在作为web服务器的情况下，nginx最大连接数为worker_connections * worker_processes.
- multi_accept 告诉nginx收到一个新连接通知后接受尽可能多的连接。
- use 设置用于复用客户端线程的轮询方法。如果你使用Linux 2.6+，你应该使用epoll。如果你使用*BSD，你应该使用kqueue。想知道更多有关事件轮询？看下维基百科吧（注意，想了解一切的话可能需要neckbeard和操作系统的课程基础）

## HTTP 模块

HTTP模块控制着nginx http处理的所有核心特性。
### 普通

```shell
http {
    server_tokens off;
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;

    access_log off;
    error_log /var/log/nginx/error.log crit;

    keepalive_timeout 10;
    client_header_timeout 10;
    client_body_timeout 10;
    reset_timedout_connection on;
    send_timeout 10;

    limit_conn_zone $binary_remote_addr zone=addr:5m;
    limit_conn addr 100;

    include /etc/nginx/mime.types;
    default_type text/html;
    charset UTF-8;

    gzip_disable "msie6";
    # gzip_static on;
    gzip_proxied any;
    gzip_min_length 1000;
    gzip_comp_level 4;
    gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript;

    # cache informations about file descriptors, frequently accessed files
    # can boost performance, but you need to test those values
    open_file_cache max=100000 inactive=20s;
    open_file_cache_valid 30s;
    open_file_cache_min_uses 2;
    open_file_cache_errors on;
    ##
    # Virtual Host Configs
    # aka our settings for specific servers
    ##
    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;

    # 定义服务组 myapp1
    upstream myapp1 {
        server srv1.example.com weight=5;
        server srv2.example.com weight=10;
    }
    # 开始配置一个域名,一个 server 配置段一般对应一个域名
    server {
        # 在本机所有 ip 上监听 80,也可以写为 192.168.1.202:80,这样的话,就只监听 192.168.1.202 上的 80 口
        listen 80;
        server_name  *.example.org; # 域名
        index index.html index.htm; # 索引文件
        location / { # 可以有多个 location
            root /data/www; # 站点根目录,你网站文件存放的地方。注:站点目录和域名尽量一样,养成一个 好习惯
            proxy_pass http://myapp1;
        }
        location /images/ {
            root /data;
        }
        location ~ \.(gif|jpg|jpeg|png|bmp|ico)$ {
            root /var/www/img/;
            expires 30d;
        }
        # 定义错误页面,如果是 500 错误,则把站点根目录下的 50x.html 返回给用户
        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
            root /www/html/bbs.heytool.com;
        }
    }
    server {
        listen 80;
        server_name  ~^(?<user>.+)\.example\.net$;
        ...
    }
}
```

- server_tokens 并不会让nginx执行的速度更快，但它可以关闭在错误页面中的nginx版本数字，这样对于安全性是有好处的。
- sendfile可以让sendfile()发挥作用。sendfile()可以在磁盘和TCP socket之间互相拷贝数据(或任意两个文件描述符)。Pre-sendfile是传送数据之前在用户空间申请数据缓冲区。之后用read()将数据从文件拷贝到这个缓冲区，write()将缓冲区数据写入网络。sendfile()是立即将数据从磁盘读到OS缓存。因为这种拷贝是在内核完成的，sendfile()要比组合read()和write()以及打开关闭丢弃缓冲更加有效(更多有关于sendfile)
- tcp_nopush 告诉nginx在一个数据包里发送所有头文件，而不一个接一个的发送
- tcp_nodelay 告诉nginx不要缓存数据，而是一段一段的发送–当需要及时发送数据时，就应该给应用设置这个属性，这样发送一小块数据信息时就不能立即得到返回值。
- access_log设置nginx是否将存储访问日志。关闭这个选项可以让读取磁盘IO操作更快(aka,YOLO)。
- error_log 告诉nginx只能记录严重的错误。
- keepalive_timeout 给客户端分配keep-alive链接超时时间。服务器将在这个超时时间过后关闭链接。我们将它设置低些可以让ngnix持续工作的时间更长。
- client_header_timeout 和client_body_timeout 设置请求头和请求体(各自)的超时时间。我们也可以把这个设置低些。
- reset_timeout_connection告诉nginx关闭不响应的客户端连接。这将会释放那个客户端所占有的内存空间。
- send_timeout 指定客户端的响应超时时间。这个设置不会用于整个转发器，而是在两次客户端读取操作之间。如果在这段时间内，客户端没有读取任何数据，nginx就会关闭连接。
- limit_conn为给定的key设置最大连接数。这里key是addr，我们设置的值是100，也就是说我们允许每一个IP地址最多同时打开有100个连接。
- limit_conn_zone设置用于保存各种key（比如当前连接数）的共享内存的参数。5m就是5兆字节，这个值应该被设置的足够大以存储（32K*5）32byte状态或者（16K*5）64byte状态。
- include只是一个在当前文件中包含另一个文件内容的指令。这里我们使用它来加载稍后会用到的一系列的MIME类型。
- default_type设置文件使用的默认的MIME-type。
- charset设置我们的头文件中的默认的字符集。
- gzip是告诉nginx采用gzip压缩的形式发送数据。这将会减少我们发送的数据量。
- gzip_disable为指定的客户端禁用gzip功能。我们设置成IE6或者更低版本以使我们的方案能够广泛兼容。
- gzip_static告诉nginx在压缩资源之前，先查找是否有预先gzip处理过的资源。这要求你预先压缩你的文件（在这个例子中被注释掉了），从而允许你使用最高压缩比，这样nginx就不用再压缩这些文件了（想要更详尽的gzip_static的信息，请点击这里）。
- gzip_proxied允许或者禁止压缩基于请求和响应的响应流。我们设置为any，意味着将会压缩所有的请求。
- gzip_min_length设置对数据启用压缩的最少字节数。如果一个请求小于1000字节，我们最好不要压缩它，因为压缩这些小的数据会降低处理此请求的所有进程的速度。
- gzip_comp_level设置数据的压缩等级。这个等级可以是1-9之间的任意数值，9是最慢但是压缩比最大的。我们设置为4，这是一个比较折中的设置。
- gzip_type设置需要压缩的数据格式。上面例子中已经有一些了，你也可以再添加更多的格式。
- open_file_cache打开缓存的同时也指定了缓存最大数目，以及缓存的时间。我们可以设置一个相对高的最大时间，这样我们可以在它们不活动超过20秒后清除掉。
- open_file_cache_valid 在open_file_cache中指定检测正确信息的间隔时间。
- open_file_cache_min_uses 定义了open_file_cache中指令参数不活动时间期间里最小的文件数。
- open_file_cache_errors指定了当搜索一个文件时是否缓存错误信息，也包括再次给配置中添加文件。我们也包括了服务器模块，这些是在不同文件中定义的。如果你的服务器模块不在这些位置，你就得修改这一行来指定正确的位置。

- upstream 用于定义一组反向代理/负载均衡后端服务器池。负载均衡默认采用轮询方式。参考[Using nginx as HTTP load balancer](http://nginx.org/en/docs/http/load_balancing.html)
- server 服务组，通过端口或server_name区分。nginx在确定用哪个server处理来处理接收到的request后，将进一步从该server block中所定义的location directives中，选择能匹配该请求URI的。参考nginx [beginner's guide](http://nginx.org/en/docs/beginners_guide.html).
- server_name 虚拟主机的域名,可以写多个域名,类似于别名,比如说你可以配置成
server_name b.ttlsa.com c.ttlsa.com d.ttlsa.com,这样的话,访问任何一个域名,内容都是一样的。支持通配符*（例如*.domain.com）或正则表达式（例如~^(?.+)\.domain\.com$）。参考关于Nginx的[server names](http://nginx.org/en/docs/http/server_names.html)
- proxy_pass 用于指定反向代理的服务器池
- expires起到控制页面缓存的作用，合理的配置expires可以减少很多服务器的请求.

# nginx 操作
启动：

    nginx
    # nginx -c ~/local/nginx/conf/nginx.conf
其他操作

    nginx -s stop                快速关闭Nginx，可能不保存相关信息，并迅速终止web服务。
    nginx -s quit                平稳关闭Nginx，保存相关信息，有安排的结束web服务。 
    nginx -s reload              修改配置后重启。 
    nginx -s reopen              重新打开日志文件。 
    从容停止   kill -QUIT 主进程号
    快速停止   kill -TERM 主进程号
    强制停止   kill -9 nginx

# 常见问题
（1）nginx: [emerg] unknown log format "main" in
"main"错误是因为丢失了log_format选项，之前把他屏蔽掉了，把nginx.conf文件中的"log_format"取消注释即可。

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
    access_log  logs/access.log main;
(2)nginx: [emerg] bind() to 0.0.0.0:80 failed (13: permission denied)
the socket API bind() to a port less than 1024, such as 80 as your title mentioned, need root access.


