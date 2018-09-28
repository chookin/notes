#!/bin/sh
#
# 批量转换文件格式，从gbk转到utf-8
dir=$1
for i in `find $dir -type f`
do
  echo -e "$i"
  iconv -f gb18030 -t utf8 $i > /tmp/iconv.tmp
  mv /tmp/iconv.tmp $i
done


dir=$1
for i in `find $dir -type f`
do
  echo "$i"
  name=${i##*/}
  iconv -f utf-8 -t gb18030 $i > $dir/$name_gb18030.txt
done
