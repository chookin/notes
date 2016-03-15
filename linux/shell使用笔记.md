[TOC]
# 基本使用

## 查找
查找指定类型的文件，并进而查找包含指定字符的
```find . -type f -name *.java | xargs grep -r common.Logger```

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

## if

    if ....; then
    ....
    elif ....; then
    ....
    else
    ....
    fi
例如：

    if [ -z "$NATIVE_SO_PATH" ] || ! [ -f "$NATIVE_SO_PATH/libnativetask.so" ] ; then
      echo 'Please set $NATIVE_SO_PATH to the directory containing libnativetask.so'
      exit 1
    fi
用"[]"来表示条件测试，要确保方括号的空格。 [  ....  -a  ..... ] 相当于 "与"，-o表示 或。
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

## 1>/dev/null跟在命令行后面

    1> /dev/null 表示将命令的标准输出重定向到 /dev/null
    2>/dev/null 表示将命令的错误输出重定向到 /dev/null

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

```shell
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
