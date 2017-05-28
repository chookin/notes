## 端口使用情况

### namenode

通过9100端口与datanode互联。

50070 namenode web管理页面

```shell
[root@PZMG-WB10-VAS ~]# netstat -lanp |grep `ps aux |grep NameNode | grep -v Second |grep -v grep | awk '{print $2}'` |grep -v unix
tcp        0      0 0.0.0.0:52491               0.0.0.0:*                   LISTEN      22310/java
tcp        0      0 172.17.128.20:9100          0.0.0.0:*                   LISTEN      22310/java
tcp        0      0 0.0.0.0:50070               0.0.0.0:*                   LISTEN      22310/java
tcp        0      0 172.17.128.20:9100          172.17.128.23:42063         ESTABLISHED 22310/java
tcp        0      0 172.17.128.20:9100          172.17.128.26:32894         ESTABLISHED 22310/java
tcp        0      0 172.17.128.20:9100          172.17.128.25:54731         ESTABLISHED 22310/java
tcp        0      0 172.17.128.20:9100          172.17.128.22:58919         ESTABLISHED 22310/java
tcp        0      0 172.17.128.20:9100          172.17.128.24:38582         ESTABLISHED 22310/java
tcp        0      0 172.17.128.20:9100          172.17.128.20:36762         ESTABLISHED 22310/java
tcp        0      0 172.17.128.20:9100          172.17.128.21:56929         ESTABLISHED 22310/java
```

### SecondaryNameNode

50090 web管理页面

```shell
[root@PZMG-WB10-VAS ~]# netstat -lanp |grep `ps aux |grep SecondaryNameNode | grep -v grep | awk '{print $2}'` |grep -v unix
tcp        0      0 0.0.0.0:37652               0.0.0.0:*                   LISTEN      22622/java
tcp        0      0 0.0.0.0:50090               0.0.0.0:*                   LISTEN      22622/java
```

### DataNode

50075 web管理页面

```shell
[root@PZMG-WB11-VAS ~]# netstat -lanp |grep `ps aux |grep DataNode | grep -v grep | awk '{print $2}'` |grep -v unix
tcp        0      0 0.0.0.0:                0.0.0.0:*                   LISTEN      13638/java
tcp        0      0 127.0.0.1:36270             0.0.0.0:*                   LISTEN      13638/java
tcp        0      0 0.0.0.0:50010               0.0.0.0:*                   LISTEN      13638/java
tcp        0      0 0.0.0.0:50075               0.0.0.0:*                   LISTEN      13638/java
tcp        0      0 0.0.0.0:50020               0.0.0.0:*                   LISTEN      13638/java
tcp        0      0 172.17.128.21:56929         172.17.128.20:9100          ESTABLISHED 13638/java
```

### ResourceManager

8088 web管理页面

```shell
[root@PZMG-WB10-VAS ~]# netstat -lanp |grep `ps aux |grep ResourceManager | grep -v grep | awk '{print $2}'` |grep -v unix
tcp        0      0 ::ffff:172.17.128.20:8088   :::*                        LISTEN      22792/java
tcp        0      0 ::ffff:172.17.128.20:8030   :::*                        LISTEN      22792/java
tcp        0      0 ::ffff:172.17.128.20:8031   :::*                        LISTEN      22792/java
tcp        0      0 ::ffff:172.17.128.20:8032   :::*                        LISTEN      22792/java
tcp        0      0 ::ffff:172.17.128.20:8033   :::*                        LISTEN      22792/java
tcp        0      0 ::ffff:172.17.128.20:8031   ::ffff:172.17.128.22:52887  ESTABLISHED 22792/java
tcp        0      0 ::ffff:172.17.128.20:8031   ::ffff:172.17.128.24:38544  ESTABLISHED 22792/java
tcp        0      0 ::ffff:172.17.128.20:8031   ::ffff:172.17.128.23:58167  ESTABLISHED 22792/java
tcp        0      0 ::ffff:172.17.128.20:8031   ::ffff:172.17.128.21:41407  ESTABLISHED 22792/java
tcp        0      0 ::ffff:172.17.128.20:8031   ::ffff:172.17.128.26:53584  ESTABLISHED 22792/java
tcp        0      0 ::ffff:172.17.128.20:8031   ::ffff:172.17.128.25:43478  ESTABLISHED 22792/java
```

### NodeManager

8042 web端口

```shell
[root@PZMG-WB11-VAS ~]# netstat -lanp |grep `ps aux |grep NodeManager | grep -v grep | awk '{print $2}'` |grep -v unix
tcp        0      0 :::51478                    :::*                        LISTEN      13765/java
tcp        0      0 :::13562                    :::*                        LISTEN      13765/java
tcp        0      0 :::8040                     :::*                        LISTEN      13765/java
tcp        0      0 :::8042                     :::*                        LISTEN      13765/java
tcp        0      0 ::ffff:172.17.128.21:41407  ::ffff:172.17.128.20:8031   ESTABLISHED 13765/java
```

### JobHistoryServer

19888 web端口

```shell
[root@PZMG-WB10-VAS ~]# netstat -lanp |grep `ps aux |grep JobHistoryServer | grep -v grep | awk '{print $2}'` |grep -v unix
tcp        0      0 172.17.128.20:19888         0.0.0.0:*                   LISTEN      95714/java
tcp        0      0 0.0.0.0:10033               0.0.0.0:*                   LISTEN      95714/java
tcp        0      0 172.17.128.20:10020         0.0.0.0:*                   LISTEN      95714/java
```

## 参考
- [Hadoop 2.x常用端口及查看方法](http://www.cnblogs.com/jancco/p/4447756.html)
