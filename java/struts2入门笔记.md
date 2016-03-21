[TOC]
# 配置文件
## web.xml
Struts应用程序都有一个核心过滤器(filter dispatcher).FilterDispatcher是早期struts2的过滤器，自2.1.3开始使用StrutsPrepareAndExecuteFilter了.为了使用它，需在部署描述文件web.xml里使用filter和filter-mapping元素注册它。
```xml
<filter>
    <filter-name>struts2</filter-name>
    <filter-class>org.apache.struts2.dispatcher.ng.filter.StrutsPrepareAndExecuteFilter</filter-class>
</filter>
<filter-mapping>
    <filter-name>struts2</filter-name>
    <url-pattern>/*</url-pattern>
</filter-mapping>
```
Struts把任务处理交由子组件拦截器(interceptor)处理。
核心过滤器做的第一件事是，校验请求的URI并判断要调用哪个动作(action)和对哪个java动作类实例化。为了匹配URIs和动作类，Struts使用了配置文件struts.xml,该文件需存放在classpath路径下。

# struts.xml
在struts.xml中定义应用程序所需要的actions、interceptors以及results。
struts.xml是以struts为根元素的xml文件。

## package元素
Struts中用包组织actions。一个struts.xml文件可以有一个或多个package元素.
```xml
<struts>
    <package name="package-1" namespace="namespace-1"> extends="struts-default">
       <action name="..."/>
        <action name="..."/>
            ...
    </package>
        ...
    <package name="package-n" namespace="namespace-n"> extends="struts-default">
        <action name="..."/>
        <action name="..."/>
            ...
    </package>
</struts>
```
每个package元素都必须有一个name属性；namespace属性是可选的，默认值是'/'。若某namespace属性不是默认值，那么该package里面的action被调用的URI格式是：

```java
/context/{namespace}/actionName.action
```

package元素一般继承struts-default.xml文件中定义的struts-default包。通过该继承，该package里面的actions都能使用struts-default.xml中注册的结果类型(result-types)及拦截器。
一个大型应用可能有很多packages，为方便管理struts.xml，我们可以吧它划分成几个较小的文件，在每个文件中只定义一个包或几个彼此相关的包，然后用include元素在struts.xml中引用那些小文件。
```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE struts PUBLIC
    "-//Apache Software Foundation//DTD Struts Configuration 2.0//EN"
    "http://struts.apache.org/dtds/struts-2.0.dtd">
<struts>
    <include file="module-l.xml" /> 
    <include file="module-2.xml" /> 
    ...
    <include file="module-n.xml" />
</struts>
```

## global-results元素
如果某个action不能从其声明中找到匹配的返回结果，则将查询global-results中可用的。

# struts2与spring集成
需要的JAR文件为：Spring和Struts2框架本身需要的JAR文件以及他们所依赖的JAR文件，比如commons-logging.jar等等，另外还需要Struts2发布包中的struts2-spring-plugin-x.xx.jar。

struts2单独使用时action由struts2自己负责创建；与spring集成时，action实例由spring负责创建（依赖注入）。这导致在两种情况下struts.xml配置文件的略微差异。

假如：LoginAction在包cn.edu.jlu.cs.action中。

1.struts2单独使用时，action的class属性为LoginAction的全路径名，如下：
```xml
<action name="login" class="cn.edu.jlu.cs.action.LoginAction">
   <result name="studentSuccess">
        /student/studentindex.jsp
   </result>
```

2.struts2与spring集成时，class属性是spring的applicationContext.xml中配置的bean的id属性值。
```xml
<!-- struts.xml -->
<action name="login" class="LoginAction">
   <result name="studentSuccess">
        /student/studentindex.jsp
   </result>
</action>
```

```xml
<!-- applicationContext.xml    或者在spring相应的配置文件中 -->
<bean id="LoginAction" class="cn.edu.jlu.cs.action.LoginAction" />
```
# 参考

1. Struts design and programming: a tutorial.
