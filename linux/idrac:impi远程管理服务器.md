# idrac

idrac是dell服务器的远程管理口。

## 简介

管理iDRAC卡，可以使用自带SSH中的命令行来执行开机、关机、重启等命令，具体参考dell的手册，以下是摘出来对电源部分的控制命令，个人觉得目前也就这个比较有用。

## 默认信息

远程控制卡在R720型号上是默认开启的，有初始化的IP地址，用户名，密码，估计每个型号的DELL服务器初始化信息不一致，具体可以和DELL沟通。
R720型号的远程控制卡的默认IP是192.168.0.120，用户名是root,密码是calvin，通过https://192.168.0.120/index.html登录进去后，别忘记修改密码。

## ssh连接

服务器电源管理

语法

使用 SSH 登录 iDRAC

>ssh 192.168.0.120
>login: root
>password:

关闭服务器的电源

->stop /system1
system1 已成功停止

将服务器从电源关闭状态打开

->start /system1
system1 已成功启动

重新引导服务器

->reset /system1
system1 已成功重设



完成！

## 浏览器访问

在浏览器中输入idrac地址。

若需要启动远程控制台，则firefox浏览器，打开`viewer.jnlp`：在打开程序中选择`javaws`

http://download.oracle.com/otn-pub/java/jdk/8u121-b13/e9e7ea248e2c4826b92b3f075a80e441/jdk-8u121-linux-x64.tar.gz?AuthParam=1489730794_a542669b868af469e662897146a3c478

其中，低版本的java可能打不开，高版本的也打不开

https://www.java.com/en/download/help/java_blocked.xml
> Why are Java applications blocked by your security settings with the latest Java?
> Java has further enhanced security to make the user system less vulnerable to external exploits. Starting with Java 7 Update 51, Java does not allow users to run applications that are not signed (unsigned), self-signed (not signed by trusted authority) or that are missing permission attributes.
> 解决办法：对于linux服务器，执行`ControlPanel`命令，在`Security`页面，配置`Execption Site List`，例如添加`http://172.31.238.219`，之后点击`Apply`生效。
> 然后，命令行执行`javaws Downloads/jviewer.jnlp`或者浏览器打开。

火狐和java的版本如下，

```shell
[zhuyin@lab21 ~]$ firefox -v
Mozilla Firefox 45.8.0
[root@lab21 ~]# java -version
java version "1.8.0_121"
Java(TM) SE Runtime Environment (build 1.8.0_121-b13)
Java HotSpot(TM) 64-Bit Server VM (build 25.121-b13, mixed mode)
```

> Dell iDRAC Service Module 2.3 (For Linux)
> The iDRAC (Integrated Dell Remote Access Controller) Service Module is a lightweight optional software application that can be installed on Dell 12th Generation Server or greater with iDRAC.
> It complements iDRAC interfaces – Graphical User Interface (GUI), Remote Access Controller Admin (RACADM) CLI and Web Service Management (WSMAN) with additional monitoring data.

http://www.dell.com/support/home/cn/zh/cndhs1/Drivers/DriversDetails?driverId=9YVPK

# ipmi

ipmi是曙光服务器的远程管理口。

曙光A620r-G 默认idrac地址 http://192.168.100.101 用户名和密码，默认ADMIN/ADMIN

曙光 A840r-G 默认用户名和密码 root/superuser

# ipmitool

ipmitool 是一种可用在 linux 系统下的命令行方式的 ipmi 平台管理工具，它支持 ipmi 1.5 规范（最新的规范为 ipmi 2.0），通过它可以实现获取传感器的信息、显示系统日志内容、网络远程开关机等功能。

## 安装

查看服务器支持的ipmi协议版本。

```shell
[root@lab07 ~]# dmidecode |sed -n '/IPMI/,+5p'
IPMI Device Information
        Interface Type: KCS (Keyboard Control Style)
        Specification Version: 2.0
        I2C Slave Address: 0x10
        NV Storage Device: Not Present
        Base Address: 0x0000000000000CA2 (I/O)
```


```shell
 yum install ipmitool
 # 或者
 yum install OpenIPMI-tools
```

## 载入功能模块

安装好了之后，还有一步要做的就是载入支持 ipmi 功能的系统模块。

对于dell服务器是需要：

```shell
modprobe ipmi_devintf
```

对于曙光服务器是需要：

```shell
modprobe ipmi_msghandler
modprobe ipmi_devintf
modprobe ipmi_si
```

## 具体命令

查看ipmi信息

```shell
[root@lab21 ~]# ipmitool mc info
Device ID                 : 32
Device Revision           : 1
Firmware Revision         : 2.41
IPMI Version              : 2.0
Manufacturer ID           : 674
Manufacturer Name         : DELL Inc
Product ID                : 256 (0x0100)
Product Name              : Unknown (0x100)
Device Available          : yes
Provides Device SDRs      : yes
Additional Device Support :
    Sensor Device
    SDR Repository Device
    SEL Device
    FRU Inventory Device
    IPMB Event Receiver
    Bridge
    Chassis Device
Aux Firmware Rev Info     :
    0x00
    0x07
    0x28
    0x28
```

### 设置网络

```shell
# 设置ip
[root@lab07 ~]# ipmitool lan set 1 ipaddr 172.31.238.214
Setting LAN IP Address to 172.31.238.214
# 设置掩码
[root@lab07 ~]# ipmitool  lan  set 1  netmask 255.255.255.0
Setting LAN Subnet Mask to 255.255.255.0
# 必须执行这一步，否则网关设置失败
ipmitool lan set 1 ipsrc static
# 设置网关
[root@lab07 ~]# ipmitool lan set 1 defgw ipaddr 172.31.238.254
Setting LAN Default Gateway IP to 172.31.238.254
```

### 查看网络

```shell
# ipmitool lan print
Set in Progress         : Set Complete
Auth Type Support       : MD5
Auth Type Enable        : Callback : MD5
                        : User     : MD5
                        : Operator : MD5
                        : Admin    : MD5
                        : OEM      :
IP Address Source       : Static Address
IP Address              : 172.31.238.121
Subnet Mask             : 255.255.255.0
MAC Address             : 18:fb:7b:a2:99:a5
SNMP Community String   : public
IP Header               : TTL=0x40 Flags=0x40 Precedence=0x00 TOS=0x10
BMC ARP Control         : ARP Responses Enabled, Gratuitous ARP Disabled
Gratituous ARP Intrvl   : 2.0 seconds
Default Gateway IP      : 172.31.238.254
Default Gateway MAC     : 00:00:00:00:00:00
Backup Gateway IP       : 0.0.0.0
Backup Gateway MAC      : 00:00:00:00:00:00
802.1q VLAN ID          : Disabled
802.1q VLAN Priority    : 0
RMCP+ Cipher Suites     : 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14
Cipher Suite Priv Max   : Xaaaaaaaaaaaaaa
                        :     X=Cipher Suite Unused
                        :     c=CALLBACK
                        :     u=USER
                        :     o=OPERATOR
                        :     a=ADMIN
                        :     O=OEM
```

若报错：`Could not open device at /dev/ipmi0 or /dev/ipmi/0 or /dev/ipmidev/0: No such file or directory`
则尝试载入功能模块：

```shell
modprobe ipmi_devintf
```

### 查看设备状态

```sh
[root@lab07 ~]# ipmitool -L user sensor list | less
CPU1 Temperature | 15.000     | degrees C  | ok    | 0.000     | 0.000     | 0.000     | 70.000    | 75.000    | 80.000
CPU2 Temperature | 15.000     | degrees C  | ok    | 0.000     | 0.000     | 0.000     | 70.000    | 75.000    | 80.000
TR1 Temperature  | 0.000      | degrees C  | nr    | 0.000     | 0.000     | 0.000     | 60.000    | 70.000    | 80.000
TR2 Temperature  | 0.000      | degrees C  | nr    | 0.000     | 0.000     | 0.000     | 60.000    | 70.000    | 80.000
...
```

ipmi获取不到磁盘的状况，需要使用MegaCli。

- [一篇文章全面了解监控知识体系](http://www.yunweipai.com/archives/13243.html)
- [基于Zabbix IPMI监控服务器硬件状况](http://www.jianshu.com/p/819d5fea1cfa)
- [基于Zabbix IPMI监控服务器硬件状况](http://pengyao.org/zabbix-monitor-ipmi-1.html)

### 更改用户密码

```shell
[root@lab21 ~]# ipmitool user list 1
ID  Name             Callin  Link Auth  IPMI Msg   Channel Priv Limit
2   root             true    true       true       ADMINISTRATOR
[root@lab21 ~]# ipmitool user set password 1 "abc"
Set User Password command failed (user 1): Invalid data field in request
[root@lab21 ~]# ipmitool user set password 2 "Jsrcdj_Ywsyxjzy1"
```

## 参考

- [利用ipmi更改本机自带的idrac](http://nosmoking.blog.51cto.com/3263888/1696017/)
- [ipmitool 对linux服务器进行IPMI管理](https://my.oschina.net/davehe/blog/88801?from=rss)
