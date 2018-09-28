# 安全漏洞
## 只允许某个用户登录

修改`/etc/security/access.conf`

只允许`work`用户远程访问。

```sh
# All other users should be denied to get access from all sources.
#- : ALL : ALL
-:ALL EXCEPT work:ALL
```

进一步允许`cmana`用户访问。

```sh
# User "foo" and members of netgroup "nis_group" should be
# allowed to get access from all sources.
# This will only work if netgroup service is available.
#+ : @nis_group foo : ALL
+ : cmana : ALL
```

```sh
# vi /etc/pam.d/sshd
#%PAM-1.0
auth       required     pam_sepermit.so
auth       include      password-auth
# account    required     pam_nologin.so
account    required     pam_access.so
account    include      password-auth
password   include      password-auth
# pam_selinux.so close should be the first session rule
session    required     pam_selinux.so close
session    required     pam_loginuid.so
# pam_selinux.so open should only be followed by sessions to be executed in the user context
session    required     pam_selinux.so open env_params
session    optional     pam_keyinit.so force revoke
session    include      password-auth



#auth required /lib64/security/pam_listfile.so item=user sense=allow file=/etc/sshusers onerr=fail
#account   required    /lib64/security/pam_access.so
#session     required      /lib64/security/pam_limits.so
```

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

## 升级openssl
官网 ：https://www.openssl.org/source/

安装最新的openssl

```shell
wget https://www.openssl.org/source/openssl-1.0.2l.tar.gz --no-check-certificate
tar zxf openssl-1.0.2l.tar.gz
cd openssl-1.0.2l
./config shared zlib
make
make install
```

将原来的openssl备份

```sh
which openssl
mv /usr/bin/openssl /usr/bin/open1.0.1e
mv /usr/include/openssl/ /usr/include/openssl1.0.1e
```

将安装好的openssl 做链接到原来的路径，并加载库文件

```sh
ln -sv  /usr/local/ssl/bin/openssl /usr/bin/openssl
ln -sv /usr/local/ssl/include/openssl /usr/include/openssl
echo "/usr/local/ssl/lib" >> /etc/ld.so.conf
ldconfig -v
```

查看当前版本信息

```sh
[work@lab23 ~]$ openssl version -a
OpenSSL 1.0.2l  25 May 2017
built on: reproducible build, date unspecified
platform: linux-x86_64
options:  bn(64,64) rc4(16x,int) des(idx,cisc,16,int) idea(int) blowfish(idx)
compiler: gcc -I. -I.. -I../include  -fPIC -DOPENSSL_PIC -DZLIB -DOPENSSL_THREADS -D_REENTRANT -DDSO_DLFCN -DHAVE_DLFCN_H -Wa,--noexecstack -m64 -DL_ENDIAN -O3 -Wall -DOPENSSL_IA32_SSE2 -DOPENSSL_BN_ASM_MONT -DOPENSSL_BN_ASM_MONT5 -DOPENSSL_BN_ASM_GF2m -DRC4_ASM -DSHA1_ASM -DSHA256_ASM -DSHA512_ASM -DMD5_ASM -DAES_ASM -DVPAES_ASM -DBSAES_ASM -DWHIRLPOOL_ASM -DGHASH_ASM -DECP_NISTZ256_ASM
OPENSSLDIR: "/usr/local/openssl/ssl"
```

## apache

### 远程WWW服务支持TRACE请求
解决办法，修改`httpd.conf`，之后重启apache

```
# 启用Rewrite引擎
RewriteEngine On

# 对Request中的Method字段进行匹配：^TRACE 即以TRACE字符串开头
RewriteCond %{REQUEST_METHOD} ^TRACE

# 定义规则：对于所有格式的来源请求，均返回[F]-Forbidden响应
RewriteRule .* - [F]
```

对于2.0.55以上版本的apache服务器，有一种更简单的办法

```
TraceEnable off
```


## 其他
```shell
yum update -y openssl bash
```

