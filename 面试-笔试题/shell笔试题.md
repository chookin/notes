- [ $a == $b ] 和 [ $a -eq $b ] 有什么区别

```
[ $a == $b ] - 用于字符串比较
[ $a -eq $b ] - 用于数字比较
```

- 写出测试 $a 是否大于 12 的命令 ?

```sh
[ $a -gt 12 ]
```

- 如何检查字符串是否以字母 "abc" 开头 ?

```sh
[[ $string == abc* ]]
```

- 如何去除字符串中的所有空格 ?

```sh
echo $string|tr -d " "
```

- 如何打印数组的第一个元素 ?

```sh
echo ${array[0]}
```

- 如何打印数组的所有元素 ?

```sh
echo ${array[@]}
```

- 如何输出所有数组索引 ?

```sh
echo ${!array[@]}
```

- 如何移除数组中索引为 2 的元素 ?

```sh
unset array[2]
```

- 如何在数组中添加 id 为 333 的元素 ?

```sh
array[333]="New_element"
```

- 在脚本中如何使用 "expect" ?

```shell
/usr/bin/expect << EOD
spawn rsync -ar ${line} ${desthost}:${destpath}
expect "*?assword:*"
send "${password}\r"
expect eof
EOD
```
