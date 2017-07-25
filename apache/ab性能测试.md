模拟1000个请求，600个并发，加上-r参数可防止出现：apr_socket_recv "connection reset by peer" 错误

```
# ab -r -n 1000 -c 600 http://192.168.15.55/test/big/index.php
This is ApacheBench, Version 2.3 <$Revision: 655654 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking 192.168.15.55 (be patient)
Completed 100 requests
Completed 200 requests
Completed 300 requests
Completed 400 requests
Completed 500 requests
Completed 600 requests
Completed 700 requests
Completed 800 requests
Completed 900 requests
Completed 1000 requests
Finished 1000 requests


Server Software:        Apache/2.4.10
Server Hostname:        192.168.15.55
Server Port:            80

Document Path:          /test/big/index.php
Document Length:        0 bytes

Concurrency Level:      600
Time taken for tests:   0.612 seconds
Complete requests:      1000
Failed requests:        1645
   (Connect: 0, Receive: 642, Length: 361, Exceptions: 642)
Write errors:           0
Non-2xx responses:      367
Total transferred:      156709 bytes
HTML transferred:       79272 bytes
Requests per second:    1634.79 [#/sec] (mean)
Time per request:       367.019 [ms] (mean)
Time per request:       0.612 [ms] (mean, across all concurrent requests)
Transfer rate:          250.18 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0   25  50.0      0     191
Processing:    34  156  77.0    168     308
Waiting:        0   98  91.5    122     308
Total:         34  182 110.8    176     481

Percentage of the requests served within a certain time (ms)
  50%    176
  66%    198
  75%    219
  80%    231
  90%    372
  95%    447
  98%    463
  99%    472
 100%    481 (longest request)
```

结果分析：

```
Server Software 表示被测试的Web服务器软件名称
Server Hostname 表示请求的URL主机名
Server Port 表示被测试的Web服务器软件的监听端口
Document Path 表示请求的URL中的根绝对路径，通过该文件的后缀名，我们一般可以了解该请求的类型
Document Length 表示HTTP响应数据的正文长度
Concurrency Level 表示并发用户数，这是我们设置的参数之一
Time taken for tests 表示所有这些请求被处理完成所花费的总时间
Complete requests 表示总请求数量，这是我们设置的参数之一
Failed requests 表示失败的请求数量，这里的失败是指请求在连接服务器、发送数据等环节发生异常，以及无响应后超时的情况。如果接收到的HTTP响应数据的头信息中含有2XX以外的状态码，则会在测试结果中显示另一个名为       “Non-2xx responses”的统计项，用于统计这部分请求数，这些请求并不算在失败的请求中。
Total transferred 表示所有请求的响应数据长度总和，包括每个HTTP响应数据的头信息和正文数据的长度。注意这里不包括HTTP请求数据的长度，仅仅为web服务器流向用户PC的应用层数据总长度。
HTML transferred 表示所有请求的响应数据中正文数据的总和，也就是减去了Total transferred中HTTP响应数据中的头信息的长度。
Requests per second 吞吐率，计算公式：Complete requests / Time taken for tests
Time per request 用户平均请求等待时间，计算公式：Time token for tests/（Complete requests/Concurrency Level）
Time per requet(across all concurrent request) 服务器平均请求等待时间，计算公式：Time taken for tests/Complete requests，正好是吞吐率的倒数。也可以这么统计：Time per request/Concurrency Level
Transfer rate 表示这些请求在单位时间内从服务器获取的数据长度，计算公式：Total trnasferred/ Time taken for tests，这个统计很好的说明服务器的处理能力达到极限时，其出口宽带的需求量。
Percentage of requests served within a certain time（ms） 这部分数据用于描述每个请求处理时间的分布情况，比如以上测试，80%的请求处理时间都不超过6ms，这个处理时间是指前面的Time per request，即对于单个用户而言，平均每个请求的处理时间。
```

重点分析：

```
Requests per second
Time per request
Percentage of requests served within a certain time（ms）
```

参考：

- [apache压力测试ab命令使用及结果判断](http://blog.csdn.net/nuli888/article/details/51867801)
