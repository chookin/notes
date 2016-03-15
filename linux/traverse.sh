#!bin/sh

#遍历文件夹
for file in ../lib/*
do
    if test -f $file
    then
        echo $file 是文件
    else
        echo $file 是目录
    fi
done

# 便利文件夹，并解压所有的jar文件
#
for file in /Users/chookin/project/DaTiBa/Server4.0/trunk/WebRoot/WEB-INF/lib/*
do
    if test -f $file
    then
        echo extract $file
        # 利用basename获取文件名
        filename=$(basename $file .jar)
        echo $filename
        # ()创建了子shell进程，`cd`命令不影响父进程的路径
        (mkdir $filename && cd $filename && jar -xvf $file)
    fi
done
