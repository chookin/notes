# 安全漏洞
## ssh
升级ssh
```shell
wget http://mirror.team-cymru.org/pub/OpenBSD/OpenSSH/portable/openssh-6.9p1.tar.gz
tar zxvf openssh-6.9p1.tar.gz
# 需要先安装一些基础包
yum install -y gcc zlib-devel openssl-devel
./configure && make && make install
# ssh -V
OpenSSH_6.9p1, OpenSSL 1.0.1e-fIPs 11 Feb 2013
```

