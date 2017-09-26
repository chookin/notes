[TOC]
os max os 10.12.2

# brew

http://brew.sh
安装`/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`

brew 安装的软件存放在 /usr/local/Cellar 中，同时会在 /usr/local/bin, /usr/local/sbin, /usr/local/lib 中创建链接。

```shell
brew install wget
```

卸载

```shell
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)"
```

常见问题
1，

```
$ brew update
Error: /usr/local must be writable!
```

解决办法

```shell
sudo chown -R $(whoami) /usr/local
```

2, `brew update`慢
删了brew，再重装

3,brew install 下载慢
找到brew下载文件的目录，将刚才下载的文件移动到目录

```
# cd `brew --cache`
 //进入brew的下载目录
# rm go-1.6.2.el_capitan.bottle.tar.gz
 //删除刚才下载一半的文件
# mv /Downloads/go-1.6.2.el_capitan.bottle.tar.gz ./
//将下载好的压缩包放到brew下载目录
```

# zsh

https://github.com/robbyrussell/oh-my-zsh
Oh My Zsh is installed by running one of the following commands in your terminal. You can install this via the command-line with either curl or wget.

via curl

```sh
# yum install -y zsh git
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```

配置文件`~/.zshrc`

1， vi报错

```
(eval):1: _vim: function definition file not found
(eval):1: _vim: function definition file not found
(eval):1: _vim: function definition file not found
```
解决办法

```sh
rm $ZSH_COMPDUMP
exec zsh
```

# vi

## 配置文件
编辑文件~/.vimrc，添加如下内容

```
set nu
set ai                  " auto indenting
set history=500         " keep 100 lines of history
set ruler               " show the cursor position
syntax on               " syntax highlighting
set hlsearch            " highlight the last searched term
filetype plugin on      " use the file type plugins
" 自动对起，也就是把当前行的对起格式应用到下一行
set autoindent
" 依据上面的对起格式，智能的选择对起方式
set smartindent
set tabstop=4
set shiftwidth=4
set showmatch

" 当vim进行编辑时，如果命令错误，会发出一个响声，该设置去掉响声
set vb t_vb=


" When editing a file, always jump to the last cursor position
autocmd BufReadPost *
\ if ! exists("g:leave_my_cursor_position_alone") |
\ if line("'\"") > 0 && line ("'\"") <= line("$") |
\ exe "normal g'\"" |
\ endif |
\ endif
```

# iterm2

- 设置字体大小为16。`Preference -> Profiles -> Text tab -> Font`


- 取消退出确认。`Preference -> General -> Closing`

# 控制台terminal

编辑文件`~/.bashrc`.

注意：mac下`~/.bashrc`不起作用

新建` ~/.bash_profile`，在其中加载一次`.bashrc`

```shell
if [ "${BASH-no}" != "no" ]; then
    [ -r ~/.bashrc ] && . ~/.bashrc
fi
```
# sublime text

注册码

```
—– BEGIN LICENSE —–
Michael Barnes
Single User License
EA7E-821385
8A353C41 872A0D5C DF9B2950 AFF6F667
C458EA6D 8EA3C286 98D1D650 131A97AB
AA919AEC EF20E143 B361B1E7 4C8B7F04
B085E65E 2F5F5360 8489D422 FB8FC1AA
93F6323C FD7F7544 3F39C318 D95E6480
FCCC7561 8A4A1741 68FA4223 ADCEDE07
200C25BE DBBC4855 C4CFB774 C5EC138C
0FEC1CEF D9DCECEC D3A5DAD1 01316C36
—— END LICENSE ——
```

如果想要在命令行中启动Sublime Text，需要在终端执行一下命令：

```shell
ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" /usr/local/bin/subl
```

package 路径

```
/Users/chookin/Library/Application\ Support/Sublime\ Text\ 3/
```



- [Sublime Text 快捷键](https://github.com/liveNo/Sublime-Tutorial?hmsr=toutiao.io&utm_medium=toutiao.io&utm_source=toutiao.io)

# 开发工具

## jdk

JDK7，JDK8则需要自己到Oracle官网下载安装对应的版本。自己安装的JDK默认路径为：/Library/Java/JavaVirtualMachines/jdk1.8.0_73.jdk
[jdk1.7](http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html)
[jkd1.8](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)

安装多个版本的jdk

1. 下载并安装mac版的jdk。

2. 在用户目录下的bash配置文件.bashrc中配置JAVA_HOME的路径（具体路径与实际版本号有关）

```shell
jdk7() {
    export JAVA_7_HOME=/Library/Java/JavaVirtualMachines/jdk1.7.0_79.jdk/Contents/Home
    export JAVA_HOME=$JAVA_7_HOME
    export CLASSPATH="$JAVA_HOME/lib:$JAVA_HOME/jre/lib:$CLASSPATH"
    export PATH=$JAVA_HOME/bin:$PATH
}

jdk8() {
    export JAVA_8_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_91.jdk/Contents/Home
    export JAVA_HOME=$JAVA_8_HOME
    export CLASSPATH="$JAVA_HOME/lib:$JAVA_HOME/jre/lib:$CLASSPATH"
    export PATH=$JAVA_HOME/bin:$PATH
}

jdk7
```

上述配置jdk为1.7的，若要切换到1.8，执行如下命令即可：

```shell
jdk8
```

问题：

- 代码编译报错

```
 no suitable method found for collect(java.util.stream.Collector<java.lang.Object,capture#1 of ?,java.util.List<java.lang.Object>>)
```

解决办法，升级jdk 到版本8u40及以上 [Bogus "no suitable method found" error from javac](https://bugs.openjdk.java.net/browse/JDK-8051443)

## maven

在mac中使用brew安装，配置文件没有找到，因此采用下载安装包的方式。

## idea

访问 http://idea.lanyus.com 获取激活码

选择license server

- http://15.idea.lanyus.com 已不可用

- http://idea.qinxi1992.cn



- [IntelliJ IDEA 2016.1破解码一枚](http://aiyougege.com/articles/022711.html)

### 配置

- Appearance, UI Options, do Override default fonts by... and choose Name of 'Monaco' and size of '16'
- check use soft wraps in console
- show line numbers
- change font 'Monaco' and size 16, and set Line spacing to '1.2'
- mark modified tabs with asterisk
- code completion.
  - check case sensitive completion, set to `none`
  - uncheck sort lookup items lexicographically
  - check insert selected variant by typing dot...
  - check autopopup and change to 200 ms
- 智能提示忽略大小写 [Editor]|[Code Completion]，选择`Case sensitive completion`为`None`；

如果`todo`不能自动提示添加`TODO:`那么需要做如下配置：
- todo search 'todo', in live templates,
  - confirm 'edit variables': 'date' expression is `date()` and 'skip if defined' is checked.
  - 'Applicable in java', change to: statement, expression, declaration, comment and smart type completion for java.

### 常用操作

- 快捷键 https://resources.jetbrains.com/assets/products/intellij-idea/IntelliJIDEA_ReferenceCard_mac.pdf
- 为了使得能自动加载本地的包，需要配置idea,执行更新maven的Repositories. [Build, Execution, Deployment]|[Build Tools]|[Maven]|[Repositories]，选择本地的repository，点击`update`按钮。
- 查看注释：Win: Ctrl+Q, Mac: Control+J
- 统计代码函数，安装插件statistics，之后【View】|【Tool Windows】|【statistics】
- 为java程序设置 -D command-line option：【Run】|【Edit Configurations...】，在“VM options"中输入参数，如"-Daction=baidu"

### 插件
- GsonFormat Java开发中，经常有把json格式的内容转成Object的需求，[GsonFormat](https://plugins.jetbrains.com/plugin/7654?pr=)这款插件可以实现该功能。
- FindBugs-IDEA
- CheckStyle 通过检查对代码编码格式，命名约定，Javadoc，类设计等方面进行代码规范和风格的检查，从而有效约束开发人员更好地遵循代码编写规范。

### 常见问题

- `Error:java: Compilation failed: internal java compiler error`
> 配置 [Preferences...]|[Build,Execution,Deployment]|[Compiler]|[Java Compiler]，为出问题的module设置`Target bytecode version`（或者设置`Project bytecode version`，然后删除具体的module配置即可）。

## android studio

[Android ButterKnife Zelezny插件的安装与使用
](http://blog.csdn.net/dreamlivemeng/article/details/51261170)

[ButterKnifeZelezny](https://github.com/avast/android-butterknife-zelezny)插件功用：一键从布局文件中生成对于的 View 声明和 ButterKnife 注解。

在线安装：File-->settings-->Plugins-->Browse repositories-->然后再输入框输入ButterKnife Zelezny并搜索-->install-->restart Android studio（安装后重启生效）

在需要导入注解的Activity或者fragment或者ViewHolder资源片段的layout地方（例如Activity里面，一定要把鼠标移到oncreate的 setContentView(R.layout.activity_main);的R.layout.activity_main这个位置,把鼠标光标移到上去。右击选择Generate 再选择Generate ButterKnife Injections

代码统计：
最近想查看Android studio项目的代码行数，查看了半天发现了一个比较不错的android studio插件：statistic；
官方网址：https://plugins.jetbrains.com/plugin/4509
在官网上下载jar包就好了，然后打开android studio-->setting->Plugins->Install plugin from disk....


# 实用工具

## SecureCRT

用于远程ssh连接。

更改字体、默认编码

```
在出现的“Global Options”选项卡中，选择“Default Session”选项，再选择右边一栏中的“Edit Default Settings”按钮。字体选择“couriew 18pt"，Character encoding选择“UTF-8"。之后重启 SecureCRT
```

破解3.7.x 版本

`sudo perl ~/Downloads/securecrt_mac_crack.pl /Applications/SecureCRT.app/Contents/MacOS/SecureCRT`
生成序列号信息。
之后，打开secureCRT，输入license，选择手动依次输入。

问题
无法保存密码

```
打开secureCRT，菜单preferences--general，找到mac options。然后去掉Use KeyChain选项，这样每次连接服务器后就会自动保存密码了。不同的版本可能这个选项的位置不同，只要记住勾选掉Use keyChain选项就可以了。
```

配置：

- Session Options | Terminal | Emulation, 选择为`linux`，并选中Ansi color;
- Global Options | Terminal，Mouse, paste on right button.
- Global Options | Terminal | Emulation，Maximum columns 256，当只显示一部分宽度时。
- Global Options | Terminal | Appearance，选择 color scheme为`Traditional`
- Global Options | Terminal | Appearance，字体选择utf8。
- Global Options | Terminal | Appearance | Advanced，配置`Window transparency`，用于设置securt半透明；


## vnc-veviewer

用于远程连接vnc服务器。

```
$ brew search vnc
vncsnapshot                              x11vnc
homebrew/x11/tiger-vnc                   Caskroom/cask/tigervnc-viewer
Caskroom/cask/jollysfastvnc              Caskroom/cask/vnc-viewer
Caskroom/cask/real-vnc
$ brew install Caskroom/cask/tigervnc-viewer
==> brew cask install Caskroom/cask/tigervnc-viewer
==> Downloading https://bintray.com/artifact/download/tigervnc/stable/TigerVNC-1
Already downloaded: /Library/Caches/Homebrew/tigervnc-viewer-1.6.0.dmg
==> Verifying checksum for Cask tigervnc-viewer
==> Symlinking App 'TigerVNC Viewer 1.6.0.app' to '/Users/chookin/Applications/T
🍺  tigervnc-viewer staged at '/opt/homebrew-cask/Caskroom/tigervnc-viewer/1.6.0' (6 files, 3.9M)
```

## cheatsheet

用于长按command键调出当前软件的快捷键列表。

## charles

用于网路抓包。

### 配置

打开Charles的代理设置：Proxy->Proxy Settings，设置一下端口号，默认的是8888，这个只要不和其他程序的冲突即可,并且勾选Enable transparent HTTP proxying

手机连接上和电脑在同一局域网的wifi上，设置wifi的HTTP代理。代理地址是电脑的ip，端口号就是刚刚在Charles上设置的那个。
查看mac电脑ip

```shell
$ ifconfig | grep broadcast
  inet 192.168.1.101 netmask 0xffffff00 broadcast 192.168.1.255
```

### 参考

- [抓包工具Charles的使用心得](http://www.jianshu.com/p/fdd7c681929c)
- [Mac下使用Charles实现对Android手机进行抓包](http://bo1.me/2015/04/01/charles-android/)

## paw

http://xclient.info/s/paw.html
Paw 是一款Mac上实用的HTTP/REST服务测试工具，完美兼容最新的OS X El Capitan系统，Paw可以让Web开发者设置各种请求Header和参数，模拟发送HTTP请求，测试响应数据，支持OAuth, HTTP Basic Auth, Cookies，JSONP等，这对于开发Web服务的应用很有帮助，非常实用的一款Web开发辅助工具。

## jadx

android apk反编译
https://github.com/skylot/jadx

[jadx 反编译apk - 简书](http://www.jianshu.com/p/b7166f196800)
[jadx:更好的Android反编译工具](https://liuzhichao.com/2016/jadx-decompiler.html)

安装

```shell
git clone https://github.com/skylot/jadx.git
cd jadx
./gradlew dist
```

## jd-gui

反编译jar.

https://github.com/java-decompiler/jd-gui

http://jd.benow.ca

JD-GUI is a standalone graphical utility that displays Java source codes of “.class” files. You can browse the reconstructed source code with the JD-GUI for instant access to methods and fields.
配置：

```
ulimit -c unlimited
```

## LICEcap

[LICEcap](http://www.cockos.com/licecap/) 是一款免费的屏幕录制工具，支持导出 GIF 动画图片格式，轻量级、使用简单，录制过程中可以随意改变录屏范围。

## Adapter
[Adapter](https://macroplant.com/adapter)是一款视频、音频、图片格式转换工具，支持预览、批量混合处理以及剪裁.

## Tuxera Disk Manager

mac读写ntfs格式磁盘。

# 常用网址

- [google的镜像站](http://guge.suanfazu.com)
- [What's My User Agent?](http://whatsmyuseragent.com)
- [MVN repository](http://mvnrepository.com)

# 不好用的软件

## macdown

[MacDown](http://macdown.uranusjr.com) is an open source Markdown editor for OS X, released under the MIT License. It is heavily influenced by Chen Luo’s Mou.

```shell
brew cask install macdown
```

导出的html中，代码段无法自动换行，解决办法：

若使用css 'Github2'，则通过点击 Preferences | Rendering | CSS Reveal, 打开Styles/Github2.css文件，在文件末尾追加如下内容并保存，重启macdown即可。

```css
div pre code {
    white-space: pre-line !important;
}
```

不太好用，卸载了吧！

```shell
$ brew cask uninstall macdown
==> Removing App symlink: '/Users/chookin/Applications/MacDown.app'
==> Removing Binary symlink: '/usr/local/bin/macdown'
```

# 常见问题

（1）mac下~/.bashrc不起作用
新建 ~/.bash_profile，在其中加载一次.bashrc

```shell
if [ "${BASH-no}" != "no" ]; then
    [ -r ~/.bashrc ] && . ~/.bashrc
fi
```

参考
- [](https://my.oschina.net/shede333/blog/470377)
