[TOC]

# 安装Package Control
安装插件之前，我们需要首先安装一个Sublime 中最不可缺少的插件 Package Control, 以后我们安装和管理插件都需要这个插件的帮助。

使用快捷键 " ctrl + `" 打开Sublime的控制台 ,或者选择 View > Show Console 。
在控制台的命令行输入框，把下面一段代码粘贴进去，回车 就可以完成Pacakge Control 的安装了。
```python
import  urllib.request,os;pf='Package Control.sublime-package';ipp=sublime.installed_packages_path();urllib.request.install_opener(urllib.request.build_opener(urllib.request.ProxyHandler()));open(os.path.join(ipp,pf),'wb').write(urllib.request.urlopen('http://sublime.wbond.net/'+pf.replace(' ','%20')).read())
```

# markdown
## MarkdownEditing
[MarkdownEditing](https://github.com/SublimeText-Markdown/MarkdownEditing)是Markdown写作者必备的插件，它可以不仅可以高亮显示Markdown语法还支持很多编程语言的语法高亮显示。
```c
int main(){
    printf("Hello World\n");
}
```
除了高亮显示语法，MarkdownEditing 还提供了一些快捷键用于快速插入markdown 标记，下面是我常用的两个(更多的快捷键请参阅其官方文档)。

    command + option + v 插入链接
    command + shift + k 插入图片
## OmniMarkupPreviewer
[OmniMarkupPreviewer](https://github.com/timonwong/OmniMarkupPreviewer)用来预览markdown 编辑的效果，同样支持渲染代码高亮的样式。

	⌘+⌥+O: Preview Markup in Browser.
	⌘+⌥+X: Export Markup as HTML.
	Ctrl+Alt+C: Copy Markup as HTML.

## MarkdownLight
主题`MarkdownEditing`相对好看。貌似不能语法高亮，需要结合MarkdownEditing使用。

## Markdown Preview
相对`OmniMarkupPreviewer`来说，可以用[TOC]标记来生成目录。
### 使用
Markdown Preview较常用的功能是preview in browser和Export HTML in Sublime Text，前者可以在浏览器看到预览效果，后者可将markdown保存为html文件。

preview in browser据称是实时的，但是实践上还是需要在st保存，然后浏览器刷新才能看到新的效果，好在markdown写得多的话也不需要每敲一行看一次效果。
### 快捷键
st支持自定义快捷键，markdown preview默认没有快捷键，我们可以自己为preview in browser设置快捷键。方法是在Preferences -> Key Bindings User打开的文件的中括号中添加以下代码(可在Key Bindings Default找到格式)：
```javascript
 { "keys": ["alt+m"], "command": "markdown_preview", "args": { "target": "browser"} }
```
"alt+m"可设置为自己喜欢的按键。

### 设置语法高亮和mathjax支持
在Preferences ->Package Settings->Markdown Preview->Setting User中配置
```javascript
{
    /*
       Enable or not mathjax support.
    */"enable_mathjax": true,
 P
    /*
        Enable or not highlight.js support for syntax highlighting.
    */
    "enable_highlight": true
}

```

### 自定义css
```
cd /Users/chookin/Library/Application\ Support/Sublime\ Text\ 3/Installed\ Packages
mkdir -p tmp/markdownpreview
cp Markdown\ Preview.sublime-package tmp/markdownpreview.zip
cd tmp/markdownpreview && unzip ../markdownpreview.zip
cp ../markdown.css ../../markdownpreview.css
cd ../../
```
编辑 markdownpreview.css，进行配置，如调整页面宽度为75em

```css
body {
  width: 75em;
  border: 1px solid #ddd;
  outline: 1300px solid #fff;
  margin: 16px auto;
}
```

之后，在Preferences ->Package Settings->Markdown Preview->Setting User中配置

```js
"css":["/Users/chookin/Library/Application Support/Sublime Text 3/Installed Packages/markdownpreview.css"]
```

### 目录生成
关于目录生成，只要文章是按照markdown语法写作的。在需要生成目录的地方写`[TOC]`即可。
### 打印成pdf
将markdown转换为pdf应该有很多种方法的。我没有再折腾，直接用谷歌浏览器虚拟打印功能生成。
利用Markdown Preview的Preview in Browser功能可以在浏览器上看到htm效果。在页面右键->打印->另存为pdf->调节页边距即可将pdf文件下载下来。

# SidebarEnhancements
为左侧sidebar增加功能。
怎么让左侧显示目录树？

* View ->Side Bar ->Show Side Bar
* 打开sublime text3程序，然后点击file->open folder打开你要显示的目录就行。

# 使用BracketHighlighter高亮括号配对
高亮括号配对在查找时很方便
# auto-save自动保存修改
这个插件在1秒没有按键时会自动保存。个人感觉太频繁，可根据需求选择
也可以启动sublime text的自动保存功能：
菜单： Sublime Text -> Preferences -> Settings - user
在配置文件中加上： "save_on_focus_lost": true 这样当前文档失去焦点时会自动保存

# 代码格式化
## Alignment
代码对齐，按照=对齐

## Trmmer
删除不必要的空格

## JsFormat：代码格式化

JsFormat 基于 JS Beautifier，可以帮助你自动格式化 JavaScript和JSON。
快捷键：Ctrl + Alt + f 或者，你也可以使用菜单栏。
可定制喜欢的格式：在 SublimeText 3 中 Preferences -> Package Settings -> JsFormat -> Settings - Default 可以调整这些配置。


## HTML-CSS-JS Prettify
需要先按照node.js.

确认Node.js安装路径:

鼠标右键HTML/CSS/JS Prettify > Set Plugin Options保证插件路径与Node.js安装路径一致，Ctrl+s保存。
格式化html，`cmd + shift +h`

## Pretty Json
格式化`cmd + cntr + j`

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

# 版本管理
## Git
这个插件会将Git整合进你的SublimeText，使的你可以在SublimeText中运行Git命令，包括添加，提交文件，查看日志，文件注解以及其它Git功能。

## sublimerge pro
文件diff，与历史版本，与剪贴板

# AutoFileName
自动补全文件路径，非常方便。
# DocBlockr
DocBlockr会成为你编写代码文档的有效工具。当输入/**并且按下Tab键的时候，这个插件会自动解析任何一个函数并且为你准备好合适的模板
# Brogrammer主题
Brogrammer主题可使得标题栏、侧边栏都是酷酷的黑色，不错！安装主题的方法与安装插件一致，输入主题名字 Brogrammer 即可完成安装.
```javascript
"theme": "Brogrammer.sublime-theme",
"color_scheme": "Packages/Theme - Brogrammer/brogrammer.tmTheme"
```

# ConvertToUTF8
需要装插件Codecs33.
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
