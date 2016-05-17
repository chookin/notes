设置root初始密码,以管理员账户执行如下命令
```shell
sudo passwd root
```

# DS_Store
DS_Store是Mac OS保存文件夹的自定义属性的隐藏文件，如文件的图标位置或背景色，相当于Windows的desktop.ini。
1，禁止.DS_store生成：打开   “终端” ，复制黏贴下面的命令，回车执行，重启Mac即可生效。

    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool TRUE
2，恢复.DS_store生成：

    defaults delete com.apple.desktopservices DSDontWriteNetworkStores
# QQ
同步通讯录
把聊天记录的QQ文件夹整个复制替换新电脑里的，打开QQ后一切都过来了。mac中的路径为：

    ~/Library/Containers/com.tencent.qq/Data/Library/Application Support/QQ/

# 移动硬盘的挂载路径
/Volumes/

# rar解压缩软件
iZip unarchiver app store安装。

# Wunderlist
Wunderlist is a simple to­do list and task manager app that helps you get stuff done. Whether you’re sharing a grocery list with a loved one, working on a project, or planning a vacation, Wunderlist makes it easy to capture, share, and complete your to­dos. Wunderlist instantly syncs between your phone, tablet and computer, so you can access all your tasks from anywhere.

# 文件操作

## 打开mht文件
在MAC下查看MHT文件About how to open mht files on a mac. MHT是IE (PC)下保存网页的文件，有很多人说直接拖到OPERA下就行，但由于很多页面不兼容OPERA内容可能无法显示。后来找到FIREFOX和SAFARI的插件，用起来更顺手一些。

打开firefox, 输入地址：http://www.unmht.org/en_index.html 点击 unmht-5.2.0.xpi （或最新版本）。会提示安装（install），然后自动重启后就行了。直接拖文件到ff图标下无法打开，需要先打开ff然后拖文件到浏览器就可以看了。

## terminal打开当前路径文件夹
`open .`


# Microsoft Office 2016
破解

    $ chmod +x /Users/chookin/百度云同步盘/Microsoft\ Office\ 2016\ for\ Mac\ 15.12.3/MSO15.11.2Patch
    $ /Users/chookin/百度云同步盘/Microsoft\ Office\ 2016\ for\ Mac\ 15.12.3/MSO15.11.2Patch
    Patching Microsoft Office Outlook...
    Password:
    /Applications/Microsoft Outlook.app/Contents/Frameworks/MicrosoftSetupUI.framework: replacing existing signature
    Patching Microsoft Office Word...
    /Applications/Microsoft Word.app/Contents/Frameworks/MicrosoftSetupUI.framework: replacing existing signature
    Patching Microsoft Office Excel...
    /Applications/Microsoft Excel.app/Contents/Frameworks/MicrosoftSetupUI.framework: replacing existing signature
    Patching Microsoft Office PowerPoint...
    /Applications/Microsoft PowerPoint.app/Contents/Frameworks/MicrosoftSetupUI.framework: replacing existing signature
    Credits go to darkvoid.
    All done! Enjoy! :)

导入utf-8编码的中文csv文件乱码问题：
- 首先使用sublime打开该csv文件，将文件转为GBK编码（需要sublime装convert to utf8插件），【File】|【Set File Encoding to】|【Chinese Simplified(GBK)】。
- 之后，打开office excel，新建一个空白文档，选择【文件】|【导入...】，选择已转码后的csv文件，在“文件原始格式”处，选择Chinese(GB 18030)。

# VirtualBox
[VirtualBox](https://www.virtualbox.org/wiki/Downloads)
安装virtualbox和VirtualBox Extension Pack。
在菜单【VirtualBox】，点击【偏好配置】，在“网络”页面添加nat和hostonly的网卡。

## 安装windows
在网络配置中，选择”网络地址转换(NAT)”即可。USB选择USB2.0(注意：虚机选用usb3.0很可能识别不了u盘，建议选用usb2.0).
在共享文件夹配置中添加共享文件夹。

win7密钥 KH2J9-PC326-T44D4-39H6V-TVPBY
虚机屏幕全屏的办法：登录虚机，之后，在虚机的菜单栏【设备】,点击【安装增强功能...】
启用共享文件夹的方法：登录虚机，在文件夹窗口，右键点击”计算机“，选择”映射网络驱动器(N)...“,进入”映射网络驱动器“窗口，点击”浏览“，选择宿主机所共享的文件夹路径即可。
虚机连接USB设备：首先需要在宿主机中”推出“，之后，在虚机的菜单栏【设备】|【USB】勾选相应的USB即可。

# 翻墙
访问google,不需要使用翻墙软件，配置hosts即可。之后就可以正常访问https://www.google.com.hk
https://github.com/highsea/Hosts/blob/master/hosts
https://github.com/racaljk/hosts/blob/master/hosts#L2

参考：

- [mac修改host文件，让你的mac轻松上google](http://www.liubingyang.com/like/host-google-mac.html)

# 操作笔记

    重命名文件 点击“回车键”
    剪切文件 先“cmd+c“,之后，到目标文件夹，执行"option+cmd+v"。
    待机  control + shift + 电源键
    关机  control + option + cmd + 电源键 或者 Control + 关机键，弹出 关机菜单， 点击关机
    隐藏dock栏 option + cmd + d
    查看端口    lsof -nP | grep {port}
    创建软连接 ln -s source_file target_file 注意mac系统中文件名是不区分大小写的
    怎么看mht文件    把mht文件作为附件发给自己的qq邮箱，然后点击预览
    修改hostname  sudo scutil --set HostName chookin.mac
    截取全屏 Shift＋Command＋3快捷键组合，即可截取电脑全屏，图片自动保存在桌面
    截取任意窗口：快捷键（Shift＋Command＋4）
        ▲直接按“Shift＋Command＋4“快捷键组合，出现十字架的坐标图标；
        ▲拖动坐标图标，选取任意区域后释放鼠标，图片会自动保存在桌面。
    dock在多屏幕间移动 想要在哪个屏幕使用dock，就在这个屏幕把鼠标移动到最底部即可。
# note
不好用的软件
foxmail
数据文件夹 /Users/你的用户/Library/Containers/com.tencent.Foxmail/Data/Library/Foxmail/Profiles/
