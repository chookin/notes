
- 安装中文包

需要使用centos的yum源
yum groupinstall Chinese-support  --安装中文语言包

编辑文件 /etc/sysconfig/i18n     --永久生效(修改配置文件)
LANG="zh_CN.utf8"--修改配置文件
