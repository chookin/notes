export JAVA_HOME=$HOME/local/jdk
export CLASSPATH="$JAVA_HOME/lib:$JAVA_HOME/jre/lib:$CLASSPATH"
export PATH=$JAVA_HOME/bin:$PATH

jdk7() {
    export JAVA_7_HOME=/Library/Java/JavaVirtualMachines/jdk1.7.0_79.jdk/Contents/Home
    export JAVA_HOME=$JAVA_7_HOME
    export CLASSPATH="$JAVA_HOME/lib:$JAVA_HOME/jre/lib:$CLASSPATH"
    export PATH=$JAVA_HOME/bin:$PATH
}

jdk8() {
    export JAVA_8_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_73.jdk/Contents/Home
    export JAVA_HOME=$JAVA_8_HOME
    export CLASSPATH="$JAVA_HOME/lib:$JAVA_HOME/jre/lib:$CLASSPATH"
    export PATH=$JAVA_HOME/bin:$PATH
}

#jdk7
jdk8

export APACHE_HOME=$HOME/local/apache
export PATH=$APACHE_HOME/bin:$PATH

export PHP_HOME=$HOME/local/php
export PATH=$PHP_HOME/bin:$PATH

export PYTHON_HOME=$HOME/local/python
export PATH=${PYTHON_HOME}/bin:$PATH

export JAVA_HOME=$HOME/local/jdk
export CLASSPATH="$JAVA_HOME/lib:$JAVA_HOME/jre/lib:$CLASSPATH"
export PATH=$JAVA_HOME/bin:$PATH

export MYSQL_HOME=$HOME/local/mysql
export PATH=$MYSQL_HOME/bin:$PATH

export SYSBENCH_PATH=$HOME/local/sysbench
export PATH=$SYSBENCH_PATH/bin:$PATH

export MONGO_HOME=$HOME/local/mongodb
export PATH=$MONGO_HOME/bin:$PATH

export REDIS_HOME=$HOME/local/redis
export PATH=$REDIS_HOME/bin:$PATH

export MEMCACHED_HOME=$HOME/local/memcached
export PATH=$MEMCACHED_HOME/bin:$PATH

export JETTY_HOME=$HOME/local/jetty
export PATH=$JETTY_HOME/bin:$PATH

export ANDROID_HOME=$HOME/Library/Android/sdk

export MYCAT_HOME=$HOME/project/learning/Mycat-Server

export MAVEN_HOME=$HOME/local/apache-maven
export PATH=$MAVEN_HOME/bin:$PATH

export GRADLE_HOME=$HOME/local/gradle
export PATH=$GRADLE_HOME/bin:$PATH

export PHANTOM_HOME=$HOME/local/phantomjs
export PATH=$PHANTOM_HOME/bin:$PATH

export CASPER_JS_HOME=$HOME/local/casperjs
export PATH=$CASPER_JS_HOME/bin:$PATH

export JADX_HOME=$HOME/local/jadx
export PATH=$JADX_HOME/bin:$PATH

# configure terminal color
export CLICOLOR=1
export LSCOLORS=gxfxaxdxcxegedabagacad

export LD_LIBRARY_PATH=/home/`whoami`/local/mysql/lib:$LD_LIBRARY_PATH

# 历史命令最大条数
HISTFILESIZE=100000
# 历史命令添加时间戳
HISTTIMEFORMAT="%F %T "
export HISTTIMEFORMAT

alias ll="ls -all"

alias vi='/usr/bin/vim'
alias mvnps='mvn package -DskipTests'
alias mvnis='mvn install -DskipTests'
alias gs='git status'
alias gc='git commit -a'
alias gpush='git push origin master'
alias gpull='git pull origin'

export SVN_EDITOR=vim

alias tree="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'"

# set up a UTF-8 environment if the default encoding is not utf-8
# ref: http://perlgeek.de/en/article/set-up-a-clean-utf8-environment
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export SVN_EDITOR=vim

alias grep='grep --color=auto'
alias mystrace="strace -tt -T -f -ff -o stracelog -s 1024 -p "
function mykill(){
    keyword=$1
    user_name=$(whoami)
    ps -u ${user_name} -f |grep ${keyword} | grep -v grep |awk '{print $2}'|xargs kill -9
}

function myps() {
    ps -C $1 -f
}
