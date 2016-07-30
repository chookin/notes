# 安全漏洞
## ssh
升级ssh
```shell
wget http://mirrors.evowise.com/pub/OpenBSD/OpenSSH/portable/openssh-7.2p2.tar.gz
tar zxvf openssh-*.tar.gz
# 需要先安装一些基础包，否则报错 configure: error: *** zlib.h missing - please install first or check config.log ***
yum install -y gcc zlib-devel openssl-devel
./configure && make && make install
# ssh -V
OpenSSH_6.9p1, OpenSSL 1.0.1e-fIPs 11 Feb 2013
```


## Linux幽灵(Ghost)漏洞CVE-201500235

yum update -y glibc

测试脚本 `ghost-test.sh`
```shell
#!/bin/bash
#Version 3

echo "Installed glibc version(s)"

rv=0
for glibc_nvr in $( rpm -q --qf '%{name}-%{version}-%{release}.%{arch}\n' glibc ); do
    glibc_ver=$( echo "$glibc_nvr" | awk -F- '{ print $2 }' )
    glibc_maj=$( echo "$glibc_ver" | awk -F. '{ print $1 }')
    glibc_min=$( echo "$glibc_ver" | awk -F. '{ print $2 }')
    
    echo -n "- $glibc_nvr: "
    if [ "$glibc_maj" -gt 2   -o  \
        \( "$glibc_maj" -eq 2  -a  "$glibc_min" -ge 18 \) ]; then
        # fixed upstream version
        echo 'not vulnerable'
    else
        # all RHEL updates include CVE in rpm %changelog
        if rpm -q --changelog "$glibc_nvr" | grep -q 'CVE-2015-0235'; then
            echo "not vulnerable"
        else
            echo "vulnerable"
            rv=1
        fi
    fi
done

if [ $rv -ne 0 ]; then
    cat <<EOF

This system is vulnerable to CVE-2015-0235

EOF
fi

exit $rv
```

## 其他
yum update -y openssl bash

# 端口扫描
## nc
netcat是网络工具中的瑞士军刀，它能通过TCP和UDP在网络中读写数据。通过与其他工具结合和重定向，你可以在脚本中以多种方式使用它。使用netcat命令所能完成的事情令人惊讶。
`yum install nc`

`nc -z -v -n 172.31.100.7 21-25`

- 可以运行在TCP或者UDP模式，默认是TCP，-u参数调整为udp.
- z 参数告诉netcat使用0 IO,连接成功后立即关闭连接， 不进行数据交换(谢谢@jxing 指点)
- v 参数指使用冗余选项（译者注：即详细输出）
- n 参数告诉netcat 不要使用DNS反向查询IP地址的域名

```shell
nohup nc -z -v -n 111.13.47.164 1-65535 > 164.log &
```
