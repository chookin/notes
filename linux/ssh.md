# 远程执行命令

    ssh -t -p $port $user@$p 'cmd'

* $port : ssh连接端口号
* $user: ssh连接用户名
* $ip:ssh连接的ip地址
* cmd:远程服务器需要执行的操作
* t: 提供一个远程服务器的虚拟tty终端，加上这个参数我们就可以在远程服务器的虚拟终端上输入自己的提权密码了，非常安全 .

```shell
ssh -t -p 21022 lab08 'hostname > /home/mtag/share/`hostname`.txt'
```
