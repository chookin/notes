# 基础语法
## enum
enum定义了特殊的类别，继承自`java.lang.Enum`，不过这是由编译器处理，直接继承Enum类别会被编译器拒绝。
```java
enum Status {
    New(0),
    Inited(1),
    Running(2),
    Stop(3),
    Stopped(4);
    Status(int code){
        this.code = code;
    }
    private int code;
    public int code(){return code;}
}
```
常用方法
```java
Enum.valueOf // 从枚举常量的字符串值解析得到enum
#name // 获取枚举常量的名称
#compareTo // 按照枚举常量的声明次序做比较
```

# 技术点
## json序列化
### fastjson
采用fastjson序列化存在些问题，例如：
```java
List<List<String>> items = new ArrayList<>();
List<String> item = new ArrayList<>();
item.add("a");
item.add("b");
items.add(item);
items.add(item);
System.out.println(JSON.toJSONString(obj));
// 输出的是：[["a","b"],{"$ref":"$[0]"}]，而不是[["a","b"],["a","b"]]
```

## gson
自定义序列化样式
```java
// 将Date类型字段序列化为long型
// 
JsonSerializer<Date> dateSer = new JsonSerializer<Date>() {
  @Override
  public JsonElement serialize(Date src, Type typeOfSrc, JsonSerializationContext 
             context) {
    return src == null ? null : new JsonPrimitive(src.getTime());
  }
};

JsonDeserializer<Date> dateDeser = new JsonDeserializer<Date>() {
  @Override
  public Date deserialize(JsonElement json, Type typeOfT,
       JsonDeserializationContext context) throws JsonParseException {
    return json == null ? null : new Date(json.getAsLong());
  }
};

Gson gson = new GsonBuilder()
   .registerTypeAdapter(Date.class, dateSer)
   .registerTypeAdapter(Date.class, dateDeser)
   .create();

// 反序列化得到集合
public static Set<String> parseStringSet(String json) {
    return new Gson().fromJson(json, new TypeToken<Set<String>>() {}.getType());
}
```

# 并发
## java.util.concurrent
### ReadWriteLock
在多线程开发中，经常会出现一种情况，我们希望读写分离。就是对于读取这个动作来说，可以同时有多个线程同时去读取这个资源，但是对于写这个动作来说，只能同时有一个线程来操作，而且同时，当有一个写线程在操作这个资源的时候，其他的读线程是不能来操作这个资源的，这样就极大的发挥了多线程的特点，能很好的将多线程的能力发挥出来。在Java中，ReadWriteLock这个接口就为我们实现了这个需求，通过他的实现类ReentrantReadWriteLock我们可以很简单的来实现刚才的效果.
## ThreadLocal
ThreadLocal，它是线程绑定的变量，提供线程局部变量。ThreadLocal采用了“以空间换时间”的方式，为每一个线程提供一个独立的变量副本，A线程的ThreadLocal只能看到A线程的ThreadLocal，不能看到B线程的ThreadLocal。
## nio

同步非阻塞，服务器实现模式为一个请求一个线程，即客户端发送的连接请求都会注册到多路复用器上，多路复用器轮询到连接有I/O请求时才启动一个线程进行处理。
NIO方式适用于连接数目多且连接比较短（轻操作）的架构，比如聊天服务器，并发局限于应用中，编程比较复杂，JDK1.4开始支持。
## aio
异步非阻塞，服务器实现模式为一个有效请求一个线程，客户端的I/O请求都是由OS先完成了再通知服务器应用去启动线程进行处理，
AIO方式使用于连接数目多且连接比较长（重操作）的架构，比如相册服务器，充分调用OS参与并发操作，编程比较复杂，JDK7开始支持。
## jar
jar、.war格式，都是Zip压缩格式的文件.
# java tools
## jmx
### jmx简介
JMX的全称为Java Management Extensions. 顾名思义，是管理Java的一种扩展。这种机制可以方便的管理正在运行中的Java程序。常用于管理线程，内存，日志Level，服务重启，系统环境等。

JMX由三部分组成：

- 程序端的Instrumentation, 我把它翻译成可操作的仪器。这部分就是指的MBean. MBean类似于JavaBean。最常用的MBean则是Standard MBean和MXBean.
- 程序端的JMX agent. 这部分指的是MBean Server. MBean Server则是启动与JVM内的基于各种协议的适配器。用于接收客户端的调遣，然后调用相应的MBeans.
- 客户端的Remote Management. 这部分则是面向用户的程序。此程序则是MBeans在用户前投影，用户操作这些投影，可以反映到程序端的MBean中去。这内部的原理则是client通过某种协议调用agent操控MBeans.

### jmxclient
JDK提供了一个工具在jdk/bin目录下面，这就是JConsole。使用JConsole可以远程或本地连接JMX agent。
### jvisualvm
主要用来监控JVM的运行情况，可以用它来查看和浏览Heap Dump、Thread Dump、内存对象实例情况、GC执行情况、CPU消耗以及类的装载情况。
