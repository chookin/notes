[TOC]

# 安装Python
以安装python-2.7.8为例进行说明。

## 前提条件
安装如下组件

```
yum install gcc zlib zlib-devel openssl-devel
```

## 下载

```sh
version=2.7.8
version=2.7.13
wget https://www.python.org/ftp/python/$version/Python-$version.tgz --no-check-certificate
```

## 编译安装
```shell
username=`whoami`
mkdir ~/local
./configure --prefix=/home/${username}/local/python
make
make install
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
easy_install pymongo MySQL-python
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
