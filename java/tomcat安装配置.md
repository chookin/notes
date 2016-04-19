[TOC]
# 简介
Tomcat 服务器是一个免费的开放源代码的Web 应用服务器，Tomcat是Apache 软件基金会（Apache Software Foundation）的Jakarta 项目中的一个核心项目，它早期的名称为catalina，后来由Apache、Sun 和其他一些公司及个人共同开发而成，并更名为Tomcat。Tomcat 是一个小型的轻量级应用服务器，在中小型系统和并发访问用户不是很多的场合下被普遍使用，是开发和调试JSP 程序的首选，因为Tomcat 技术先进、性能稳定，成为目前比较流行的Web 应用服务器。Tomcat是应用（java）服务器，它只是一个servlet容器，是Apache的扩展，但它是独立运行的。目前最新的版本为Tomcat 8.0.24 Released
。
## Tomcat的架构
Tomcat 6支持Servlet 2.5和JSP 2.1的规范，它由一组嵌套的层次和组件组成，一般可分为以下四类：

- 顶级组件：位于配置层次的顶级，并且彼此间有着严格的对应关系；
- 连接器：连接客户端（可以是浏览器或Web服务器）请求至Servlet容器，
- 容器：包含一组其它组件；
- 被嵌套的组件：位于一个容器当中，但不能包含其它组件；

## 各常见组件

1. 服务器(server)：Tomcat的一个实例，通常一个JVM只能包含一个Tomcat实例；因此，一台物理服务器上可以在启动多个JVM的情况下在每一个JVM中启动一个Tomcat实例，每个实例分属于一个独立的管理端口。这是一个顶级组件。
2. 服务(service)：一个服务组件通常包含一个引擎和与此引擎相关联的一个或多个连接器。给服务命名可以方便管理员在日志文件中识别不同服务产生的日志。**一个server可以包含多个service组件，但通常情下只为一个service指派一个server**.
3. 连接器(connectors)：负责连接客户端（可以是浏览器或Web服务器）请求至Servlet容器内的Web应用程序，通常指的是接收客户发来请求的位置及服务器端分配的端口。默认端口通常是HTTP协议的8080，管理员也可以根据自己的需要改变此端口。一个引擎可以配置多个连接器，但这些连接器必须使用不同的端口。默认的连接器是基于HTTP/1.1的Coyote。同时，Tomcat也支持AJP、JServ和JK2连接器。
4. 引擎(Engine)：引擎通是指处理请求的Servlet引擎组件，即Catalina Servlet引擎，它检查每一个请求的HTTP首部信息以辨别此请求应该发往哪个host或context，并将请求处理后的结果返回的相应的客户端。严格意义上来说，容器不必非得通过引擎来实现，它也可以是只是一个容器。如果Tomcat被配置成为独立服务器，默认引擎就是已经定义好的引擎。而如果Tomcat被配置为Apache Web服务器的提供Servlet功能的后端，默认引擎将被忽略，因为Web服务器自身就能确定将用户请求发往何处。一个引擎可以包含多个host组件。
5. 主机(Host)：主机组件类似于Apache中的虚拟主机，但在Tomcat中只支持基于FQDN的“虚拟主机”。一个引擎至少要包含一个主机组件。
6. 上下文(Context)：Context组件是最内层次的组件，它表示Web应用程序本身。配置一个Context最主要的是指定Web应用程序的根目录，以便Servlet容器能够将用户请求发往正确的位置。Context组件也可包含自定义的错误页，以实现在用户访问发生错误时提供友好的提示信息。
7. 阀门(Valve)：用来拦截请求并在将其转至目标之前进行某种处理操作，类似于Servlet规范中定义的过滤器。Valve可以定义在任何容器类的组件中。Valve常被用来记录客户端请求、客户端IP地址和服务器等信息，这种处理技术通常被称作请求转储(request dumping)。请求转储valve记录请求客户端请求数据包中的HTTP首部信息和cookie信息文件中，响应转储valve则记录响应数据包首部信息和cookie信息至文件中。
8. 日志记录器(Logger)：用于记录组件内部的状态信息，可被用于除Context之外的任何容器中。日志记录的功能可被继承，因此，一个引擎级别的Logger将会记录引擎内部所有组件相关的信息，除非某内部组件定义了自己的Logger组件。
9. 领域(Realm)：用于用户的认证和授权；在配置一个应用程序时，管理员可以为每个资源或资源组定义角色及权限，而这些访问控制功能的生效需要通过Realm来实现。Realm的认证可以基于文本文件、数据库表、LDAP服务等来实现。Realm的效用会遍及整个引擎或顶级容器，因此，一个容器内的所有应用程序将共享用户资源。同时，Realm可以被其所在组件的子组件继承，也可以被子组件中定义的Realm所覆盖。

## Tomcat连接器架构

基于Apache做为Tomcat前端的架构来讲，Apache通过mod_jk、mod_jk2或mod_proxy模块与后端的Tomcat进行数据交换。而对Tomcat来说，每个Web容器实例都有一个Java语言开发的连接器模块组件，在Tomcat6中，这个连接器是`org.apache.catalina.Connector`类。这个类的构造器可以构造两种类别的连接器：
- HTTP/1.1负责响应基于HTTP/HTTPS协议的请求;
- AJP/1.3负责响应基于AJP的请求。

可以简单地通过在server.xml配置文件中实现连接器的创建，但创建时所使用的类根据系统是支持APR(Apache Portable Runtime)而有所不同。
APR是附加在提供了通用和标准API的操作系统之上一个通讯层的本地库的集合，它能够为使用了APR的应用程序在与Apache通信时提供较好伸缩能力时带去平衡效用。
同时，需要说明的是，mod_jk2模块目前已经不再被支持了，mod_jk模块目前还apache被支持，但其项目活跃度已经大大降低。因此，目前更常用 的方式是使用mod_proxy模块。
如果支持APR：

    HTTP/1.1：org.apache.cotote.http11.Http11AprProtocol
    AJP/1.3：org.apache.coyote.ajp.AjpAprProtocol
如果不支持APR：

    HTTP/1.1: org.apache.coyote.http11.Http11Protocol
    AJP/1.3: org.apache.jk.server.JkCoyoteHandler

## 连接器协议
Tomcat的Web服务器连接器支持两种协议：AJP和HTTP，它们均定义了以二进制格式在Web服务器和Tomcat之间进行数据传输，并提供相应的控制命令。

- AJP(Apache JServ Protocol)协议：目前正在使用的AJP协议的版本是通过JK和JK2连接器提供支持的AJP13，它基于二进制的格式在Web服务器和Tomcat之间传输数据，而此前的版本AJP10和AJP11则使用文本格式传输数据。
- HTTP协议：诚如其名称所表示，其是使用HTTP或HTTPS协议在Web服务器和Tomcat之间建立通信，此时，Tomcat就是一个完全功能的HTTP服务器，它需要监听在某端口上以接收来自于商前服务器的请求。

# 安装
需要先按照jdk。
之后下载tomcat，解压缩即可。

    wget http://mirror.bit.edu.cn/apache/tomcat/tomcat-6/v6.0.45/bin/apache-tomcat-6.0.45.tar.gz

查看版本信息
```
$ catalina.sh version
Using CATALINA_BASE:   /home/zhuyin/local/apache-tomcat
Using CATALINA_HOME:   /home/zhuyin/local/apache-tomcat
Using CATALINA_TMPDIR: /home/zhuyin/local/apache-tomcat/temp
Using JRE_HOME:        /home/zhuyin/local/jdk
Using CLASSPATH:       /home/zhuyin/local/apache-tomcat/bin/bootstrap.jar
Server version: Apache Tomcat/6.0.45
Server built:   Feb 1 2016 18:08:10 UTC
Server number:  6.0.45.0
OS Name:        Linux
OS Version:     2.6.32-431.el6.x86_64
Architecture:   amd64
JVM Version:    1.7.0_79-b15
JVM Vendor:     Oracle Corporation
```

# 启停

    bin/startup.sh
    bin/shutdown.sh
# 配置文件详解

## 配置文件

- server.xml: Tomcat的主配置文件，包含Service, Connector, Engine, Realm, Valve, Hosts主组件的相关配置信息；
- web.xml：遵循Servlet规范标准的配置文件，用于配置servlet，并为所有的Web应用程序提供包括MIME映射等默认配置信息；
- tomcat-user.xml：Realm认证时用到的相关角色、用户和密码等信息；Tomcat自带的manager默认情况下会用到此文件；在Tomcat中添加/删除用户，为用户指定角色等将通过编辑此文件实现；-
- catalina.policy：Java相关的安全策略配置文件，在系统资源级别上提供访问控制的能力；
- catalina.properties：Tomcat内部package的定义及访问相关的控制，也包括对通过类装载器装载的内容的控制；Tomcat6在启动时会事先读取此文件的相关设置；
- logging.properties: Tomcat6通过自己内部实现的JAVA日志记录器来记录操作相关的日志，此文件即为日志记录器相关的配置信息，可以用来定义日志记录的组件级别以及日志文件的存在位置等；
- context.xml：所有host的默认配置信息；

## server.xml

Tomcat以面向对象的方式运行，它可以在运行时动态加载配置文件中定义的对象结构，这有点类似于apache的httpd模块的调用方式。server.xml中定义的每个主元素都会被创建为对象，并以某特定的层次结构将这些对象组织在一起。下面是个样例配置：

```xml
<Server port=”8005″ shutdown=”SHUTDOWN”>

　　<Listener className=”org.apache.catalina.core.Jas<a href="http://www.ttlsa.com/perl/" title="perl"target="_blank">perL</a>istener” />
　　<Listener className=”org.apache.catalina.mbeans.ServerLifecycleListener” />
　　<Listener className=”org.apache.catalina.mbeans.GlobalResourcesLifecycleListener” />

　　<GlobalNamingResources>
　　　<Resource name=”UserDatabase” auth=”Container”
　　　type=”org.apache.catalina.UserDatabase”
　　　description=”User database that can be updated and saved”
　　　factory=”org.apache.catalina.users.MemoryUserDatabaseFactory”
　　　pathname=”conf/tomcat-users.xml”/>
　　</GlobalNamingResources>

　　<Service name=”Catalina”>

　　　　<Connector port=”8080″ protocol=”HTTP/1.1″
　　　　　　maxThreads=”150″ connectionTimeout=”20000″
　　　　　　redirectPort=”8443″/>

　　　　<Engine name=”Catalina” defaultHost=”localhost”>

　　　　　　<Host name=”localhost” appBase=”webapps”
　　　　　　　　unpackWARs=”true” autoDeploy=”true”
　　　　　　　　xmlValidation=”false” xmlNamespaceAware=”false”>
　　　　　　</Host>
　　　　</Engine>
　　</Service>
</Server>

<Server port=”8005″ shutdown=”SHUTDOWN”>
　　<Listener className=”org.apache.catalina.core.AprLifecycleListener” SSLEngine=”on” />
　　<Listener className=”org.apache.catalina.core.JasperListener” />
　　<Listener className=”org.apache.catalina.core.JreMemoryLeakPreventionListener” />
　　<Listener className=”org.apache.catalina.mbeans.GlobalResourcesLifecycleListener” />
　　<Listener className=”org.apache.catalina.core.ThreadLocalLeakPreventionListener” />

　　<GlobalNamingResources>
　　　　<Resource name=”UserDatabase” auth=”Container”
　　　　　　type=”org.apache.catalina.UserDatabase”
　　　　　　description=”User database that can be updated and saved”
　　　　　　factory=”org.apache.catalina.users.MemoryUserDatabaseFactory”
　　　　　　pathname=”conf/tomcat-users.xml” />
　　</GlobalNamingResources>

　　<Service name=”Catalina”>

　　　　<Connector port=”8080″ protocol=”HTTP/1.1″
　　　　　　connectionTimeout=”20000″
　　　　　　redirectPort=”8443″ />
　　　　<Connector port=”8009″ protocol=”AJP/1.3″ redirectPort=”8443″ />

　　　　<Engine name=”Catalina” defaultHost=”localhost”>

　　　　　<Realm className=”org.apache.catalina.realm.LockOutRealm”>
　　　　　　　<Realm className=”org.apache.catalina.realm.UserDatabaseRealm”
　　　　　　　　　　　resourceName=”UserDatabase”/>
　　　　　</Realm>

　　　　　<Host name=”localhost” appBase=”webapps”
　　　　　　　　　unpackWARs=”true” autoDeploy=”true”>

　　　　　　　<Valve className=”org.apache.catalina.valves.AccessLogValve” directory=”logs”
　　　　　　　　　　　prefix=”localhost_access_log.” suffix=”.txt”
　　　　　　　　　　　pattern=”%h %l %u %t &quot;%r&quot; %s %b” />

　　　　　</Host>
　　　　</Engine>
　　</Service>
</Server>
```

server.xml文件中可定义的元素非常多，包括Server, Service, Connector, Engine, Cluster, Host, Alias, Context, Realm, Valve, Manager, Listener, Resources, Resource, ResourceEnvRef, ResourceLink, WatchedResource, GlobalNameingResources, Store, Transaction, Channel, Membership, Transport, Member, ClusterListener等。
下面简单介绍几个常用组件。

### Server组件

    <Server port=”8005” shutdown=”SHUTDOWN”>

这会让Tomcat6启动一个server实例（即一个JVM），它监听在8005端口以接收shutdown命令，使用 telnet 连接8005 端口可以直接执行 SHUTDOWN 命令来关闭 Tomcat。各Server的定义不能使用同一个端口，这意味着如果在同一个物理机上启动了多个Server实例，必须配置它们使用不同的端口。这个端口的定义用于为管理员提供一个关闭此实例的便捷途径，因此，管理员可以直接telnet至此端口使用SHUTDOWN命令关闭此实例。不过，基于安全角度的考虑，这通常不允许远程进行。
Server的相关属性：

- className: 用于实现此Server容器的完全限定类的名称，默认为org.apache.catalina.core.StandardServer；
- port: 接收shutdown指令的端口，默认仅允许通过本机访问，默认为8005；
- shutdown：发往此Server用于实现关闭tomcat实例的命令字符串，默认为SHUTDOWN；

### Service组件
Service主要用于关联一个引擎和与此引擎相关的连接器，每个连接器通过一个特定的端口和协议接收入站请求交将其转发至关联的引擎进行处理。困此，Service要包含一个引擎、一个或多个连接器。
    
    <Service name=”Catalina”>
这定义了一个名为Catalina的Service，此名字也会在产生相关的日志信息时记录在日志文件当中。
Service相关的属性：

- className： 用于实现service的类名，一般都是org.apache.catalina.core.StandardService。
- name：此服务的名称，默认为Catalina；

### Connector组件
进入Tomcat的请求可以根据Tomcat的工作模式分为如下两类：
1. Tomcat作为应用程序服务器：请求来自于前端的web服务器，这可能是Apache, IIS, Nginx等；
2. Tomcat作为独立服务器：请求来自于web浏览器；

Tomcat应该考虑工作情形并为相应情形下的请求分别定义好需要的连接器才能正确接收来自于客户端的请求。一个引擎可以有一个或多个连接器，以适应多种请求方式。
定义连接器可以使用多种属性，有些属性也只适用于某特定的连接器类型。一般说来，常见于server.xml中的连接器类型通常有4种：
1) HTTP连接器
2) SSL连接器
3) AJP 1.3连接器
4) proxy连接器
如下面定义的HTTP连接器：

    <Connector port=”8080″ protocol=”HTTP/1.1″ maxThreads=”150″ connectionTimeout=”20000″ redirectPort=”8443″/>

定义连接器时可以配置的属性非常多，但通常定义HTTP连接器时必须定义的属性只有“port“，定义AJP连接器时必须定义的属性只有”protocol”，因为默认的协议为HTTP。以下为常用属性的说明：
1) address：指定连接器监听的地址，默认为所有地址，即0.0.0.0;
2) maxThreads：支持的最大并发连接数，默认为200；
3) port：监听的端口，默认为0；
4) protocol：连接器使用的协议，默认为HTTP/1.1，定义AJP协议时通常为AJP/1.3；
5) redirectPort：如果某连接器支持的协议是HTTP，当接收客户端发来的HTTPS请求时，则转发至此属性定义的端口；
6) connectionTimeout：等待客户端发送请求的超时时间，单位为毫秒，默认为60000，即1分钟；
7) enableLookups：是否通过request.getRemoteHost()进行DNS查询以获取客户端的主机名；默认为true； 进行反解的，可以设置为false
8) acceptCount：设置等待队列的最大长度；通常在tomcat所有处理线程均处于繁忙状态时，新发来的请求将被放置于等待队列中；

下面是一个定义了多个属性的SSL连接器：

```xml
<Connector port=”8443″ maxThreads=”150″ minSpareThreads=”25″ maxSpareThreads=”75″ enableLookups=”false” acceptCount=”100″ debug=”0″ scheme=”https” secure=”true” clientAuth=”false” sslProtocol=”TLS” />
```

### Engine组件：
Engine是Servlet处理器的一个实例，即servlet引擎，默认为定义在server.xml中的Catalina。Engine需要defaultHost属性来为其定义一个接收所有发往非明确定义虚拟主机的请求的host组件。如：

```xml
<Engine name=”Catalina” defaultHost=”localhost”>
```

常用的属性定义:
- defaultHost：Tomcat支持基于FQDN的虚拟主机，这些虚拟主机可以通过在Engine容器中定义多个不同的Host组件来实现；但如果此引擎的连接器收到一个发往非非明确定义虚拟主机的请求时则需要将此请求发往一个默认的虚拟主机进行处理，因此，在Engine中定义的多个虚拟主机的主机名称中至少要有一个跟defaultHost定义的主机名称同名；
- name：Engine组件的名称，用于日志和错误信息记录时区别不同的引擎.

Engine容器中可以包含Realm、Host、Listener和Valve子容器。

### Host组件
位于Engine容器中用于接收请求并进行相应处理的主机或虚拟主机，如

```xml
<Host name=”localhost” appBase=”webapps” unpackWARs=”true” autoDeploy=”true” xmlValidation=”false” xmlNamespaceAware=”false”> </Host>
```

常用属性说明：
1) appBase：此Host的webapps目录，即存放非归档的web应用程序的目录或归档后的WAR文件的目录路径；可以使用基于$CATALINA_HOME的相对路径；
2) autoDeploy：在Tomcat处于运行状态时放置于appBase目录中的应用程序文件是否自动进行deploy；默认为true；
3) unpackWars：在启用此webapps时是否对WAR格式的归档文件先进行展开；默认为true；

虚拟主机定义示例：
<Engine name=”Catalina” defaultHost=”localhost”>
    <Host name=”localhost” appBase=”webapps”>
        <Context path=”” docBase=”ROOT”/>
        <Context path=”/bbs” docBase=”/web/bss”
            reloadable=”true” crossContext=”true”/>
    </Host>
    <Host name=”mail.magedu.com” appBase=”/web/mail”>
        <Context path=”” docBase=”ROOT”/>
    </Host>
</Engine>

主机别名定义：
如果一个主机有两个或两个以上的主机名，额外的名称均可以以别名的形式进行定义，如下：
```xml
<Host name=”www.ttlsa.com” appBase=”webapps” unpackWARs=”true”>
    <Alias>feiyu.com</Alias>
</Host>
```

### Context组件：
Context在某些意义上类似于apache中的路径别名，一个Context定义用于标识tomcat实例中的一个Web应用程序；如下面的定义：
```xml
<!– Tomcat Root Context –>
<Context path=”” docBase=”/web/webapps”/>
<!– buzzin webapp –>
<Context path=”/bbs”
docBase=”/web/threads/bbs”
reloadable=”true”>
</Context>
<!– chat server –>
<Context path=”/chat” docBase=”/web/chat”/>
<!– darian web –>
<Context path=”/darian” docBase=”darian”/>
```

在Tomcat6中，每一个context定义也可以使用一个单独的XML文件进行，其文件的目录为`$CATALINA_HOME/conf//`。可以用于Context中的XML元素有Loader，Manager，Realm，Resources和WatchedResource。
常用的属性定义有：
1) docBase：相应的Web应用程序的存放位置；也可以使用相对路径，起始路径为此Context所属Host中appBase定义的路径；切记，docBase的路径名不能与相应的Host中appBase中定义的路径名有包含关系，比如，如果appBase为deploy，而docBase绝不能为deploy-bbs类的名字；
2) path：相对于Web服务器根路径而言的URI；如果为空“”，则表示为此webapp的根路径；如果context定义在一个单独的xml文件中，此属性不需要定义，有可能是别名；
3) reloadable：是否允许重新加载此context相关的Web应用程序的类；默认为false；

### Realm组件：
一个Realm表示一个安全上下文，它是一个授权访问某个给定Context的用户列表和某用户所允许切换的角色相关定义的列表。因此，Realm就像是一个用户和组相关的数据库。定义Realm时惟一必须要提供的属性是classname，它是Realm的多个不同实现，用于表示此Realm认证的用户及角色等认证信息的存放位置。

```
JAASRealm：基于Java Authintication and Authorization Service实现用户认证；
JDBCRealm：通过JDBC访问某关系型数据库表实现用户认证；
JNDIRealm：基于JNDI使用目录服务实现认证信息的获取；
MemoryRealm：查找tomcat-user.xml文件实现用户信息的获取；
UserDatabaseRealm：基于UserDatabase文件(通常是tomcat-user.xml)实现用户认证，它实现是一个完全可更新和持久有效的MemoryRealm，因此能够跟标准的MemoryRealm兼容；它通过JNDI实现；
```

下面是一个常见的使用UserDatabase的配置：

    <Realm className=”org.apache.catalina.realm.UserDatabaseRealm” resourceName=”UserDatabase”/>
下面是一个使用JDBC方式获取用户认证信息的配置：
```xml
<Realm className=”org.apache.catalina.realm.JDBCRealm” debug=”99″
    driverName=”org.gjt.mm.mysql.Driver”
    connectionURL=”jdbc:mysql://localhost/authority”
    connectionName=”test” connectionPassword=”test”
    userTable=”users” userNameCol=”user_name”
    userCredCol=”user_pass”
    userRoleTable=”user_roles” roleNameCol=”role_name” />
```

### Valve组件
Valve类似于过滤器，它可以工作于Engine和Host/Context之间、Host和Context之间以及Context和Web应用程序的某资源之间。一个容器内可以建立多个Valve，而且Valve定义的次序也决定了它们生效的次序。Tomcat6中实现了多种不同的Valve：

```
AccessLogValve：访问日志Valve
ExtendedAccessValve：扩展功能的访问日志Valve
JDBCAccessLogValve：通过JDBC将访问日志信息发送到数据库中；
RequestDumperValve：请求转储Valve；
RemoteAddrValve：基于远程地址的访问控制；
RemoteHostValve：基于远程主机名称的访问控制；
SemaphoreValve：用于控制Tomcat主机上任何容器上的并发访问数量；
JvmRouteBinderValve：在配置多个Tomcat为以Apache通过mod_proxy或mod_jk作为前端的集群架构中，当期望停止某节点时，可以通过此Valve将用记请求定向至备用节点；使用此Valve，必须使JvmRouteSessionIDBinderListener；
ReplicationValve：专用于Tomcat集群架构中，可以在某个请求的session信息发生更改时触发session数据在各节点间进行复制；
SingleSignOn：将两个或多个需要对用户进行认证webapp在认证用户时连接在一起，即一次认证即可访问所有连接在一起的webapp；
ClusterSingleSingOn：对SingleSignOn的扩展，专用于Tomcat集群当中，需要结合ClusterSingleSignOnListener进行工作；
```

RemoteHostValve和RemoteAddrValve可以分别用来实现基于主机名称和基于IP地址的访问控制，控制本身可以通过allow或deny来进行定义，这有点类似于Apache的访问控制功能；如下面的Valve则实现了仅允许本机访问/probe：

```xml
<Context path=”/probe” docBase=”probe”>
    <Valve className=”org.apache.catalina.valves.RemoteAddrValve”
    allow=”127\.0\.0\.1″/>
</Context>
```

其中相关属性定义有:
1) className：相关的java实现的类名，相应于分别应该为org.apache.catalina.valves.RemoteHostValve或org.apache.catalina.valves.RemoteAddrValve；
2) allow：以逗号分开的允许访问的IP地址列表，支持正则表达式，因此，点号“.”用于IP地址时需要转义；仅定义allow项时，非明确allow的地址均被deny；
3) deny: 以逗号分开的禁止访问的IP地址列表，支持正则表达式；使用方式同allow；

### GlobalNamingResources
应用于整个服务器的JNDI映射，此可以避免每个Web应用程序都需要在各自的web.xml创建，这在web应用程序以WAR的形式存在时尤为有用。它通常可以包含三个子元素：Environment，Resource、ResourceEnvRef。

### WatchedResource
WatchedResource可以用于Context中监视指定的webapp程序文件的改变，并且能够在监视到文件内容发生改变时重新装载此文件。

### Listener
Listener用于创建和配置LifecycleListener对象，而LifecycleListener通常被开发人员用来创建和删除容器。

### Loader
Java的动态装载功能是其语言功能强大表现之一，Servlet容器使用此功能在运行时动态装载servlet和它们所依赖的类。Loader可以用于Context中控制java类的加载。

### Manager
Manger对象用于实现HTTP会话管理的功能，Tomcat6中有5种Manger的实现：
1) StandardManager
Tomcat6的默认会话管理器，用于非集群环境中对单个处于运行状态的Tomcat实例会话进行管理。当Tomcat关闭时，这些会话相关的数据会被写入磁盘上的一个名叫SESSION.ser的文件，并在Tomcat下次启动时读取此文件。
2) PersistentManager
当一个会话长时间处于空闲状态时会被写入到swap会话对象，这对于内存资源比较吃紧的应用环境来说比较有用。
3)DeltaManager
用于Tomcat集群的会话管理器，它通过将改变了会话数据同步给集群中的其它节点实现会话复制。这种实现会将所有会话的改变同步给集群中的每一个节点，也是在集群环境中用得最多的一种实现方式。
4)BackupManager
用于Tomcat集群的会话管理器，与DeltaManager不同的是，某节点会话的改变只会同步给集群中的另一个而非所有节点。
5)SimpleTcpReplicationManager
Tomcat4时用到的版本，过于老旧了。

### Stores
PersistentManager必须包含一个Store元素以指定将会话数据存储至何处。这通常有两种实现方式：FileStore和JDBCStore。

### Resources
经常用于实现在Context中指定需要装载的但不在Tomcat本地磁盘上的应用资源，如Java类，HTML页面，JSP文件等。

### Cluster
专用于配置Tomcat集群的元素，可用于Engine和Host容器中。在用于Engine容器中时，Engine中的所有Host均支持集群功能。在Cluster元素中，需要直接定义一个Manager元素，这个Manager元素有一个其值为org.apache.catalina.ha.session.DeltaManager或org.apache.catalina.ha.session.BackupManager的className属性。同时，Cluster中还需要分别定义一个Channel和ClusterListener元素。
1、Channel
用于Cluster中给集群中同一组中的节点定义通信“信道”。Channel中需要至少定义Membership、Receiver和Sender三个元素，此外还有一个可选元素Interceptor。
2、Membership
用于Channel中配置同一通信信道上节点集群组中的成员情况，即监控加入当前集群组中的节点并在各节点间传递心跳信息，而且可以在接收不到某成员的心跳信息时将其从集群节点中移除。Tomcat6中Membership的实现是org.apache.catalina.tribes.membership.McastService。
3、Sender
用于Channel中配置“复制信息”的发送器，实现发送需要同步给其它节点的数据至集群中的其它节点。发送器不需要属性的定义，但可以在其内部定义一个Transport元素。
4 Transport
用于Sender内部，配置数据如何发送至集群中的其它节点。Tomcat6有两种Transport的实现：
1) PooledMultiSender
基于Java阻塞式IO，可以将一次将多个信息并发发送至其它节点，但一次只能传送给一个节点。
2)PooledParallelSener
基于Java非阻塞式IO，即NIO，可以一次发送多个信息至一个或多个节点。
5 Receiver
用于Channel定义某节点如何从其它节点的Sender接收复制数据，Tomcat6中实现的接收方式有两种BioReceiver和NioReceiver。

### 小结
Tomcat 的配置层次，各组件之间的关系
```xml
<server>
    <service>
    <connector/>
    <engine>
        <host>
            <context>
            </context>
        </host>
        <host>
        </host>
    </engine>
    </service>
</server>
````
顶级组件：位于整个配置的顶层；<server>
容器类：可以包含其它组件的组件；<service>
连接器组件：连接用户请求至tomcat；<connector />
被嵌套类的组件：位于一个容器当中，不能包含其它组件；
容器类：
engine: 核心容器，catalina引擎，负责通过connector接收用户请求
host: 类似于httpd中的虚拟主机；支持基于FQDN的虚拟主机
context: 最内层的容器类组件，一个context代表一个web应用程序；配置context的主要目的，指定对应的webapp的根目录；还能为webapp指定额外的属性，如部署方式等；
服务：service， 将连接器关联至engine；因此一个service内部可以有多个connector，但只能有一个engine；
顶级组件：server，表示一个运行于JVM中的tomcat实例；
嵌套类组件：
valve: 拦截请求并在将其转至对应的webapp之前进行某种处理操作；可以用于任何容器中；
access log valve: 响应前先记录日志
remote address filter value: 基于IP做访问控制
logger: 日志记录器，用于记录组件 内部的状态信息；
可用于除context之外的任何容器中
realm: 可以用于任何容器类的组件中，关联一个用户认证库，实现认证和授权；
UserDatabaseRealm: 使用JNDI自定义的用户认证库；
MemoryRealm: tomcat-users.xml中
JDBCRealm: 基于JDBC连接至数据库中查找用户；

## web.xml文件
web.xml基于Java Servlet规范，可被用于每一个Java servlet容器，通常有两个存放位置，`$CATALINA_BASE/conf`和每个Web应用程序（通常是WEB-INF/web.xml）。Tomcat在deploy一个应用程序时(包括重启或重新载入)，它首先读取conf/web.xml，而后读取WEB-INF/web.xml。

# 常见问题
1）启动tomcat后，控制台报错：WEB-INF/lib/servlet-api.jar not loaded. See Servlet Spec 2.3, section 9.7.2. Offending class: javax/servlet/Servlet.class
问题原因：tomcat的common/lib下已经包含了servlet-api.jar，因此没有重复加载。

2）与nginx集成端口重定向问题

# 参考
- [Tomcat安装及配置详解](https://www.ttlsa.com/tomcat/tomcat-install-and-configure/)
- [nginx和Tomcat集成后发生的重定向问题分析和解决](http://www.ituring.com.cn/article/48042)
