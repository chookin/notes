-fTOC]
# 基本使用

## echo
-e

    若字符串中出现以下字符，则特别加以处理，而不会将它当成一般文字输出：
    \a 发出警告声；
    \b 删除前一个字符；
    \c 最后不加上换行符号；
    \f 换行但光标仍旧停留在原来的位置；
    \n 换行且光标移至行首；
    \r 光标移至行首，但不换行；
    \t 插入tab；
    \v 与\f相同；
    \\ 插入\字符；
    \nnn 插入nnn（八进制）所代表的ASCII字符；
-n

    不换行输出。
    例如：
    $echo -n "123"
    $echo "456"
    最终输出
    123456

## 比较

在shell中字符串与数值的比较方法是不同的，要注意区分

整数比较：
    -eq       等于,如:if [ "$a" -eq "$b" ]
    -ne       不等于,如:if [ "$a" -ne "$b" ]
    -gt       大于,如:if [ "$a" -gt "$b" ]
    -ge       大于等于,如:if [ "$a" -ge "$b" ]
    -lt       小于,如:if [ "$a" -lt "$b" ]
    -le       小于等于,如:if [ "$a" -le "$b" ]
    <       小于(需要双括号),如:(("$a" < "$b"))
    <=       小于等于(需要双括号),如:(("$a" <= "$b"))
    >       大于(需要双括号),如:(("$a" > "$b"))
    >=       大于等于(需要双括号),如:(("$a" >= "$b"))

字符串比较：
    =       等于,如:if [ "$a" = "$b" ]
    ==     等于,如:if [ "$a" == "$b" ], 与=等价
               注意:==的功能在[[]]和[]中的行为是不同的,如下:
               1 [[ $a == z* ]]    # 如果$a以"z"开头(模式匹配)那么将为true
               2 [[ $a == "z*" ]] # 如果$a等于z*(字符匹配),那么结果为true
               3
               4 [ $a == z* ]      # File globbing 和word splitting将会发生
               5 [ "$a" == "z*" ] # 如果$a等于z*(字符匹配),那么结果为true

    !=      不等于,如:if [ "$a" != "$b" ]， 这个操作符将在[[]]结构中使用模式匹配.
    <       小于,在ASCII字母顺序下.如:
               if [[ "$a" < "$b" ]]
               if [ "$a" \< "$b" ]     在[]结构中"<"需要被转义.
    >       大于,在ASCII字母顺序下.如:
           if [[ "$a" > "$b" ]]
           if [ "$a" \> "$b" ]  在[]结构中">"需要被转义.
    -z       字符串为"null".就是长度为0.
    -n       字符串不为"null"

## if

    if ....; then
    ....
    elif ....; then
    ....
    elif [ a > b] || [ a < 0]
    then
    ....
    else
    ....
    fi
例如：

    if [ -z "$NATIVE_SO_PATH" ] || ! [ -f "$NATIVE_SO_PATH/libnativetask.so" ] ; then
      echo 'Please set $NATIVE_SO_PATH to the directory containing libnativetask.so'
      exit 1
    fi
用"[]"来表示条件测试，要<b>确保方括号的空格</b>。 [  ....  -a  ..... ] 相当于 "与"，-o表示 或。当然也可以用 && 或者 ||

shell中条件判断if中的-z到-d的意思：

    [ -a FILE ] 如果 FILE 存在则为真。
    [ -b FILE ] 如果 FILE 存在且是一个块特殊文件则为真。
    [ -c FILE ] 如果 FILE 存在且是一个字特殊文件则为真。
    [ -d FILE ] 如果 FILE 存在且是一个目录则为真。
    [ -e FILE ] 如果 FILE 存在则为真。
    [ -f FILE ] 如果 FILE 存在且是一个普通文件则为真。
    [ -g FILE ] 如果 FILE 存在且已经设置了SGID则为真。
    [ -h FILE ] 如果 FILE 存在且是一个符号连接则为真。
    [ -k FILE ] 如果 FILE 存在且已经设置了粘制位则为真。
    [ -p FILE ] 如果 FILE 存在且是一个名字管道(F如果O)则为真。
    [ -r FILE ] 如果 FILE 存在且是可读的则为真。
    [ -s FILE ] 如果 FILE 存在且大小不为0则为真。
    [ -t FD ] 如果文件描述符 FD 打开且指向一个终端则为真。
    [ -u FILE ] 如果 FILE 存在且设置了SUID (set user ID)则为真。
    [ -w FILE ] 如果 FILE 如果 FILE 存在且是可写的则为真。
    [ -x FILE ] 如果 FILE 存在且是可执行的则为真。
    [ -O FILE ] 如果 FILE 存在且属有效用户ID则为真。 [ -G FILE ] 如果 FILE 存在且属有效用户组则为真。
    [ -L FILE ] 如果 FILE 存在且是一个符号连接则为真。
    [ -N FILE ] 如果 FILE 存在 and has been mod如果ied since it was last read则为真。
    [ -S FILE ] 如果 FILE 存在且是一个套接字则为真。
    [ FILE1 -nt FILE2 ] 如果 FILE1 has been changed more recently than FILE2,
    or 如果 FILE1 exists and FILE2 does not则为真。
    [ FILE1 -ot FILE2 ] 如果 FILE1 比 FILE2 要老, 或者 FILE2 存在且 FILE1 不存在则为真。
    [ FILE1 -ef FILE2 ] 如果 FILE1 和 FILE2 指向相同的设备和节点号则为真。 [ -o OPTIONNAME ] 如果 shell选项 “OPTIONNAME” 开启则为真。
    [ -z STRING ] “STRING” 的长度为零则为真。
    [ -n STRING ] or [ STRING ] “STRING” 的长度为非零则为真。
    [ STRING1 == STRING2 ] 如果2个字符串相同。 “=” may be used instead of “==” for strict POSIX compliance则为真。
    [ STRING1 != STRING2 ] 如果字符串不相等则为真。
    [ STRING1 < STRING2 ] 如果 “STRING1” sorts before “STRING2” lexicographically in the current locale则为真。
    [ STRING1 > STRING2 ] 如果 “STRING1” sorts after “STRING2” lexicographically in the current locale则为真。

## 函数
Shell函数返回值，常用的两种方式：return，echo

- return 语句

shell函数的返回值，可以和其他语言的返回值一样，通过return语句返回。

```shell
#!/bin/sh
function test()
{
    echo "arg1 = $1"
    if [ $1 = "1" ] ;then
        return 1
    else
        return 0
    fi
}

echo
echo "test 1"
test 1
echo $?         # print return result
```

- echo 返回值

函数的返回值有一个非常安全的返回方式，即通过输出到标准输出返回。因为子进程会继承父进程的标准输出，因此，子进程的输出也就直接反应到父进程。

```shell
function testFunc()
{
    local_result='local value'
    echo $local_result
}

result=$(testFunc)
echo $result
```

## 1>/dev/null 2>&1的含义
shell中可能经常能看到：`>/dev/null 2>&1`

其意义是什么呢？现在说说其中各组件的意思：

    /dev/null 代表空设备文件
    > 代表重定向到哪里，例如：echo "123" > /home/123.txt
    1 表示stdout标准输出，系统默认值是1，所以">/dev/null"等同于"1>/dev/null"
    2 表示stderr标准错误
    & 表示等同于的意思，2>&1，表示2的输出重定向等同于1

那么本文标题的语句:

    1>/dev/null 首先表示标准输出重定向到空设备文件，也就是不输出任何信息到终端，说白了就是不显示任何信息。
    2>&1 接着，标准错误输出重定向等同于 标准输出，因为之前标准输出已经重定向到了空设备文件，所以标准错误输出也重定向到空设备文件。

## EOF 与 <<
在shell脚本中，通常将EOF与 << 结合使用，表示后续的输入作为子命令或子Shell的输入，直到遇到EOF为止，再返回到主Shell。
当shell遇到<<时，它知道下一个词是一个分界符。在该分界符以后的内容都被当作输入，直到shell又看到该分界符(位于单独的一行)。
此分界符可以是所定义的任何字符串，其实，不一定要用EOF，只要是“内容段”中没有出现的字符串，都可以用来替代EOF，完全可以换成abcde之类的字符串，只是一个起始和结束的标志罢了。

```
$ mysql -u root -proot << EOF
> show databases;
> EOF
mysql: [Warning] Using a password on the command line interface can be insecure.
Database
information_schema
mysql
performance_schema
sys
var
wom
```

特殊用法：

```sql
: << COMMENTBLOCK
   shell脚本代码段
COMMENTBLOCK
```
用来注释整段脚本代码。 : 是shell中的空语句。

```sql
echo start
:<<COMMENTBLOCK
echo
echo "this is a test"
echo
COMMENTBLOCK
echo end
```
这段脚本执行时，中间部分不会被执行：

代码示例:

```sql
$ sh eof.sh
start
end
```

## 字符串

字符串包含
echo "remove-hadoop.sh" | grep -q "remo"
echo $?

-q 表示--quiet, --silent

## $参数说明

    $$
    Shell本身的PID（ProcessID）
    $!
    Shell最后运行的后台Process的PID
    $?
    最后运行的命令的结束代码（返回值）。如果是0说明上次脚本执行成功，如果非0说明上次脚本执行失败。
    $-
    使用Set命令设定的Flag一览
    $*
    所有参数列表。如"$*"用「"」括起来的情况、以"$1 $2 … $n"的形式输出所有参数。
    $@
    所有参数列表。如"$@"用「"」括起来的情况、以"$1" "$2" … "$n" 的形式输出所有参数。
    $#
    添加到Shell的参数个数
    $0
    Shell本身的文件名
    $1～$n
    添加到Shell的各参数值。$1（或${1}）是第1参数、$2是第2参数…

## 按行读取文件

    cat filename | while read line
    do
       echo $line
    done

## case
case语句结构特点如下：

- case行尾必须为单词“in”，每一个模式必须以右括号“)”结束;
- 双分号“;;”表示命令序列结束;
- 匹配模式中可使用方括号表示一个连续的范围，如[0-9]；使用竖杠符号“|”表示或;
- 最后的“*)”表示默认模式;
- esac 和 case是一对，就像fi 和 if.

示例

```
case "$1" in
  init)
        echo -e ${prompt_init}
        ;;
  create_db)
        echo -e ${prompt_create_db}
        ;;
  collect)
        echo -e ${promt_data_acquistion}
        for para in $*
        do
            case ${para} in
                --histdetail)
                    echo -e "load histdetail from downloaded files"
                    ;;
            esac
        done
        ;;
  *)
        echo "Use bash stock.sh <action> --help to get details on options available."
        exit 1
esac
```

# 常见问题

Q: A variable modified inside a while loop is not remembered
A: https://stackoverflow.com/questions/16854280/a-variable-modified-inside-a-while-loop-is-not-remembered

```
echo -e $lines | while read line
...
done
```

The while is loop executed in a subshell. So any changes you do for the variable will not be available once the subshell exits.

Instead you can use a [here string](https://www.gnu.org/software/bash/manual/bashref.html#Here-Strings) to re-write the while loop to be in the main shell process; only `echo -e $lines` will run in a subshell:

```shell
while read line
do
    if [[ "$line" == "second line" ]]
    then
    foo=2
    echo "Variable \$foo updated to $foo inside if inside while loop"
    fi
    echo "Value of \$foo in while loop body: $foo"
done <<< "$(echo -e "$lines")"
```
