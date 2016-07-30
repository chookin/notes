# 配置http访问
## 安装 Apache, Subversion
```shell
yum install httpd
```

启动并配置开机自启动

```shell
service httpd start
chkconfig httpd on
```

## 安装Subversion

```shell
yum install subversion mod_dav_svn
```

安装完毕后，在` /etc/httpd/module`下面生成两个关于 svn的mod.

```
ll modules/ | grep svn
-rwxr-xr-x 1 root root   12704 Apr 12  2012 mod_authz_svn.so
-rwxr-xr-x 1 root root  146928 Apr 12  2012 mod_dav_svn.so
```

在`/etc/httpd/conf.d/`文件下生成`subversion.conf`。

## 项目示例

### 情景一 共用权限管理

处于同一路径的多个项目共用一套权限管理，该路径下的项目不用再配置权限。

#### 配置

配置仓库根目录为`/var/svn`, web访问路径为`/svn`,  及密码文件为`/etc/svn-users`。

```shell
vim /etc/httpd/conf.d/subversion.conf
```

```
LoadModule dav_svn_module     modules/mod_dav_svn.so
LoadModule authz_svn_module   modules/mod_authz_svn.so

Alias /svn /var/svn

<Location /svn>
   DAV svn
   SVNParentPath /var/svn
   AuthType Basic
   AuthName "Subversion User Authentication "
   AuthUserFile /etc/svn-users
   Require valid-user
</Location>
```

#### 创建repository

在仓库根目录下添加项目`myrepo`

```shell
mkdir /var/svn
cd /var/svn
svnadmin create myrepo
chown -R apache.apache myrepo
```

新加repository后，需要重启apache才能生效。

```shell
service httpd restart
```

#### 添加用户

添加用户`user1`

```shell
touch /etc/svn-users
# -m  Force MD5 encryption of the password.
htpasswd -m /etc/svn-users user1
```

#### 在浏览器访问

访问svn的http地址，输入用户名及密码。

```
http://example.com/svn/myrepo/
```

若登录后页面显示为如下，则配置正常，否则请排查原因。

```
myrepo - Revision 0: /
```

## 情景二 项目具有自己的权限管理

以创建仓库`admonitor`为例进行说明。

#### 配置

    vi /etc/httpd/conf.d/subversion.conf

    <Location /repos/admonitor>
       DAV svn
       SVNPath /var/svn/admonitor
       AuthType Basic
       AuthName "admonitor repos"
       AuthUserFile /var/svn/admonitor/conf/passwd
       Require valid-user
    </Location>

#### 创建repository

```shell
cd /var/svn
svnadmin create admonitor
chown -R apache.apache admonitor # 如果不授权，在签入时会报错：svn: Can't open file '/var/www/svn/stuff/db/txn-current-lock': Permission denied。
```
#### 添加用户

配置的用户密码文件是`/var/svn/admonitor/conf/passwd`，在使用命令创建repository时，已自动生成该文件，然而该文件的格式不能被`htpasswd`使用，需要删了重建。

```shell
cd /var/svn/admonitor/conf/
rm -f passwd
touch passwd
htpasswd -m /etc/svn-users user1
```

#### 在浏览器访问

访问svn的http地址，输入用户名及密码。

```
http://example.com/repo/admonitor/
```

#### 测试

```shell
# 需替换为实际的地址
svn checkout http://http://example.com/repo/admonitor/
cd admonitor/
touch REAME.md
svn add REAME.md
svn commit -m "test commit"
```

如果提交成功，则测试通过。

## 附录

### htpasswd

使用htpasswd命令来创建用户密码文件。命令的格式为

```
htpasswd [-cmdpsD] passwordfile username
```

若第一次创建用户，我们必须使用参数“-c”来同时创建用户密码文件

```
cd conf
htpasswd -c passwd robert
```

上述命令创建的一个文件“passwd”，同时在文件里添加了一个 user named “robert”，执行该命令时会要求输入密码。
提醒：添加用户密码，不需要重启http。
注意：创建第二或之后的用户时，一定不能用参数“c”，否则之前的用户就会被删除。


如果想要删除某个用户，我们可以使用下列命令：

```
htpasswd -D passwd robert
```

这样，robert就被从 passwd中删除了。

### 权限细分

用于为不同的用户赋予不同的权限。

以仓库admonitor为例进行说明。

首先修改`/etc/httpd/conf.d/subversion.conf`，修改该repository的配置，增加`AuthzSVNAccessFile`

```
<Location /repos/admonitor>
   DAV svn
   SVNPath /var/svn/admonitor
   AuthType Basic
   AuthName "admonitor repos"
   AuthUserFile /var/svn/admonitor/conf/passwd
   AuthzSVNAccessFile /var/svn/admonitor/conf/authz
   Require valid-user
</Location>
```

然后修改权限文件

```shell
> /var/svn/admonitor/conf/authz
vi  /var/svn/admonitor/conf/authz
```

在权限文件中添加以下内容

```
[groups]
design = wyang
dev = szhang,sli
[/doc]
@design = rw
@dev = r
[/src]
@design = r
@dev = rw
* = r
```

 其中创建了设计组和开发组,开发组有szhang,sli两人,设计组有wyang一个，设计人员可以读改/doc和/src中的内容。而开发人员可以修改/src中的内容，以及读取/doc中的设计文档。

### 支持svn协议

如果需要以`svn://xxxx`的形式被访问，需要启动svn后台服务。

```shell
svnserve -d -r /var/www/svn
```

运行如上命令启动后台守护进程。
注意：如果在一台服务器上同时启动多个版本管理，那么启动路径必须是所有项目仓库的根路径。

下面进一步配置svn后台服务开机自启动。
编辑脚本` /etc/rc.d/init.d/svnserved`，修改文件内容如下：

    #!/bin/bash
    # Startup script for svnserve
    # chkconfig: - 85 15
    # description: svnserve.
    svn_parent_path='/var/www/svn'
    case "$1" in
    start)
        echo "starting svnserve..."
        svnserve -d -r ${svn_parent_path}
        echo "finished"
        ;;
    stop)
        echo "stoping svnserve"
        killall svnserve
        echo "finished"
        ;;
    restart)
        $0 stop
        $0 start
        ;;
    *)
        exit
    esac
增加可执行权限

```shell
chmod +x /etc/rc.d/init.d/svnserved
```

以后可以通过如下命令启动或停止svnserve

    service svnserved start
    service svnserved stop

配置为开机自启动

```shell
chkconfig --add svnserved
chkconfig svnserved on
```
## 常见问题

1) 浏览器打开svn的http地址时，报错：

```
Forbidden

You don't have permission to access /repos/admonitor on this server.
```

请检查`/var/log/httpd/error_log `, `/var/log/messages`, `/var/log/secure`, `/var/log/audit/audit.log`等日志文件查看问题原因，可能情况：

- subversion.conf配置了`AuthzSVNAccessFile`属性，可是该属性对应的文件没有给相应用户赋权限；
- selinux启用了，在`/var/log/secure`日志中应有告警提示登录失败；
- httpd.conf中没有放开权限，在apache的错位日志中应有拦截记录。

## 参考

- [How to Setup SubVersion Server on CentOS, RHEL & Fedora](http://tecadmin.net/setup-subversion-server-on-centos/#)

# svn 客户端

## 代理配置
编辑文件~/.subversion/servers，修改http-proxy-host，http-proxy-port等信息。
注意：只能连接http协议的svn。
# 命令
## 签出

    svn checkout http://111.13.47.167/repos/tagbase/ tagbase/
不会覆盖本地的tagbase文件夹中文件。
## 撤消未提交的修改
```shell
svn revert --recursive example_folder
# 示例
svn revert -R .
```

## 撤销已提交的修改
分为三步操作：
1. svn update，svn log，找到最新版本（latest revision）
2. 找到自己想要回滚的版本号（rollbak revision）
3. 用svn merge来回滚： svn merge -r : something

具体示例

1、保证我们拿到的是最新代码： 
 svn update 
 假设最新版本号是28。 
2、然后找出要回滚的确切版本号： 
 svn log [something]
 假设根据svn log日志查出要回滚的版本号是25，此处的something可以是文件、目录或整个项目
 如果想要更详细的了解情况，可以使用svn diff -r 28:25 [something]
3、回滚到版本号25：
   svn merge -r 28:25 something
 为了保险起见，再次确认回滚的结果：
   svn diff [something]
 发现正确无误，提交。
4、提交回滚：
 svn commit -m "Revert revision from r28 to r25,because of ..." 
 提交后版本变成了29。

## 导入文件

    svn import project/hadoop-2.2.0-cdh5.0.0-beta-2/src/ svn://localhost/hadoop-2.2.0-cdh5.0.0-beta-2 -F svn-commit.tmp
注意，导入后的文件需要再checkout到本地，否则会提示” is not a working copy”。
## checkout

    svn checkout svn://localhost/hadoop-2.2.0-cdh5.0.0-beta-2 src/
checkout到本地的src文件夹（需要把原来的给删掉）。
## update

    svn update
## 分支
创建分支 svn copy trunk branches/branch-ms
merge分支 首先把主干上的代码合并到分支上来（如果主干进行修改了的话），分支测试完成之后再将分支代码合并到主干去。
建立tags
产品开发已经基本完成，并且通过很严格的测试，这时候我们就想发布给客户使用，发布我们的1.0版本
svn copy http://svn_server/xxx_repository/trunk http://svn_server/xxx_repository/tags/release-1.0 -m "1.0 released"

删除分支或tags
svn rm http://svn_server/xxx_repository/branches/br_feature001
svn rm http://svn_server/xxx_repository/tags/release-1.0

## 忽略文件
Use the following command to create a list not under version control files.

```shell
svn status | grep "^\?" | awk "{print \$2}" > ignoring.txt
```
Then edit the file to leave just the files you want actually to ignore. Then use this one to ignore the files listed in the file:
```shell
svn propset svn:ignore -F ignoring.txt .
```
Note the dot at the end of the line. It tells SVN that the property is being set on the current directory.

或者
```shell
export SVN_EDITOR=/usr/bin/vi
svn propedit svn:ignore .
```

## 提交文件

    svn commit  [path...]
## 生成patch

    svn diff -x --ignore-all-space  > test.patch
## 提交patch文件

    mv test.patch ../cmri/patches/
    cd ../cmri/patches/
    svn add test.patch
    svn commit test.patch -m "test"
## 打patch

    cd ../src
    patch -p0 < ../cmri/patches/test.patch
## 与指定版本做对比，生成diff

    svn diff -x --ignore-all-space -r 276 > a.patch
## 修改仓库地址

svn relocate $new_repository_address

# 常见问题

1)
    svn: Could not use external editor to fetch log message; consider setting the $SVN_EDITOR environment variable or using the --message (-m) or --file (-F) options
    svn: None of the environment variables SVN_EDITOR, VISUAL or EDITOR are set, and no 'editor-cmd' run-time configuration option was found
问题原因：
没有设置svn编辑器的环境变量，主要是import、commit中填写comment要用。
解决办法：

1. 记录一个log信息，即在命令后面加上 -m "消息内容"
2. 修改环境变量文件，例如/etc/profile，加入如下一行：

```
export SVN_EDITOR=vi
```
温馨提示：
编辑完以后一般需要让配置文件立即生效，可执行命令：

    source /etc/profile

2) idea打开svn版本管理的项目报错：
```
svn: E155021: This client is too old to work with the working copy at '/Users/chookin/project/DaTiBa' (format 31). You need to get a newer Subversion client. 
```

查看当前用户下的svn版本，发现版本挺高的啊。问题原因是，idea使用的系统自带的svn，配置idea中的svn路径为当前用户所使用的较高版本的svn路径即可。
# 总结
在这篇文章中介绍了如何部署svn的服务端软件subversion、客户端软件TortoiseSVN、eclipse svn插件以及在eclipse中使用svn。
