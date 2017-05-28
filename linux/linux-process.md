
# 进程
##  查看进程确切启动时间

```shell
ps -eO lstart
```

## 结束进程

```shell
jps | grep appname | awk '{print $1}' | xargs kill -9
ps axu |grep gradle |grep -v grep |  awk '{print $2}' | xargs kill -9
pgrep appname | xargs kill -9
```
