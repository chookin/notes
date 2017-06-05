# linux 文本操作

## 文件比较

使用`diff`生成patch文件，然后使用vi打开，就可以高亮显示了。

```shell
diff -Nuar old-file  new-file > my.patch
```


## awk
will print all but very first column:

```sh
awk '{$1=""; print $0}' somefile
```

will print all but two first columns:

```sh
awk '{$1=$2=""; print $0}' somefile
```

正则匹配
`~,!~` 表示指定变量与正则表达式匹配（代字号）或不匹配（代字号、感叹号）的条件语句。

```shell
# 将第一个字段包含字符 n 的所有记录打印至标准输出。
awk '$1 ~ /n/'   testfile
# 将第5个字段不包含字符`{`的所有记录打印至标准输出
awk -F '|' '$5 !~ /{/'
```

参考：
- [linux awk 运算符](http://blog.csdn.net/ithomer/article/details/8476621)

# 问题
Q：Display 3rd line of the file in Unix
A: Using combination of “head” and “tail”: `$ mdfind -name 数据采集 doc | head -n 3 | tail -n 1`
另外一种方法，使用sed: `mdfind -name 数据采集 doc | sed -n '3,3p'`

Q: How to print last two columns using awk
A: You can make use of variable NF which is set to the total number of fields in the input record:

```sh
# this assumes that you have at least 2 fields.
awk '{print $(NF-1),"\t",$NF}' file
```

Q: 一个文件，最后一列是大于0的数值，分隔符是空格，查找并输出最后一列数值大于1的。
A: 有两种方案，一种是用`awk`，一种是用`grep`

```sh
$ grep total 1.log  | awk '$NF>0'
$ grep total 1.log  | grep -v "0$"
total removed {"site":"wandoujia","appName":"Nike+","apkName":"com.nike.plusgps"} 17
```

Q: print all columns from the 4th to the last
A: You could use a for-loop to loop through printing fields `$4` through `$NF` (built-in variable that represents the number of fields on the line).

```sh
# Edit: Since "print" appends a newline, you'll want to buffer the results:
awk '{out=""; for(i=4;i<=NF;i++){out=out" "$i}; print out}'

# Alternatively, use printf:
awk '{for(i=4;i<=NF;i++){printf "%s ", $i}; printf "\n"}'
```

