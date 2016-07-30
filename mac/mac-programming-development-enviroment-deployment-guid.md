[TOC]

# brew

http://brew.sh
安装`/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`

brew 安装的软件存放在 /usr/local/Cellar 中，同时会在 /usr/local/bin, /usr/local/sbin, /usr/local/lib 中创建链接。

```shell
brew install wget
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

编辑文件`~/.bashrc`，添加如下内容

```shell
#!/bin/path

export JAVA_7_HOME=/Library/Java/JavaVirtualMachines/jdk1.7.0_79.jdk/Contents/Home
export JAVA_8_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_73.jdk/Contents/Home

export JAVA_HOME=$JAVA_7_HOME
# export JAVA_HOME=$JAVA_8_HOME

export CLASSPATH="$JAVA_HOME/lib:$JAVA_HOME/jre/lib:$CLASSPATH"
export PATH=$JAVA_HOME/bin:$PATH

# alias jdk8='export JAVA_HOME=$JAVA_8_HOME'
# alias jdk7='export JAVA_HOME=$JAVA_7_HOME'

export MYCAT_HOME=$HOME/project/learning/Mycat-Server

export MAVEN_HOME=$HOME/local/apache-maven
export PATH=$MAVEN_HOME/bin:$PATH

export PHANTOM_HOME=$HOME/local/phantomjs
export PATH=$PHANTOM_HOME/bin:$PATH

export CASPER_JS_HOME=$HOME/local/casperjs
export PATH=$CASPER_JS_HOME/bin:$PATH

export GRADLE_HOME=$HOME/local/gradle
export PATH=$GRADLE_HOME/bin:$PATH

# configure terminal color
export CLICOLOR=1 
export LSCOLORS=gxfxaxdxcxegedabagacad 

# 历史命令最大条数
HISTFILESIZE=100000
# 历史命令添加时间戳
HISTTIMEFORMAT="%F %T "
export HISTTIMEFORMAT

alias ll="ls -all"

alias grep='grep --color=auto'

export HOMEBREW_GITHUB_API_TOKEN=4f6d2a0066f2c9de121c9ba775e8be5b8596f0e7
```

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

# 开发工具

## jdk

JDK7，JDK8则需要自己到Oracle官网下载安装对应的版本。自己安装的JDK默认路径为：/Library/Java/JavaVirtualMachines/jdk1.8.0_73.jdk
[jdk1.7](http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html)
[jkd1.8](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)

安装多个版本的jdk

1. 下载并安装mac版的jdk。

2. 在用户目录下的bash配置文件.bashrc中配置JAVA_HOME的路径（具体路径与实际版本号有关）

```shell
export JAVA_7_HOME=/Library/Java/JavaVirtualMachines/jdk1.7.0_79.jdk/Contents/Home
export JAVA_8_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_73.jdk/Contents/Home
export JAVA_HOME=$JAVA_8_HOME
export CLASSPATH="$JAVA_HOME/lib:$JAVA_HOME/jre/lib:$CLASSPATH"
export PATH=$JAVA_HOME/bin:$PATH
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

### idea15激活

选择license server

- http://15.idea.lanyus.com 已不可用

- http://idea.qinxi1992.cn 

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

### 常用操作

- 快捷键 https://resources.jetbrains.com/assets/products/intellij-idea/IntelliJIDEA_ReferenceCard_mac.pdf
- 智能提示忽略大小写 [Editor]|[Code Completion]，选择`Case sensitive completion`为`None`；



- 为了使得能自动加载本地的包，需要配置idea,执行更新maven的Repositories. [Build, Execution, Deployment]|[Build Tools]|[Maven]|[Repositories]，选择本地的repository，点击`update`按钮。
- 查看注释：Win: Ctrl+Q, Mac: Control+J
- 统计代码函数，安装插件statistics，之后【View】|【Tool Windows】|【statistics】
- 为java程序设置 -D command-line option：【Run】|【Edit Configurations...】，在“VM options"中输入参数，如"-Daction=baidu"


### 插件
- GsonFormat Java开发中，经常有把json格式的内容转成Object的需求，[GsonFormat](https://plugins.jetbrains.com/plugin/7654?pr=)这款插件可以实现该功能。
- FindBugs-IDEA
- CheckStyle 通过检查对代码编码格式，命名约定，Javadoc，类设计等方面进行代码规范和风格的检查，从而有效约束开发人员更好地遵循代码编写规范。

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

## paw

http://xclient.info/s/paw.html
Paw 是一款Mac上实用的HTTP/REST服务测试工具，完美兼容最新的OS X El Capitan系统，Paw可以让Web开发者设置各种请求Header和参数，模拟发送HTTP请求，测试响应数据，支持OAuth, HTTP Basic Auth, Cookies，JSONP等，这对于开发Web服务的应用很有帮助，非常实用的一款Web开发辅助工具。

## jd-gui

反编译jar.
http://jd.benow.ca
JD-GUI is a standalone graphical utility that displays Java source codes of “.class” files. You can browse the reconstructed source code with the JD-GUI for instant access to methods and fields.
配置：

```
ulimit -c unlimited
```

## LICEcap

[LICEcap](http://www.cockos.com/licecap/) 是一款免费的屏幕录制工具，支持导出 GIF 动画图片格式，轻量级、使用简单，录制过程中可以随意改变录屏范围。

# DB

## mysql

### 采用brew安装

```shell
brew install mysql # brew方式安装后的软件路径是/usr/local/opt/mysql/，数据文件夹是/usr/local/var/mysql
```
### 配置

```shell
mysqld --help --verbose | more # (查看帮助, 按空格下翻)
```
你会看到开始的这一行(表示配置文件默认读取顺序)

    Default options are read from the following files in the given order:
    /etc/my.cnf /etc/mysql/my.cnf /usr/local/etc/my.cnf ~/.my.cnf
通常这些位置是没有配置文件的, 所以要自己建一个

```shell
# 用这个可以找到样例.cnf
ls $(brew --prefix mysql)/support-files/my-*
# 拷贝到第一个默认读取目录
cp /usr/local/opt/mysql/support-files/my-default.cnf /etc/my.cnf
# 此后按需修改my.cnf
```

### mysql启停
可用使用mysql的脚本启停,也可借助brew

    mysql.server start
    brew services start mysql
    brew services stop mysql

## memcached

安装

```shell
$ brew search memcache
homebrew/php/php53-memcache         homebrew/php/php55-memcache         homebrew/php/php70-memcached        memcacheq
homebrew/php/php53-memcached        homebrew/php/php55-memcached        libmemcached
homebrew/php/php54-memcache         homebrew/php/php56-memcache         memcache-top
homebrew/php/php54-memcached        homebrew/php/php56-memcached        memcached ✔
$ brew install memcached

$ brew info memcached
memcached: stable 1.4.24 (bottled)
High performance, distributed memory object caching system
https://memcached.org/
Conflicts with: mysql-cluster
/usr/local/Cellar/memcached/1.4.24 (12 files, 162.3K) *
  Poured from bottle on 2016-03-04 at 14:15:07
From: https://github.com/Homebrew/homebrew-core/blob/master/Formula/memcached.rb
==> Dependencies
Required: libevent ✔
==> Options
--with-sasl
	Enable SASL support -- disables ASCII protocol!
--with-sasl-pwdb
	Enable SASL with memcached's own plain text password db support -- disables ASCII protocol!
==> Caveats
To have launchd start memcached now and restart at login:
  brew services start memcached
Or, if you don't want/need a background service you can just run:
  /usr/local/opt/memcached/bin/memcached
```

启动

```
cd /usr/local/opt/memcached && nohup bin/memcached -m 2048 -c 8192 -p 11211 >/dev/null 2>> logs/memcached11211.log &
```

# web

## apache

1.启动

`sudo apachectl -k start`

2.重新启动

`sudo apachectl -k restart`

## php
`brew install php`

## phpmyadmin

```
brew install mhash
brew install homebrew/php/phpmyadmin
```
之后，配置apache，添加如下内容到/etc/apache2/httpd.conf文件的末尾处。

```shell
  Alias /phpmyadmin /usr/local/share/phpmyadmin
  <Directory /usr/local/share/phpmyadmin/>
    Options Indexes FollowSymLinks MultiViews
    AllowOverride All
    <IfModule mod_authz_core.c>
      Require all granted
    </IfModule>
    <IfModule !mod_authz_core.c>
      Order allow,deny
      Allow from all
    </IfModule>
  </Directory>
```

修改httpd.conf，找到“#LoadModule php5_module libexec/apache2/libphp5.so”，把前面的#号去掉，以使得apache能处理php页面。

## PhantomJS

[PhantomJS](http://phantomjs.org/download.html) is a headless WebKit scriptable with a JavaScript API. It has fast and native support for various web standards: DOM handling, CSS selector, JSON, Canvas, and SVG.

下载解压缩，配置到PATH路径中即可。
https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-macosx.zip

## CasperJS

[CasperJS](http://casperjs.org/) is an open source navigation scripting & testing utility written in Javascript for the PhantomJS WebKit headless browser and SlimerJS (Gecko). It eases the process of defining a full navigation scenario and provides useful high-level functions, methods & syntactic sugar for doing common tasks such as:

- defining & ordering browsing navigation steps
- filling & submitting forms
- clicking & following links
- capturing screenshots of a page (or part of it)
- testing remote DOM
- logging events
- downloading resources, including binary ones
- writing functional test suites, saving results as JUnit XML
- scraping Web contents

Prerequisites

- PhantomJS 1.9.1 or greater. Please read the installation instructions for PhantomJS
- Python 2.6 or greater for casperjs in the bin/ directory

下载解压缩，配置到PATH路径中即可。

测试安装

    phantomjs --version
    casperjs
如果执行‘casperjs'命令时报错

```
Couldn't find nor compute phantom.casperPath, exiting.
```
问题原因是phantomjs2更改了casperjs所调用的接口.[http://qnalist.com/questions/5858081/casperjs-phantomjs-2-released-but-it-breaks-casperjs](http://qnalist.com/questions/5858081/casperjs-phantomjs-2-released-but-it-breaks-casperjs)

To resolve this error , you need to insert following lines in bootsrap.js in your bin directory of casperjs .[how-to-install-casperjs-on-windows](http://www.javaroots.com/2015/03/how-to-install-casperjs-on-windows.html)

```javascript
var system = require('system');
var argsdeprecated = system.args;
argsdeprecated.shift();
phantom.args = argsdeprecated; 
```

Now , try to run again , and you will not see this error . 


## Node.js
[Node.js](https://nodejs.org/en/) is a JavaScript runtime built on Chrome's V8 JavaScript engine. Node.js uses an event-driven, non-blocking I/O model that makes it lightweight and efficient. Node.js' package ecosystem, npm, is the largest ecosystem of open source libraries in the world.

```
Node.js was installed at

   /usr/local/bin/node

npm was installed at

   /usr/local/bin/npm

Make sure that /usr/local/bin is in your $PATH.
```

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

