# 代码格式化
## Alignment
代码对齐，按照=对齐
ctrl + alt + a

## [codeformatter](https://github.com/akalongman/sublimetext-codeformatter)
CodeFormatter is a Sublime Text 2/3 plugin that supports format (beautify) source code.


CodeFormatter has support for the following languages:

* PHP - By phpfmt
* JavaScript/JSON - By JSBeautifier
* HTML - By JSBeautifier
* CSS - By JSBeautifier
* SCSS - By Nishutosh Sharma
* Python - By PythonTidy (only ST2)
* Visual Basic/VBScript

Tools -> Command Palette (`Cmd+Shift+P` or `Ctrl+Shift+P`) and type `Format Code`.

You can set up your own key combo for this, by going to Preferences -> Key Bindings - User, and adding a command in that huge array: `{ "keys": ["ctrl+alt+f"], "command": "code_formatter" },`. Default keybinding is `ctrl+alt+f`. You can use any other key you want, thought most of them are already taken.

## HTML-CSS-JS Prettify
需要先安装node.js.

确认Node.js安装路径:

鼠标右键HTML/CSS/JS Prettify > Set Plugin Options保证插件路径与Node.js安装路径一致，Ctrl+s保存。

格式化html，`cmd + shift +h`

## JsFormat

JsFormat 基于 JS Beautifier，可以帮助你自动格式化 JavaScript和JSON。
快捷键：Ctrl + Alt + f 或者，你也可以使用菜单栏。
可定制喜欢的格式：在 SublimeText 3 中 Preferences -> Package Settings -> JsFormat -> Settings - Default 可以调整这些配置。

## Pretty Json
json文本格式化`cmd + cntr + j`

## indent xml
格式化xml

使用：cmd+shift+p，输入indent xml，即可格式化当前文件的xml。

## Trimmer
删除不必要的空格.

`cmd + shift + p` 输入`trimmer`...
