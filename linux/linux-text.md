

# linux 文本操作
## 计算字符串md5

```sh
➜  ~ echo 865969033604414 |md5
bea76ad0567f23af45ec2c2adc2bf3f4
➜  ~ echo -n 865969033604414 |md5
17e9a93972873a8d7414264484c8cf91
➜  ~ printf 865969033604414 |md5
17e9a93972873a8d7414264484c8cf91
➜  ~ printf 865969033604414 |md5 | tr "[a-z]" "[A-Z]"
17E9A93972873A8D7414264484C8CF91
```

说明：
1 echo默认是带换行符做结尾的
2 echo -n 可以去掉换行符
3 printf是没有换行符结尾的
4 tr可以删掉一个字符，如 tr -d '/n'

## 文件比较

使用`diff`生成patch文件，然后使用vi打开，就可以高亮显示了。

```shell
diff -Nuar old-file  new-file > my.patch
```


## awk
NF表示目前的记录被分割的字段的数目，NF可以理解为Number of Field。
NR,表示awk开始执行程序后所读取的数据行数，NR可以理解为Number of Record的缩写。
FNR,与NR功用类似,不同的是awk每打开一个新文件,FNR便重新累计，FNR可以理解为File Number of Record。

过滤空行

```sh
awk 'NF' somefile
```

```sh
先使用`| `分割，进一步，若分割后第一列以 数字+`.`开头，则取第一列输出，否则取第一列输出
cat sc.log| awk -F '\\| ' '{if(match($1, /^[0-9]+\.[0-9]+/)){print $1}else{print $2}}'
```

指定分隔符，使用`OFS`

```sh
[ ! -f cookie.sv ] && cat *sv.log |awk -F '|' '{OFS="|"}{print $5,$6,$7}' > cookie.sv
```

对特殊字符需要使用`\`转义

```sh
➜  139-ana cat ../20170808*/*sc.log|grep "79/319/2407"|awk -F 'Aug/2017:' '{print $2}' | awk -F ' \\+0800\\] "GET /sc/79/319/2407/5\\?v=1&ip='  '{print $1,$2}'|awk -F ' HTTP' '{print $1}'|awk -F '&t=' '{print $1,$2}'|awk -F ':' '{print $1,$3}'|awk '{print $1,$3,$4}'|sort -k 1,3|uniq |wc -l
```

不输出最后一列. 如果用 `awk ‘{$NF=””,print}’` 虽然不打印最后一列，但最后的空格是存在的。

```sh
awk 'NF--'
```

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

```
# 将第一个字段包含字符 n 的所有记录打印至标准输出。
awk '$1 ~ /n/'   testfile
# 将第5个字段不包含字符`{`的所有记录打印至标准输出
awk -F '|' '$5 !~ /{/'

# 找出以`/`为分隔符，第二个域以2256或2258开头的行
head -n 10000 128-sc.log |awk -F "72/325" '{print $2}'| awk 'NF' | awk -F '/' '$2 ~ /^2256|^2258/'
/2256/5?v=1&from=139h5&rmd=0.13012256657569932 HTTP/1.1" 302 - "-" "Mozilla/5.0 (Linux; Android 5.1; OPPO R9tm Build/LMY47I; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/53.0.2785.49 Mobile MQQBrowser/6.2 TBS/043305 Safari/537.36xwapp_andriod_hn" 2448
```

参考：
- [linux awk 运算符](http://blog.csdn.net/ithomer/article/details/8476621)

## grep/egrep
```sh
# 将会匹配到`/sv/79/319/2404/`
grep --color "sv/.*/2404/" 123-sv.log
```

## sed

```sh
sed '2 ittt' -i a.txt # 在第2行前插入ttt，并且将结果更新到a.txt
sed '2 attt' -i a.txt #在第2行后插入ttt,并且将结果更新到a.txt

# 去除开头的字符‘：’
cat s.log |awk -F ':' '{OFS=":"}{$1="";print $0}'|sed 's/^://g'>s1.log
```

```sh
sed -i "s/work/zhuyin/g" file
sed -i "s/com.cmri.migu.recm/com.cmri.um.recm/g" `grep "com.cmri.migu.recm" -rl recm-server``
sed -i "s/home\/work/home\/${username}/g" `grep home/work -rl ${SRC_PATH}`
sed -i "s/^slaveof.*/slaveof $redis_master $redis_port/g" ${redis_home}/redis.conf
sed -i "s#home/work#home/zhuyin#g" php-*.ini
find ${soft_name} \( -name "*.ini" -o -name "*.conf" -o -name "*.cnf" \) -exec sed -i "s#/home/work#$target_path#g" {} +
```

- [文件和目录管理-sed](http://man.linuxde.net/sed)

# 问题
Q：Display 3rd line of the file in Unix
A: Using combination of “head” and “tail”: `$ mdfind -name 数据采集 doc | head -n 3 | tail -n 1`
另外一种方法，使用sed:

```sh
mdfind -name 数据采集 doc | sed -n '3,3p'
# 搜索文件，处理文件名中的空格，把空格替换为`\ `，然后打开
mdfind -name 日历 |sed -n 3p|sed 's/ /\\ /g' | xargs open
```



```sh
sed -n '$p' file          #显示最后一行
sed -n '1,2p' file        #显示第一行到第二行
sed -n '2,$p' file        #显示第二行到最后一行
```

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

