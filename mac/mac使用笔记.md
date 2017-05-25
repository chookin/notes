设置root初始密码,以管理员账户执行如下命令

```shell
sudo passwd root
```

# 基本操作

## 配置开机自启动
- 点击苹果电脑桌面左上角的小苹果图标，打开系统偏好设置窗口；
- 窗口左下角打开用户与群组；
- 在进入的新窗口中，左侧需要需要用户，右侧标签页选择登录项，如果你想取消某个应用程序开机启动，只需要选中他，然后点下面的减号。

## 权限

### 禁用guest账户

```
系统偏好设置 -> 用户与群组
```

### 屏保需输入密码

```
系统偏好设置 -> 安全性与隐私 -> 通用
```

## 共享

- 打开蓝牙共享
- 修改计算机名称

```
系统偏好设置 -> 共享
```

## 文件

### finder

直接在 Finder 中按快捷键 command+/。这个快捷键其实就相当于点击菜单栏中的显示——显示状态栏，按下这个快捷键之后，你会发现 Finder 的最下面多除了一条“状态栏”，其中就会显示剩余磁盘空间（左侧边栏不要选择“我的所有文件”和“AirDrop”）。

配置为打开finder时不打开“我的所有文件”：

- Finder偏好设置 | 通用 | 开启新Finder窗口时打开“” 调整为其他的，例如“文稿”即可。

### DS_Store

DS_Store是Mac OS保存文件夹的自定义属性的隐藏文件，如文件的图标位置或背景色，相当于Windows的desktop.ini。
1，禁止.DS_store生成：打开   “终端” ，复制黏贴下面的命令，回车执行，重启Mac即可生效。

    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool TRUE
2，恢复.DS_store生成：

    defaults delete com.apple.desktopservices DSDontWriteNetworkStores
### 移动硬盘的挂载路径

/Volumes/

### 文件检索

mdfind 是 Spotlight 的命令行

```shell
mdfind -name [target_file_name_part1] [target_file_name_part2] -onlyin [target_dir]
```

由于索引的限制，`mdfind`搜索对象不支持正则表达式，不过这几个应该够用：

```
mdfind ''str1 str2" 表示str1和str2同时出现

mdfind "str1|str2" 表示str1和str2出现一个

mdfind "str1-str2 表示出现str1但不出现str2
```

一步到位的执行命令

```shell
mdfind -name keepalived doc | xargs open
```

[个不可不知的Mac OS X专用命令行工具](https://segmentfault.com/a/1190000000509514)

## 网络

### 翻墙

访问google,不需要使用翻墙软件，配置hosts即可。之后就可以正常访问https://www.google.com.hk
https://github.com/highsea/Hosts/blob/master/hosts
https://github.com/racaljk/hosts/blob/master/hosts#L2

- [mac修改host文件，让你的mac轻松上google](http://www.liubingyang.com/like/host-google-mac.html)

# 应用软件

## QQ

- 同步通讯录

把聊天记录的QQ文件夹整个复制替换新电脑里的，打开QQ后一切都过来了。mac中的路径为：

    ~/Library/Containers/com.tencent.qq/Data/Library/Application Support/QQ/
## iZip unarchiver

rar解压缩软件。app store安装。

## Wunderlist
奇妙清单 Wunderlist is a simple to­do list and task manager app that helps you get stuff done. Whether you’re sharing a grocery list with a loved one, working on a project, or planning a vacation, Wunderlist makes it easy to capture, share, and complete your to­dos. Wunderlist instantly syncs between your phone, tablet and computer, so you can access all your tasks from anywhere.

注册账号 469308668@qq.com


# 文件操作

## 更改文件的默认打开方式
右键点击你要修改地文件显示简介打开方式选择了新的程序之后全部更改.

## 打开mht文件
在MAC下查看MHT文件About how to open mht files on a mac. MHT是IE (PC)下保存网页的文件，有很多人说直接拖到OPERA下就行，但由于很多页面不兼容OPERA内容可能无法显示。后来找到FIREFOX和SAFARI的插件，用起来更顺手一些。

打开firefox, 输入地址：http://www.unmht.org/en_index.html 点击 unmht-5.2.0.xpi （或最新版本）。会提示安装（install），然后自动重启后就行了。直接拖文件到ff图标下无法打开，需要先打开ff然后拖文件到浏览器就可以看了。

## terminal打开当前路径文件夹
`open .`


## Microsoft Office 2016
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

还有一种更好的方法，利用iconv把文件转为GB18030格式：
```shell
iconv  -f UTF-8 -t GB18030 apps_2016-06-04.csv  > apps.csv
```

iconv有如下选项可用:

    -f, --from-code=名称 原始文本编码
    -t, --to-code=名称 输出编码

    -l, --list 列举所有已知的字符集

    -c 从输出中忽略无效的字符
    -o, --output=FILE 输出文件
    -s, --silent 关闭警告
    --verbose 打印进度信息


## VirtualBox
[VirtualBox](https://www.virtualbox.org/wiki/Downloads)
安装virtualbox和VirtualBox Extension Pack。
在菜单【VirtualBox】，点击【偏好配置】，在“网络”页面添加nat和hostonly的网卡。

## 安装windows虚拟机
在网络配置中，选择”网络地址转换(NAT)”即可。USB选择USB2.0(注意：虚机选用usb3.0很可能识别不了u盘，建议选用usb2.0).
在共享文件夹配置中添加共享文件夹。

win7密钥 KH2J9-PC326-T44D4-39H6V-TVPBY
虚机屏幕全屏的办法：登录虚机，之后，在虚机的菜单栏【设备】,点击【安装增强功能...】
启用共享文件夹的方法：登录虚机，在文件夹窗口，右键点击”计算机“，选择”映射网络驱动器(N)...“,进入”映射网络驱动器“窗口，点击”浏览“，选择宿主机所共享的文件夹路径即可。
虚机连接USB设备：首先需要在宿主机中”推出“，之后，在虚机的菜单栏【设备】|【USB】勾选相应的USB即可。

# 开发环境

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
    du -sm * | sort -n //统计当前目录大小 并安大小 排序

# note
不好用的软件
foxmail
数据文件夹 /Users/你的用户/Library/Containers/com.tencent.Foxmail/Data/Library/Foxmail/Profiles/


## mindnode
http://xclient.info/s/mind-node-pro.html
本站所有dmg、zip 打开密码均为 xclient.info

打开时提示文件已损坏的解决办法：
修改系统偏好设置，允许安装其他来源的app.


## Timing 1.7 时间分析统计工具
Timing 的使用方法很简单，你只需要开着它它就会在后台默默的记录着你的操作。当你需要查看汇总时它会列出你在每个程序上的使用时间，而且可以显示出具体在哪些时间段以及对应的时长，而浏览器的话更可以显示你在哪个网站上的浏览时间。

Timing 的左侧是各种程序分类，其默认已经对系统内置程序进行了分类，你可以自行再创建、整理这些分类，使用不同的颜色显示令其更容易查看。
http://xclient.info/s/timing.html

## 番茄土豆
番茄工作法。

## sketch
注册码
SK3-3539-1641-8881-0373-1208

[sketch-chinese-user-manual](http://www.sketchcn.com/sketch-chinese-user-manual.html)

# 常用网站

- [pc6下载站](http://www.pc6.com/mac/soft/)
