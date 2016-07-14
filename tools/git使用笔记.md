# 简介

## Git的优势

- SVN要是主机挂了.所有记录都GG了.而Git是分布式的.而且Git平台比较多,GitLab,coding.net,GitHub等等
- Git可以现在本地执行,可以在本地进行commit,而SVN每次commit都必须是提交到主机
- Git能保证数据完整性,Git中所有数据在存储前都计算校验和,然后以校验来引用,所以你在传送过程中丢失文件,Git都知道

## Git的三个工作区域和三种状态

三个工作区域 :

- 工作目录 : 我们从Git仓库提取出来的文件,正在本地修改的目录
- 暂存区域 : 是一个文件,保存下次将要提交的文件信息列表
- Git仓库 : 保存项目元数据和对象数据库的地方

三种状态:

- 已提交 : 如果Git仓库保存着特定版本文件,就属于已提交状态(commit)
- 已修改 : 自上一次取出来修改了,但还没放入暂存区(add)
- 已暂存 : 如果作了修改并放入暂存区域(add),就属于已暂存.

其实还有二种形式可分 1. 未跟踪 : 在本地未git add的就是未跟踪的. 2. 已跟踪 : 上述三种状态都是已跟踪状态.

# 安装Git

Mac：`brew install git`
Redhat/Centos：`sudo yum install git`
Windows：下载安装[Git SCM](https://git-scm.com/download/win)
对于Windows用户，安装后如果希望在全局的cmd中使用git，需要把git.exe加入PATH环境变量中。

# Git配置

## 配置文件

1. 全局系统配置 : /etc/gitconfig git config --system ...
2. 用户~/.gitconfig or ~/.config/git/config git config --global ...
3. 当前项目 : ./git/config

## 配置文件忽略

文件 .gitignore 的格式规范如下：

    所有空行或者以注释符号`#`开头的行都会被 Git 忽略。
    可以使用标准的 glob 模式匹配。
    匹配模式最后跟反斜杠`/`说明要忽略的是目录。
    要忽略指定模式以外的文件或目录，可以在模式前加上惊叹号`!`取反。

## 设置用户名和邮箱

```shell
git config --global user.name "404_K"
git config --global user.email 404_K@example.com
```

## git status显示中文

执行如下命令即可

```shell
git config --global core.quotepath false
```

# Git基础

## 初始化仓库

```shell
$ cd /tmp
$ mkdir samplePrj
$ cd samplePrj/
$ git init # 创建.git目录初始化git
Initialized empty Git repository in /private/tmp/samplePrj/.git/
$ touch README.md
$ git add . # 添加当前目录的所有文件到git中，放入暂存区
$ git commit -m 'virgin' # 提交修改
[master (root-commit) 86a264c] virgin
 1 file changed, 0 insertions(+), 0 deletions(-)
 create mode 100644 README.md
```

## 克隆现有仓库

```shell
git clone git@git.oschina.net:chookin/Pyassess.git
```

# 命令

## git
- 查看配置信息 `git config --list`
- 与暂存的对比 `git diff --cached`



```
git diff

Shows the changes between the working directory and the index. This shows what has been changed, but is not staged for a commit.

git diff --cached

Shows the changes between the index and the HEAD(which is the last commit on this branch). This shows what has been added to the index and staged for a commit.

git diff HEAD

Shows all the changes between the working directory and HEAD (which includes changes in the index). This shows all the changes since the last commit, whether or not they have been staged for commit or not.
```

## 暂存区
删除暂存区中的内容
```shell
git rm -r --cached <path>
```

## 获取
```shell
# 获取最新版本
git clone git@github.com:MyCATApache/Mycat-Server.git --depth=1
# 获取指定分支
git clone -b release_branch https://github.com/jetty/
```

## 提交

```shell
# 提交所有修改
git commit -a

# 提交指定文件的修改
git commit <file>
```

## 撤销
恢复某个已修改的文件（撤销未提交的修改）：
```shell
git checkout <commit> <file>
```
如
```shell
git checkout 9c85921cab12cd06689983bf42e7d50a8db2d4ba app/src/
```

撤销已提交的commit
```shell
git revert <commit>
```

## 分支管理
- 查看远程分支

```shell
$ git branch -a
* master
  remotes/origin/1.3.0.1
  remotes/origin/1.4
  remotes/origin/1.5
  remotes/origin/1.6
  remotes/origin/HEAD -> origin/master
  remotes/origin/master
  remotes/origin/revert-677-1.5
```

- 查看当前的远程库 `git remote -v`
- 查看当前分支

```shell
$ git branch
$ git branch -v
* master
```

- 创建分支 `git branch brach_name`
- 切换分支 `git checkout branch_name`
- 删除分支
    + `git branch -d branch_name` 如果该分支没有合并到主分支会报错
    + `git branch -D branch_name` 强制删除
- 分支合并
      比如，如果要将开发中的分支（develop），合并到稳定分支（master），
    + 首先切换的master分支：git checkout master。
    + 然后执行合并操作：git merge develop。
    + 如果有冲突，会提示你，调用git status查看冲突文件。
    + 解决冲突，然后调用git add或git rm将解决后的文件暂存。
    + 所有冲突解决后，git commit 提交更改。

# 标签

git标签分为两种类型：

- 轻量标签(Lightweight Tags)，是指向提交对象的引用；
- 附注标签(Annotated Tags)，包含完整的全部提交记录，包含创建 tag 人的信息（用户名，邮件等），创建 tag 的时间，还有备注信息。

## 创建标签

### 创建 lightweight tag

```shell
git tag v1.4   # v1.4 可以替换为自己制定的版本
```

### 创建 annotated tag:

```shell
git tag -a v1.4 -m "my version 1.4" # 多了一个 -a 参数
```

参数a即annotated的缩写，后附标签名。参数m指定标签说明，说明信息会保存在标签对象中。

## 标签发布

通常的git push不会将标签对象提交到git服务器，我们需要进行显式的操作：

```shell
git push origin v0.1.2 # 将v0.1.2标签提交到git服务器
git push origin –tags # 将本地所有标签一次性提交到git服务器
```

## 切换标签

与切换分支命令相同

```shell
git checkout [tagname]
```

再切换回主干

```shell
git checkout master
```

## 查看标签

```shell
git tag # 查看当前分支下的标签
```

git show命令可以查看标签的版本信息：

```shell
git show v0.1.2
```

## 删除标签

### 删除本地标签

误打或需要修改标签时，需要先将标签删除，再打新标签。

```shell
git tag -d v0.1.2 # 删除标签
```

参数d即delete的缩写，意为删除其后指定的标签。

### 删除远程仓库标签

```shell
git push origin :refs/tags/v0.1.2
```

说明：可以直接修改远程仓库的标签名：

```shell
git push origin refs/tags/源标签名:refs/tags/目的标签名
```

> Pushing an empty `<src>` allows you to delete the` <dst>` ref from the remote repository.

## Tagging Later

如果想给历史的某个commit打标签，则首先定位出该commit的checksum，

```shell
$ git log --pretty=oneline
15027957951b64cf874c3557a0f3547bd83b3ff6 Merge branch 'experiment'
a6b4c97498bd301d84096da251c98a07c7723e65 beginning write support
0d52aaab4479697da7686c15f77a3d64d9165190 one more thing
```

之后，在打标签命令后面追加checksum(或部分checksum)即可。

```shell
git tag -a v1.2 9fceb02
```

# 参考

- [Git基础](https://github.com/mzkmzk/Read/blob/master/progit.md?hmsr=toutiao.io&utm_medium=toutiao.io&utm_source=toutiao.io)
- [Git教程](https://github.com/geeeeeeeeek/git-recipes/wiki?hmsr=toutiao.io&utm_medium=toutiao.io&utm_source=toutiao.io)
- [Undoing Changes](https://www.atlassian.com/git/tutorials/undoing-changes/git-checkout)
- [Git Basics - Tagging](https://git-scm.com/book/en/v2/Git-Basics-Tagging)
- [git-push(1) - Linux man page](http://linux.die.net/man/1/git-push)
