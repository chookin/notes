管理iDRAC卡，可以使用自带SSH中的命令行来执行开机、关机、重启等命令，具体参考dell的手册，以下是摘出来对电源部分的控制命令，个人觉得目前也就这个比较有用。

服务器电源管理

语法

使用 SSH 界面登录 iDRAC

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
