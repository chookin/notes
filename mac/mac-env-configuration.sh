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

export PATH=/usr/local/opt/go/libexec/bin:$PATH

export PHPBREW_RC_ENABLE=1
export PHPBREW_SET_PROMPT=1
#source /Users/chookin/.phpbrew/bashrc

export PATH=/Users/chookin/Library/Android/sdk/platform-tools:$PATH

export HADOOP_HOME=$HOME/local/hadoop
export HADOOP_CONF_DIR=$HOME/local/hadoop-conf
export PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH
export HADOOP_HOME_WARN_SUPPRESS=1

export SPARK_HOME=$HOME/local/spark
export PATH=$SPARK_HOME/bin:$PATH

export SCALA_HOME=$HOME/local/scala
export PATH=$SCALA_HOME/bin:$PATH

export ZOOKEEPER_HOME=$HOME/local/zookeeper
export PATH=$ZOOKEEPER_HOME/bin:$PATH

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

alias grep='grep --color=auto'
alias mvnps='mvn package -DskipTests'
alias mvnis='mvn install -DskipTests'
alias gs='git status'
alias gc='git commit -a'
alias gpush='git push origin master'
alias gpull='git pull origin'

export HOMEBREW_GITHUB_API_TOKEN=4f6d2a0066f2c9de121c9ba775e8be5b8596f0e7

export SVN_EDITOR=vim

export JADX_HOME=$HOME/local/jadx
export PATH=$JADX_HOME/bin:$PATH

alias tree="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'"

alias admin_server="open /Users/chookin/快盘/notes/project-notes/服务器管理/服务器账户.msg -a 'Microsoft Excel'"

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
    ps aux |grep -v grep | grep $1
}
