# 配置http访问
假定svn的版本管理的根路径为/var/www/svn
## 安装
### 安装必须包
yum install mod_dav_svn subversion httpd
安装完毕后，在 /etc/httpd/module下面生成两个关于 svn的mod.

    ll modules/ | grep svn
    -rwxr-xr-x 1 root root   12704 Apr 12  2012 mod_authz_svn.so
    -rwxr-xr-x 1 root root  146928 Apr 12  2012 mod_dav_svn.so
在/etc/httpd/conf.d/文件下生成subversion.conf。
### 编辑subversion.conf
#### 一条顶级项目

    vi /etc/httpd/conf.d/subversion.conf
    LoadModule dav_svn_module     modules/mod_dav_svn.so
    LoadModule authz_svn_module   modules/mod_authz_svn.so
    <Location /repos>
       DAV svn
       SVNParentPath /var/www/svn
       AuthType Basic
       AuthName "Subversion repos"
       AuthUserFile /var/www/svn/conf/passwd
       Require valid-user
    </Location>
其中/var/www/svn是准备放仓库的目录，这个目录可以放置多个代码仓库，AuthUserFile就是用户和密码的文件（在后面介绍如何手动生成）。
#### 多个项目

    vi /etc/httpd/conf.d/subversion.conf

    <Location /repos/targetV3>
       DAV svn
       SVNPath /var/www/svn/targetV3
       AuthType Basic
       AuthName "targetV3 repos"
       AuthUserFile /var/www/svn/targetV3/conf/passwd
    AuthzSVNAccessFile /var/www/svn/targetV3/conf/authz
       Require valid-user
    </Location>
    <Location /repos/tagbase>
       DAV svn
       SVNPath /var/www/svn/tagbase
       AuthType Basic
       AuthName "targetV3 repos"
       AuthUserFile /var/www/svn/tagbase/conf/passwd
    AuthzSVNAccessFile /var/www/svn/tagbase/conf/authz
       Require valid-user
    </Location>

### 生成AuthUserFile
使用htpasswd命令来创建。命令的格式为

    htpasswd [-cmdpsD] passwordfile username
若第一次创建用户，我们必须使用参数“-c”来同时创建用户密码文件

    mkdir -p /var/www/svn/conf/
    htpasswd /var/www/svn/conf/passwd robert
上述命令创建的一个文件“passwd”，同时在文件里添加了一个 user named “robert”，执行该命令时会要求输入密码。
提醒：添加用户密码，不需要重启http。
注意：创建第二或之后的用户时，一定不能用参数“c”，否则之前的用户就会被删除。
如果想要删除某个用户，我们可以使用下列命令：

    htpasswd -D passwd robert
这样，robert就被从 passwd中删除了。
### 编辑AuthzSVNAccessFile

    echo "" > /var/www/svn/targetV3/conf/authz
    vi  /var/www/svn/targetV3/conf/authz
添加以下内容

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
 其中创建了设计组和开发组,开发组有szhang,sli两人,设计组有wyang一个，设计人员可以读改/doc和/src中的内容。而开发人员可以修改/src中的内容，以及读取/doc中的设计文档。
### 运行

    svnserve -d -r /var/www/svn
运行如上命令启动后台守护进程。
注意：如果在一台服务器上同时启动多个版本管理，那么启动路径必须是所有项目仓库的根路径。
### 重启httpd

    service httpd restart
## 测试
### 添加测试仓库
#### 添加

    cd /var/www/svn
    svnadmin create stuff
    chown -R apache.apache stuff # 如果不授权，在签入时会报错：svn: Can't open file '/var/www/svn/stuff/db/txn-current-lock': Permission denied。
#### 配置
编辑conf/svnserve.conf

    ### Uncomment the line below to use the default password file.
    password-db = passwd
编辑conf/passwd文件，增加账号：

    ### This file is an example password file for svnserve.
    ### Its format is similar to that of svnserve.conf. As shown in the
    ### example below it contains one section labelled [users].
    ### The name and password for each user follow, one account per line.
    [users]
    # harry = harryssecret
    # sally = sallyssecret
    robert = win
### http访问
访问http://111.13.47.167/repos/stuff，如果能验证登录，则测试通过。
### 签出及提交

    svn checkout http://111.13.47.167/repos/stuff/
    cd stuff/
    vi test #新建文件，并填写内容
    svn add test # 添加文件到svn
    svn commit -m "test commit" #提交
如果提交成功，则测试通过。
## 启动脚本
为小节介绍如何为svnserve增加启动脚本，已经如何配置开机自启动。
编辑脚本 /etc/rc.d/init.d/svnserved

    vi /etc/rc.d/init.d/svnserved
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

    chmod +x /etc/rc.d/init.d/svnserved

以后可以通过如下命令启动或停止svnserve

    service svnserved start
    service svnserved stop

配置为开机自启动

    chkconfig --add svnserved
    chkconfig svnserved on
# svn 客户端
## 代理配置
编辑文件~/.subversion/servers，修改http-proxy-host，http-proxy-port等信息。
注意：只能连接http协议的svn。
# 命令
## 签出

    svn checkout http://111.13.47.167/repos/tagbase/ tagbase/
不会覆盖本地的tagbase文件夹中文件。
## 撤消 revert

    svn revert --recursive example_folder
    svn info
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
