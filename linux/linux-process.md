
# 进程
##  查看进程确切启动时间

```shell
ps -eO lstart
```

## 查看进程数


```shell
[root@localhost cron.hourly]# pstree
init─┬─.sshd───{.sshd}
     ├─7───3*[{7}]
     ├─abrtd
     ├─acpid
     ├─atd
     ├─auditd───{auditd}
     ├─automount───4*[{automount}]
     ├─5*[bjtpdnodbk]
     ├─catalina.sh───java───822*[{java}]
     ├─certmonger
     ├─console-kit-dae───63*[{console-kit-da}]
     ├─crond
     ├─cronolog
     ├─cupsd
     ├─dbus-daemon
     ├─hald─┬─hald-runner─┬─hald-addon-acpi
     │      │             └─hald-addon-inpu
     │      └─{hald}
     ├─irqbalance
     ├─mcelog
     ├─memcached───5*[{memcached}]
     ├─6*[mingetty]
     ├─mysqld_safe───mysqld───72*[{mysqld}]
     ├─rhsmcertd
     ├─rpc.statd
     ├─rpcbind
     ├─rsyslogd───3*[{rsyslogd}]
     ├─sshd─┬─sshd───bash───pstree
     │      ├─sshd───bash
     │      └─2*[sshd───sftp-server]
     ├─tty───8*[{tty}]
     └─udevd───2*[udevd]
```

## 停止进程运行

```shell
kill -STOP 16621
```

## 结束进程

```shell
jps | grep appname | awk '{print $1}' | xargs kill -9
ps axu |grep gradle |grep -v grep |  awk '{print $2}' | xargs kill -9
pgrep appname | xargs kill -9
```
