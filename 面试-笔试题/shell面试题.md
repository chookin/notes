
## shell试题

- 命令 “export” 有什么用 ?
使变量在子 shell 中可用。

- 如何在后台运行脚本 ?
在脚本后面添加 “&”

- 如何在脚本文件中重定向标准输出和标准错误流到 log.txt 文件 ?
在脚本文件中添加 "exec >log.txt 2>&1" 命令。

- 如何只用 echo 命令获取字符串变量的一部分 ?

```
echo ${variable:x:y}
x - 起始位置
y - 长度
```
示例：

```sh
variable="My name is Petras, and I am developer."
echo ${variable:11:6} # 会显示 Petras
```

- 如何使用 awk 列出 UID 小于 100 的用户 ?

```sh
awk -F: '$3<100' /etc/passwd
```

- 如何计算传递进来的参数个数 ?

```sh
$#
```
- 如何在脚本中获取脚本名称

```sh
$0
```

- 如何输出当前 shell 的 PID ?

```sh
echo $$
```

- `$*` 和 `$@` 有什么区别

```
$* - 以一个字符串形式输出所有传递到脚本的参数
$@ - 以 $IFS 为分隔符列出所有传递到脚本中的参数
```

- 如何在 bash shell 中更改标准的域分隔符为 ":" ?

IFS=":"

- 如何进行两个整数相加

```sh
v1=11
v2=22
let v3=$v1+v2
echo $v3
```

或者

```sh
A=5
B=6
echo $(($A+$B)) # 方法 2
echo $[$A+$B] # 方法 3
expr $A + $B # 方法 4
echo $A+$B | bc # 方法 5
awk 'BEGIN{print '"$A"'+'"$B"'}' # 方法 6
```

- 举例如何写一个函数

```sh
$ cat fun.sh
function hi(){
    echo 'hello'
}

a=`hi`
echo $a world
```

- 在shell函数中使用`echo`和`return`有什么不同？
对于`echo`，若没有直接把函数返回值赋值给变量时，是输出信息到标准输出；否则，是把输出赋值给变量。
对于`return`,必须使用`#?`才能获取到函数返回值；另外，可以配合`&&`或`||`，作为开关使用。
示例：

```sh
# fun.sh
echo '==test echo=='
function hi(){
    echo 'hello'
    echo 'world'
}
hi
echo '--test assign--'
a=`hi`
echo $a

echo '==test_return=='
function test_r(){
    return 0
}
test_r
echo 'call `test_r` return' $?
a=`test_r`
echo $a
a=$?
echo $a
test_r && echo success
```

```sh
$ sh fun.sh
==test echo==
hello
world
--test assign--
hello world
==test_return==
call `test_r` return 0

0
success
```
可见，对于`return`，需要通过`#?`，才能获取到函数返回值。

- 若该行第一个元素是 FIND，输出第二个元素

```shell
awk'{ if ($1 == "FIND") print $2}'
```
- 如何获取文本文件的第 10 行 ?

```sh
head -10 file|tail -1
```

- 写出 shell 脚本中所有循环语法 ?

```sh
# for 循环
for i in $(ls);do
echo item:$i
done

# while 循环
COUNTER=0
while [ $COUNTER -lt 10 ]; do
echo The counter is $COUNTER
let COUNTER=COUNTER+1
done

# until 循环
COUNTER=20
until [ $COUNTER -lt 10 ]; do
echo COUNTER $COUNTER
let COUNTER-=1
done
```

- 如何调试bash脚本

方法1，使用参数 `-xv`。其中，选项`-v`启用 shell 在读取时显示每行;选项`-x`，启动Shell脚本的跟踪调试功能，将执行的每一条命令和输出的结果输出。

方法2，使用自定义格式显示显示信息，通过传递_DEBUG环境变量来建立调试风格；
示例

```sh
#!/bin/bash
function DEBUG(){
  [ "$_DEBUG" == "on" ] && $@ || :
}
for i in {1..3}
do
 DEBUG echo $i
done
echo "Script executed"
```
正常执行，不输出DEBUG日志信息。

```sh
$ sh test.sh
Script executed
```

DEBUG模式执行，输出DEBUG日志信息。

```sh
$ _DEBUG=on sh test.sh
1
2
3
Script executed
```


- 在 Shell 脚本中启用语法检查调试模式

参数选项`-n`激活语法检查模式。它会让 shell 读取所有的命令，但是不会执行它们，它（shell）只会检查语法。

## 参考

- [70个经典的 Shell 脚本面试问题](http://www.imooc.com/article/1131)
- [如何在 Shell 脚本中执行语法检查调试模式](https://linux.cn/article-8045-1.html)
- [Shell：脚本调试](http://blog.csdn.net/p106786860/article/details/51255555)
