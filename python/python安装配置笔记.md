[TOC]

# 安装Python
以安装python-2.7.8为例进行说明。

## 前提条件
安装如下组件

```
yum install -y gcc zlib zlib-devel openssl-devel
```

## 下载

```sh
version=2.7.14
wget https://www.python.org/ftp/python/$version/Python-$version.tgz --no-check-certificate
```

## 编译安装
```shell
tar xvf Python-$version*
cd Python-$version
./configure --prefix=/home/`whoami`/local/python
make && make install
```

## 配置环境变量
```shell
echo -e 'export PYTHON_HOME=$HOME/local/python\nexport PATH=${PYTHON_HOME}/bin:$PATH' >> ~/.bash_profile && source ~/.bash_profile
```

# 安装setuptools
https://pypi.python.org/pypi/setuptools

```sh
wget https://pypi.python.org/packages/source/s/setuptools/setuptools-7.0.tar.gz --no-check-certificate
tar zxvf setuptools-7.0.tar.gz
cd setuptools-7.0
python setup.py build
python setup.py install
```

# 安装modules
https://pypi.python.org/pypi
如果可以连网，则可以在安装了setuptools之后，使用如下命令安装module
`easy_install module_name`
否则，可以先下载到本地，解压缩，切换到module代码文件夹，然后执行
`python setup.py install`

module会安装到路径：`python-2.7.8/lib/python2.7/site-packages`

## 常用 module
```shell
easy_install pip pymongo MySQL-python futures paramiko redis hashlib
```

## python notebook

可以使用pip命令进行安装：

```sh
pip3 install jupyter
```

在python2中，使用：

```sh
pip install jupyter
```

安装完成后，在命令行中输入：

```sh
jupyter notebook
# 或者
ipython notebook
```

若报错

```
  File "/home/work/local/python-2.7.13/lib/python2.7/site-packages/notebook/services/sessions/sessionmanager.py", line 13, in <module>
    from pysqlite2 import dbapi2 as sqlite3
```

则手工下载pysqlite3，`https://pypi.python.org/pypi/pysqlite`，执行`python setup.py install`安装。

```sh
wget https://pypi.python.org/packages/42/02/981b6703e3c83c5b25a829c6e77aad059f9481b0bbacb47e6e8ca12bd731/pysqlite-2.8.3.tar.gz#md5=033f17b8644577715aee55e8832ac9fc --no-check-certificate
```

需要先安装`sqlite`。注意`yum install sqlite-devel`的版本比较低，导致notebook启动报错

```
    from pysqlite2 import dbapi2 as sqlite3
  File "/home/work/local/python-2.7.13/lib/python2.7/site-packages/pysqlite2/dbapi2.py", line 28, in <module>
    from pysqlite2._sqlite import *
ImportError: /home/work/local/python-2.7.13/lib/python2.7/site-packages/pysqlite2/_sqlite.so: undefined symbol: sqlite3_stmt_readonly
```

需手工编译安装sqlite. http://www.sqlite.org/download.html

```sh
wget http://www.sqlite.org/snapshot/sqlite-snapshot-201709211311.tar.gz
./configure
make && make install

cd /lib64
ln -fsv /usr/local/lib/libsqlite3.so.0 libsqlite3.so.0
`libsqlite3.so.0' -> /usr/local/lib/libsqlite3.so.0'
```

开启远程访问。

```
# 生成配置文件
[hadoop@ad-check1 ~]$ jupyter notebook  --generate-config
Writing default config to: /home/hadoop/.jupyter/jupyter_notebook_config.py

# 生成密码，记住输入的密码，远程登录时需要输入。竹喧莲动
[hadoop@ad-check1 ~]$ ipython
Python 2.7.13 (default, Sep 28 2017, 18:28:07)
In [1]: from notebook.auth import passwd

In [2]: passwd()
Enter password:
Verify password:
Out[2]: 'sha1:daee8f79e381:59a00f46f516abf55fda651b2a30d207da53a4ee'
```

把密文复制下来。修改配置文件`vim ~/.jupyter/jupyter_notebook_config.py`，如下几处修改

```
c.NotebookApp.ip = '*'
c.NotebookApp.password = u'sha1:daee8f79e381:59a00f46f516abf55fda651b2a30d207da53a4ee'
c.NotebookApp.open_browser = False
c.NotebookApp.port = 8888
c.NotebookApp.notebook_dir = u'/data/hadoop/zhuyin/nbook'
```

'sha1:855487b6e29d:bd9d01131b41aa0a85dae198b80db2dbbce538c9'

启用markdown目录

1. 安装[jupyter_contrib_nbextensions](https://github.com/ipython-contrib/jupyter_contrib_nbextensions)

```sh
pip install jupyter_contrib_nbextensions
jupyter contrib nbextension install --user
```


## scipy

scipy: Scientific Library for Python.

需要安装

```shell
# yum install followed packages.
blas-devel
lapack-devel
openblas-devel
atlas-devel

# python module
numpy
nose
```

参考：
http://memo.yomukaku.net/entries/jbRkQkq
测试：

```python
from scipy import *
a = zeros(1000)
a[:100]=1
b = fft(a)
print b[:10]
```

## 其他module
pycrypto: This is a collection of both secure hash functions (such as SHA256 and RIPEMD160), and various encryption algorithms (AES, DES, RSA, ElGamal, etc.). The package is structured to make adding new modules easy. This section is essentially complete, and the software interface will almost certainly not change in an incompatible way in the future; all that remains to be done is to fix any bugs that show up.

ECDSA: cryptographic signature library (pure python)

paramiko: This is a library for making SSH2 connections (client or server). Emphasis is on using SSH2 as an alternative to SSL for making secure connections between python scripts. All major ciphers and hash methods are supported. SFTP client and server mode are both supported too.
Required packages:

futures: Backport of the concurrent.futures package from Python 3.2

nose: nose extends unittest to make testing easier.

numpy: array processing for numbers, strings, records, and objects.

# 常见问题
```python
$ bin/python
Python 2.7.8 (default, Dec  1 2014, 11:53:43)
[GCC 4.4.7 20120313 (Red Hat 4.4.7-3)] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>> import MySQLdb;
/home/work/local/python/lib/python2.7/site-packages/setuptools-7.0-py2.7.egg/pkg_resources.py:1045: UserWarning: /home/work/.python-eggs is writable by group/others and vulnerable to attack when used with get_resource_filename. Consider a more secure location (set with .set_extraction_path or the PYTHON_EGG_CACHE environment variable).
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "build/bdist.linux-x86_64/egg/MySQLdb/__init__.py", line 19, in <module>
  File "build/bdist.linux-x86_64/egg/_mysql.py", line 7, in <module>
  File "build/bdist.linux-x86_64/egg/_mysql.py", line 6, in __bootstrap__
ImportError: libmysqlclient.so.15: cannot open shared object file: No such file or directory
```

解决办法:

```shell
vi ~/.bash_profile
export LD_LIBRARY_PATH=/home/work/local/mysql/lib:/usr/lib:$LD_LIBRARY_PATH
```

另外还有一个问题：`EnvironmentError: mysql_config not found`。解决方法：

```sh
export MYSQL_HOME=$HOME/local/mysql
export PATH=$MYSQL_HOME/bin:$PATH
```
