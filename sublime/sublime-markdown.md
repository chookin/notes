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

## Markdown Extended
Markdown Extended + Extends Monokai：不错的Markdown主题，支持对多种语言的高亮
http://www.jianshu.com/p/aa30cc25c91b

To make Markdown Extended the default highlighting for the current extension:

> Open a file with the extension you want to set a default for (i.e. .md)
Navigate through the following menus in Sublime Text: View -> Syntax -> Open all with current extension as... -> Markdown Extended
https://github.com/jonschlinkert/sublime-markdown-extended#2-activate-this-language

## OmniMarkupPreviewer
[OmniMarkupPreviewer](https://github.com/timonwong/OmniMarkupPreviewer)用来预览markdown 编辑的效果，同样支持渲染代码高亮的样式。

    ⌘+⌥+O: Preview Markup in Browser.
    ⌘+⌥+X: Export Markup as HTML.
    Ctrl+Alt+C: Copy Markup as HTML.


常见问题：
```
Error: 404 Not Found

Sorry, the requested URL 'http://127.0.0.1:51004/view/31' caused an error:

'buffer_id(31) is not valid (closed or unsupported file format)'

**NOTE:** If you run multiple instances of Sublime Text, you may want to adjust
the `server_port` option in order to get this plugin work again.
```

Here is the answer:

Sublime Text > Preferences > Package Settings > OmniMarkupPreviewer > Settings - User

remove the `strikeout` package, such as:

```js
{
    "renderer_options-MarkdownRenderer": {
        "extensions": ["tables", "toc", "fenced_code", "codehilite","nl2br"]
    }
}
```

## MarkdownLight
主题`MarkdownEditing`相对好看。貌似不能语法高亮，需要结合MarkdownEditing使用。

## Markdown Preview
相对`OmniMarkupPreviewer`来说，可以用`[TOC]`标记来生成目录。
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
