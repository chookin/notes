# 日志信息格式
日志信息格式中几个符号所代表的含义：

     -X号: X信息输出时左对齐；
     %p: 输出日志信息优先级，即DEBUG，INFO，WARN，ERROR，FATAL,
     %d: 输出日志时间点的日期或时间，默认格式为ISO8601，也可以在其后指定格式，比如：%d{yyy MMM dd HH:mm:ss,SSS}，输出类似：2002年10月18日 22：10：28，921
     %r: 输出自应用启动到输出该log信息耗费的毫秒数
     %c: 输出日志信息所属的类目，通常就是所在类的全名
     %t: 输出产生该日志事件的线程名
     %l: 输出日志事件的发生位置，相当于%C.%M(%F:%L)的组合,包括类目名、发生的线程，以及在代码中的行数。举例：Testlog4.main (TestLog4.java:10)
     %x: 输出和当前线程相关联的NDC(嵌套诊断环境),尤其用到像java servlets这样的多客户多线程的应用中。
     %%: 输出一个"%"字符
     %F: 输出日志消息产生时所在的文件名称
     %L: 输出代码中的行号
     %m: 输出代码中指定的消息,产生的日志具体信息
     %n: 输出一个回车换行符，Windows平台为"/r/n"，Unix平台为"/n"输出日志信息换行
     可以在%与模式字符之间加上修饰符来控制其最小宽度、最大宽度、和文本的对齐方式。如：
     1)%20c：指定输出category的名称，最小的宽度是20，如果category的名称小于20的话，默认的情况下右对齐。
     2)%-20c:指定输出category的名称，最小的宽度是20，如果category的名称小于20的话，"-"号指定左对齐。
     3)%.30c:指定输出category的名称，最大的宽度是30，如果category的名称大于30的话，就会将左边多出的字符截掉，但小于30的话也不会有空格。
     4)%20.30c:如果category的名称小于20就补空格，并且右对齐，如果其名称长于30字符，就从左边较远输出的字符截掉。

# 中文乱码
```
#设置输出日志文件编码（可以控制乱码情况）
log4j.appender.file.encoding=UTF-8
```

# 示例
```shell
log4j.rootLogger=TRACE, stdout, logfile
log4j.logger.org=TRACE
log4j.logger.org.apache.http=INFO
log4j.logger.chookin=TRACE

## CONSOLE appender
log4j.appender.stdout=org.apache.log4j.ConsoleAppender
log4j.appender.stdout.Threshold=TRACE
log4j.appender.stdout.layout=org.apache.log4j.PatternLayout
log4j.appender.stdout.layout.ConversionPattern=%d,%p,\t%l,%m%n

## Log FileHelper appender
# 每天产生一个日志文件(dailyFile)
log4j.appender.logfile=org.apache.log4j.DailyRollingFileAppender
log4j.appender.logfile.Threshold=TRACE
#当天的日志文件全路径
log4j.appender.logfile.File=./logs/food-extract-${host.name.time}.log
#服务器启动日志是追加，false：服务器启动后会生成日志文件把老的覆盖掉
log4j.appender.logfile.Append=true
#日志文件格式
log4j.appender.logfile.layout=org.apache.log4j.PatternLayout
log4j.appender.logfile.layout.ConversionPattern=%d,%p,%t,%l,%m%n
#设置每天生成一个文件名后添加的名称,备份名称：年月日.log
log4j.appender.logfile.DatePattern='.'yyyy-MM-dd'.log'
```
