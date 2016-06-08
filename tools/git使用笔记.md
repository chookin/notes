
# 文件忽略
文件 .gitignore 的格式规范如下：

    所有空行或者以注释符号 ＃ 开头的行都会被 Git 忽略。
    可以使用标准的 glob 模式匹配。
    匹配模式最后跟反斜杠（/）说明要忽略的是目录。
    要忽略指定模式以外的文件或目录，可以在模式前加上惊叹号（!）取反。

# git status显示中文
执行如下命令即可

```shell
git config --global core.quotepath false
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

## 获取
```shell
# 获取最新版本
git clone git@github.com:MyCATApache/Mycat-Server.git --depth=1
# 获取指定分支
git clone -b release_branch https://github.com/jetty/
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

# 参考

- [Undoing Changes](https://www.atlassian.com/git/tutorials/undoing-changes/git-checkout)
