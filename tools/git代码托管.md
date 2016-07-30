[TOC]

# 代码托管

托管代码的主流平台有国内的[开源中国-码云 git.oschina](http://git.oschina.net)、国外的[github](https://github.com)。

相比github，码云具有免费托管私有项目的功能。

# 码云

## 入门

### 当你初次使用码云时

使用码云，需要如下几步：

**1, 注册账号**

首先是在码云平台注册。

**2, 配置git**

执行下面两条命令,作为git的基础配置,作用是告诉git你是谁,你输入的信息将出现在你创建的提交中.

```shell
git config --global user.name "你的名字或昵称"
git config --global user.email "你的邮箱"
```

示例：

```shell
git config --global user.name chookin
git config --global user.email 469308668@qq.com
```

### 当你需要新建项目时

在你的需要初始化版本库的文件夹中执行

```shell
git init 

# 注:项目地址形式为:http://git.oschina.net/xxx/xxx.git或者 git@git.oschina.net:xxx/xxx.git
git remote add origin <你的项目地址> 
```

示例：

```shell
mkdir project-notes
cd project-notes
git init
git remote add origin git@git.oschina.net:chookin/project-notes.git
```

### 当你想克隆项目时

如果你想克隆一个项目,只需要执行

```shell
git clone <项目地址>
```

示例：

```shell
git clone git@git.oschina.net:chookin/Pyassess.git
```

### 完成第一次提交

进入你已经初始化好的或者克隆项目的目录,然后执行

```shell
git pull origin master
# 如果已经存在更改的文件,则这一步不是必须的
touch init.txt
git add .
git commit -m "第一次提交"
git push origin master
```

然后如果需要账号密码的话就输入账号密码，这样就完成了一次提交。

如果执行`git push origin master`报错，则需要配置SSH密钥。配置SSH密钥，请参考下一节。

```shell
$ git push origin master
Permission denied (publickey).
fatal: Could not read from remote repository.

Please make sure you have the correct access rights
```

### 配置SSH公钥

SSH key 可以让你在你的电脑和 Git@OSC 之间建立安全的加密连接。

你可以按如下命令来[生成SSH Keys](http://git.oschina.net/oschina/git-osc/wikis/帮助#ssh-keys)。

```shell
ssh-keygen -t rsa -C "xxxxx@xxxxx.com"# Creates a new ssh key using the provided email
# Generating public/private rsa key pair...
```

示例：

```
chookin:.ssh chookin$ ssh-keygen -t rsa -C "469308668@qq.com"
Generating public/private rsa key pair.
Enter file in which to save the key (/Users/chookin/.ssh/id_rsa):
/Users/chookin/.ssh/id_rsa already exists.
Overwrite (y/n)? y
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /Users/chookin/.ssh/id_rsa.
Your public key has been saved in /Users/chookin/.ssh/id_rsa.pub.
The key fingerprint is:
5f:68:36:5c:1e:53:38:8c:f0:76:f4:f7:1f:e5:29:cb 469308668@qq.com
The key's randomart image is:
+--[ RSA 2048]----+
|        .. o...  |
|         ...+o   |
|          o =.. o|
|         o = o o+|
|        S * o. oo|
|         + o. o o|
|          .  E  .|
|                 |
|                 |
+-----------------+
```

注意：存储key的文件必须是`.ssh/id_rsa`，如果已存在，则选择覆盖。

查看你的public key，并把他添加到 Git@OSC http://git.oschina.net/keys

```shell
$ cat ~/.ssh/id_rsa.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6eNtGpNGwstc....
```

添加后，在终端（Terminal）中输入

```shell
ssh -T git@git.oschina.net
```

若返回

```
Welcome to Git@OSC, yourname!
```

则证明添加成功。
