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
# rar解压缩软件
iZip unarchiver app store安装。

# Wunderlist
Wunderlist is a simple to­do list and task manager app that helps you get stuff done. Whether you’re sharing a grocery list with a loved one, working on a project, or planning a vacation, Wunderlist makes it easy to capture, share, and complete your to­dos. Wunderlist instantly syncs between your phone, tablet and computer, so you can access all your tasks from anywhere.

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

# VirtualBox
[VirtualBox](https://www.virtualbox.org/wiki/Downloads)
安装virtualbox和VirtualBox Extension Pack。
在菜单【VirtualBox】，点击【偏好配置】，在“网络”页面添加nat和hostonly的网卡。

## 安装windows
在网络配置中，选择”网络地址转换(NAT)”即可。USB选择USB3.0.
在共享文件夹配置中添加共享文件夹。

win7密钥 KH2J9-PC326-T44D4-39H6V-TVPBY
虚机屏幕全屏的办法：登录虚机，之后，在虚机的菜单栏【设备】,点击【安装增强功能...】
启用共享文件夹的方法：登录虚机，在文件夹窗口，右键点击”计算机“，选择”映射网络驱动器(N)...“,进入”映射网络驱动器“窗口，点击”浏览“，选择宿主机所共享的文件夹路径即可。
虚机连接USB设备：首先需要在宿主机中”推出“，之后，在虚机的菜单栏【设备】|【USB】勾选相应的USB即可。注意：虚机选用usb3.0很可能识别不了u盘，建议选用usb2.0.

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
# note
不好用的软件
foxmail
数据文件夹 /Users/你的用户/Library/Containers/com.tencent.Foxmail/Data/Library/Foxmail/Profiles/
