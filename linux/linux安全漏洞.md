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

```shell
wget https://mirrors.evowise.com/pub/OpenBSD/OpenSSH/portable/openssh-7.5p1.tar.gz
```


## 幽灵(Ghost)漏洞CVE-201500235

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
```shell
yum update -y openssl bash
```

