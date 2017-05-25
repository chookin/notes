[TOC]

# 安装Python
以安装python-2.7.8为例进行说明。

## 前提条件
安装如下组件
```
yum install gcc zlib zlib-devel openssl-devel
```

## 下载
`wget https://www.python.org/ftp/python/2.7.8/Python-2.7.8.tgz --no-check-certificate`

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
```
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

## MySQLdb
```shell
wget https://pypi.python.org/packages/source/M/MySQL-python/MySQL-python-1.2.5.zip#md5=654f75b302db6ed8dc5a898c625e030c --no-check-certificate
unzip MySQL-python-1.2.5.zip && cd MySQL-python-1.2.5
python setup.py install
```
或者采用easy_install方式安装

`easy_install MySQL-python`
module会安装到路径：`python-2.7.8/lib/python2.7/site-packages`
常见问题：
```
File "/tmp/make/MySQL-python-1.2.5/setup_posix.py", line 25, in mysql_config
    raise EnvironmentError("%s not found" % (mysql_config.path,))
EnvironmentError: mysql_config not found
```

## pymongo
```shell
wget --no-check-certificate https://pypi.python.org/packages/source/p/pymongo/pymongo-2.7.tar.gz
```

## pycrypto
This is a collection of both secure hash functions (such as SHA256 and RIPEMD160), and various encryption algorithms (AES, DES, RSA, ElGamal, etc.). The package is structured to make adding new modules easy. This section is essentially complete, and the software interface will almost certainly not change in an incompatible way in the future; all that remains to be done is to fix any bugs that show up. 
```shell
wget --no-check-certificate https://pypi.python.org/packages/source/p/pycrypto/pycrypto-2.6.1.tar.gz
```

## ecdsa
ECDSA cryptographic signature library (pure python)
```shell
wget --no-check-certificate https://pypi.python.org/packages/source/e/ecdsa/ecdsa-0.11.tar.gz
```

## paramiko
This is a library for making SSH2 connections (client or server). Emphasis is on using SSH2 as an alternative to SSL for making secure connections between python scripts. All major ciphers and hash methods are supported. SFTP client and server mode are both supported too.
Required packages:

- pyCrypto
- ecdsa

```shell
wget --no-check-certificate https://pypi.python.org/packages/source/p/paramiko/paramiko-1.15.2.tar.gz#md5=6bbfb328fe816c3d3652ba6528cc8b4c
```

## futures
Backport of the concurrent.futures package from Python 3.2
`wget --no-check-certificate https://pypi.python.org/packages/source/f/futures/futures-2.2.0.tar.gz#md5=310e446de8609ddb59d0886e35edb534`

## nose
nose extends unittest to make testing easier
Package Documentation
nose extends the test loading and running features of unittest, making
it easier to write, find and run tests.
By default, nose will run tests in files or directories under the current working directory whose names include “test” or “Test” at a word boundary (like “test_this” or “functional_test” or “TestClass” but not “libtest”). Test output is similar to that of unittest, but also includes captured stdout output from failing tests, for easy print-style debugging.
These features, and many more, are customizable through the use of plugins. Plugins included with nose provide support for doctest, code coverage and profiling, flexible attribute-based test selection, output capture and more. More information about writing plugins may be found on in the nose API documentation, here:http://readthedocs.org/docs/nose/
https://pypi.python.org/packages/source/n/nose/nose-1.3.4.tar.gz#md5=6ed7169887580ddc9a8e16048d38274d

## numpy
NumPy: array processing for numbers, strings, records, and objects.
NumPy is a general-purpose array-processing package designed to efficiently manipulate large multi-dimensional arrays of arbitrary records without sacrificing too much speed for small multi-dimensional arrays. NumPy is built on the Numeric code base and adds features introduced by numarray as well as an extended C-API and the ability to create arrays of arbitrary type which also makes NumPy suitable for interfacing with general-purpose data-base applications.
There are also basic facilities for discrete fourier transform, basic linear algebra and random number generation.
https://pypi.python.org/packages/source/n/numpy/numpy-1.9.1.tar.gz#md5=78842b73560ec378142665e712ae4ad9 

## scipy
SciPy: Scientific Library for Python
SciPy (pronounced “Sigh Pie”) is open-source software for mathematics,
science, and engineering. The SciPy library depends on NumPy, which provides convenient and fast N-dimensional array manipulation. The SciPy library is built to work with NumPy arrays, and provides many user-friendly and efficient numerical routines such as routines for numerical integration and optimization. Together, they run on all popular operating systems, are quick to install, and are free of charge. NumPy and SciPy are easy to use, but powerful enough to be depended upon by some of the world’s leading scientists and engineers. If you need to manipulate numbers on a computer and display or publish the results, give SciPy a try!
https://pypi.python.org/packages/source/s/scipy/scipy-0.15.1.tar.gz#md5=be56cd8e60591d6332aac792a5880110 
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
