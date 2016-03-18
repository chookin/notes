# 基本使用

    set nu  设置行号
    unset nonu  取消行号
    hjkl    移动光标，左上下右
# 各种插入模式

    a   在光标后插入
    o   在当前行后插入一个新行
    O   在当前行前插入一个新行
    cw  替换从光标所在位置后到一个单词结尾的字符
# 移动光标

    0 → 数字零，到行头
    ^ → 到本行第一个不是blank字符的位置（所谓blank字符就是空格，tab，换行，回车等）
    $ → 到本行行尾
    g_ → 到本行最后一个不是blank字符的位置。
    /pattern → 搜索 pattern 的字符串（陈皓注：如果搜索出多个匹配，可按n键到下一个）

# 复制、剪切、粘贴

    P → 粘贴,注：p/P都可以，p是表示在当前位置之后，P表示在当前位置之前
    yy → 拷贝当前行
    ggyG        全部复制
    set paste   粘贴取消自动缩进
复制多行：
* 在命令行模式输入nyy，将剪切当前行 + 随后的n-1行
* 将光标移动到需要的位置，然后按p

剪切多行:
* 在命令行模式输入ndd，将剪切当前行 + 随后的n-1行
* 将光标移动到需要的位置，然后按p

# 删除

    dd      删除当前行，并把删除的行存到剪贴板里
    d$      删除到行尾
    .,$d    从当前行一直删除到文件尾部
    dG      全部删除
# 撤销、重做

    u       撤销上一步的操作
    Ctrl+r  恢复上一步被撤销的操作
    
# 列编辑

1. 进入`VISUAL BLOCK`模式:移动光标到要注释区块的第一行，Unix下按Ctrl+v，Windows版本的VIM则按Ctrl+Q
2. 选择所需要的行:光标移动到要注释区块的最后一行(若干个j，或者直接输入行号再按G等)
3. 针对列的操作: 例如删除多列，先移动光标选择列，之后输入d，例如替换，输入c，需要插入则按Shift+I(这里的用法同VIM的单行操作类似)
4. 退出保存:按 ESC

# 代码对齐
1. ctrl + v (选中块)
2. ctrl + f (向前) 或 ctrl +v (向后)
3. 按"=", 把选中的代码对齐。=是按格式对齐缩进，=%是对齐括号间的语句块

# 缩进
在命令模式下

    >> 将行向右移动8个空格
    n>> 将连续n行向左或向右缩进8个空格
    如当程序代码中有连续5行没有缩进，要进行缩进更正，使用5>>就可以实现这5行均缩进。


# 打开/保存/退出/改变文件(Buffer)

    :e <path/to/file> → 打开一个文件
    :w → 存盘
    :saveas <path/to/file> → 另存为 <path/to/file>
    :x， ZZ 或 :wq → 保存并退出 (:x 表示仅在需要时保存，ZZ不需要输入冒号并回车)
    :q! → 退出不保存 :qa! 强行退出所有的正在编辑的文件，就算别的文件有更改。
    :bn 和 :bp → 你可以同时打开很多文件，使用这两个命令来切换下一个或上一个文件。（陈皓注：我喜欢使用:n到下一个文件）

# 配置文件
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

# 参考
[简明 Vim 练级攻略](http://coolshell.cn/articles/5426.html?hmsr=toutiao.io&utm_medium=toutiao.io&utm_source=toutiao.io)
[在线VIM编辑器模拟学习 - aTool在线工具](http://www.atool.org/vim.php)
