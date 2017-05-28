[TOC]

# 安装Package Control
安装插件之前，我们需要首先安装一个Sublime 中最不可缺少的插件 Package Control, 以后我们安装和管理插件都需要这个插件的帮助。

使用快捷键 " ctrl + `" 打开Sublime的控制台 ,或者选择 View > Show Console 。
在控制台的命令行输入框，把下面一段代码粘贴进去，回车 就可以完成Pacakge Control 的安装了。安装后需重启sublime.

```python
import urllib.request,os,hashlib; h = '2915d1851351e5ee549c20394736b442' + '8bc59f460fa1548d1514676163dafc88'; pf = 'Package Control.sublime-package'; ipp = sublime.installed_packages_path(); urllib.request.install_opener( urllib.request.build_opener( urllib.request.ProxyHandler()) ); by = urllib.request.urlopen( 'http://packagecontrol.io/' + pf.replace(' ', '%20')).read(); dh = hashlib.sha256(by).hexdigest(); print('Error validating download (got %s instead of %s), please try manual install' % (dh, h)) if dh != h else open(os.path.join( ipp, pf), 'wb' ).write(by)
```

若要安装其他插件，使用快捷键 'command + shift + p ' 进入到Sublime 命令面板，输入 "package install" 从列表中选择 "install Package" 然后回车.

参考

- [Package Control installation](https://packagecontrol.io/installation#st3)


# Colorpicker
使用一个取色器改变颜色

使用方法 : ctrl + shift + c

# AdvancedNewFile
用 sublime text 新建文件，之前的方法是，⌘N 新建一个名为 untitled 文件，⌘S 保存，然后在弹出的 Finder 中填写真正需要的文件名，然后点击 Save 。可谓很是麻烦，而且如果需要新建多层次的文件夹，则需要转换到 Finder 进入到相应的工程目录下，一层一层新建，可谓是更加麻烦。

如果用 AdvancedNewFile，一切将会变得如此简单。

⌘⌥ N 即 新建，然后 sublime text 下方便会弹出一个文本输入框，只要在里面输入文件名，或多层次的路径，然后回车，即可。相应文件或多层次的路径就会立刻在工程目录下新建完全。

# SidebarEnhancements
为左侧sidebar增加功能。
怎么让左侧显示目录树？

* View ->Side Bar ->Show Side Barb
* 打开sublime text3程序，然后点击file->open folder打开你要显示的目录就行。

# 使用BracketHighlighter高亮括号配对
高亮括号配对在查找时很方便

# auto-save自动保存修改
这个插件在1秒没有按键时会自动保存。个人感觉太频繁，可根据需求选择
也可以启动sublime text的自动保存功能：
菜单： Sublime Text -> Preferences -> Settings - user
在配置文件中加上： "save_on_focus_lost": true 这样当前文档失去焦点时会自动保存

# Terminal
用于从当前位置打开终端。
## 配置终端路径
默认调用系统自带的Shell.去package setting 找到Terminal的user setting.

iTerm on OS X with tabs

```js
{
  "terminal": "iTerm.sh",
  "parameters": ["--open-in-tab"]
}
```

## 配置快捷键
默认快捷键如下：
- ctrl+shift+t 打开文件所在文件夹，
- ctrl+shift+alt+t 打开文件所在项目的根目录文件夹

默认快捷键使用不太方便，因此，修改如下：

```js
{
  "keys": ["ctrl+shift+t"],
  "command": "open_terminal_project_folder",
  "args": {
    "parameters": ["-T", "Working in directory %CWD%"]
  }
},
{
  "keys": ["ctrl+alt+t"],
  "command": "open_terminal",
  "args": {
    "parameters": ["-T", "Working in directory %CWD%"]
  }
}
```

# wordcount
https://packagecontrol.io/packages/WordCount

# AutoFileName
自动补全文件路径，非常方便。

# DocBlockr
DocBlockr会成为你编写代码文档的有效工具。当输入/**并且按下Tab键的时候，这个插件会自动解析任何一个函数并且为你准备好合适的模板

# ConvertToUTF8
需要装插件Codecs33.

# [TodoReview](https://github.com/jonathandelgado/SublimeTodoReview)
基本使用方法

安装 TodoReview，支持sublime text 3。
在文件中，使用"`TODO:`"创建标记。

Command + Shift + p 调出命令窗口，输入todo，选择 TodoReview:Open Files。
n键移动至下一个，p上一个。回车直接跳转到对应的文件并定位到该行。
可以检测到的pattern有: TODO, NOTE, FIXME, CHANGED。

# 插入当前时间
想在代码注释时插入当前时间发现Sublime Text 3不支持，于是编写插件实现插入时间功能

1 创建插件：

Tools → New Plugin:

```python
import datetime
import sublime_plugin
class AddCurrentTimeCommand(sublime_plugin.TextCommand):
    def run(self, edit):
        self.view.run_command("insert_snippet",
            {
                "contents": "%s" % datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            }
        )
```
保存为Sublime Text 3\Packages\User\addCurrentTime.py

2 创建快捷键：

Preference → Key Bindings - User:

```javascript
[
    {
        "command": "add_current_time",
        "keys": [
            "ctrl+shift+."
        ]
    }
]
```
3 此时使用快捷键"ctrl+shift+."即可在当前光标处插入当前时间.
