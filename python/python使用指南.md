
# 一句Python命令启动一个Web服务器

切换路径准备做服务器根目录的路径下，输入命令：

```shell
python -m Web服务器模块 [端口号，默认8000]
```

例如：

```shell
python -m SimpleHTTPServer 8089
```

然后就可以在浏览器中输入如下路径来访问服务器资源。

```
http://localhost:端口号/路径
```


# 语法
输出异常

```python
import traceback
try:
    rdd.saveAsTextFile(target)
except:
    traceback.print_exc()
```

# 常见问题

1, 找不到 `OrderedDict`

```
[hadoop@PZMG-WB02-VAS ~]$ python
Python 2.6.6 (r266:84292, Mar  4 2017, 14:15:04)
[GCC 4.4.7 20120313 (Red Hat 4.4.7-4)] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>> from collections import OrderedDict
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
ImportError: cannot import name OrderedDict
```

> You are using Python 2.6 or earlier. OrderedDict was not added to Python until version 2.7.
> From the documentation:
> `New in version 2.7.`
> You could use this backport instead (also available from PyPI), it'll work on python versions 2.4 and up, or install python 2.7 and run your script with that version instead.



下载https://pypi.python.org/pypi/ordereddict/1.1 并按照

```
wget https://pypi.python.org/packages/53/25/ef88e8e45db141faa9598fbf7ad0062df8f50f881a36ed6a0073e1572126/ordereddict-1.1.tar.gz#md5=a0ed854ee442051b249bfad0f638bbec
tar xvf ...
cd order..
python setup.py install
```

使用时，需修改为

```python
import ordereddict
d = ordereddict.OrderedDict()
```

2，SyntaxError: Non-ASCII character '\xef' in file 错误解决
Python的默认编码文件是用的ASCII码，你将文件存成了UTF-8也没用
解决办法：在文件开头加入 # -*- coding: UTF-8 -*-    或者 #coding=utf-8 就行了

# 参考
- [Python定时任务的实现方式](https://lz5z.com/Python%E5%AE%9A%E6%97%B6%E4%BB%BB%E5%8A%A1%E7%9A%84%E5%AE%9E%E7%8E%B0%E6%96%B9%E5%BC%8F/)
