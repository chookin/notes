# 方案
## 程序内部实现
通过spring管理datasource的route,由aop或程序控制读写数据源.
基于程序代码内部实现：在代码中对select操作分发到从库；其它操作由主库执行；这类方法也是目前生产环境应用最广泛。优点是性能较好，因为在程序代码中实现，不需要增加额外的设备作为硬件开支。
## mysql proxy
mysql-proxy是官方提供的mysql中间件产品可以实现负载平衡，读写分离，failover等，但其不支持大数据量的分库分表且性能较差。

mysql-proxy通过其自带的lua脚本进行sql判断，虽然是mysql官方产品，但是mysql官方并不建议将mysql-proxy用到生产环境。  

MySQL Proxy is currently an Alpha release and should not be used within production environments.

- [mysql中间件研究（Atlas，cobar，TDDL）](http://www.guokr.com/blog/475765/)
- [使用mysql-proxy 快速实现mysql 集群 读写分离](http://www.open-open.com/lib/view/open1345864902321.html)
- [Chapter 1 Introduction to MySQL Proxy](http://dev.mysql.com/doc/mysql-proxy/en/mysql-proxy-introduction.html)

## mysql驱动

ReplicationDriver提供主从库访问的驱动,看了下原代码是保持了多个数据源的链接并根据readOnly true/false来选择数据源.相当于应用层解决方案的一个现有实现,耦合程度更低,扩展性更弱.并且貌似不能使用其他驱动.

## 分布式数据层TDDL
淘宝根据自己的业务特点开发了TDDL（Taobao Distributed Data Layer 外号:头都大了 ©_Ob）框架，主要解决了分库分表对应用的透明化以及异构数据库之间的数据复制，它是一个基于集中式配置的 jdbc datasource实现，具有主备，读写分离，动态数据库配置等功能。
https://github.com/alibaba/tb_tddl 最后更新时间 2012.4.27

## DRDS
TDDL所提供的读写分离、分库分表等核心功能，也成为了阿里集团内数据库领域的标配组件，在阿里的几乎所有应用 上都有应用。最为难得的是，这些功能从上线后，到现在已经经历了多年双11的严酷考验，从未出现过严重故障（p0、p1级别故障属于严重故障）。数据库体 系作为整个应用系统的重中之重，能做到这件事，真是非常不容易。

随着核心功能的稳定，自2010年开始，我们集中全部精力开始关注TDDL后端运维系统的完善与改进性工作。在DBA团队的给力配合下，围绕着 TDDL，我们成功做到了在线数据动态扩缩、异步索引等关键特征，同时也比较成功地构建了一整套分布式数据库服务管控体系，用户基本上可以完全自助地完成 整套数据库环境的搭建与初始化工作。

大概是2012年，我们在阿里云团队的支持下，开始尝试将TDDL这套体系输出到阿里云上，也有了个新的名字：阿里分布式数据库服务（DRDS）.

分布式关系型数据库服务（Distribute Relational Database Service，简称DRDS）是一种水平拆分、读写分离、可平滑扩缩容的在线分布式数据库服务。DRDS能够将成百上千个MySQL节点组成一个分布式数据库，使用如同单机MySQL数据库，完全兼容MySQL交互协议让这个产品能能够被几乎所有的客户端编程语言使用，兼容MySQL SQL让应用使用变得容易，降低使用门槛。

具备1K个MySQL组合能力

DRDS生产级别规模已经达到1K 个MySQL实例，支撑这种规模的关键在于数据的水平拆分和Share Nothing结构，可以说这是一个OLTP领域的终极解决方案，但是其核心思想并不复杂：分而治之。将数据分散到多台机器，并保证请求能够平均的分发到这些机器上，以较低的成本来解决业务的各类性能瓶颈。

## amoeba
由陈思儒开发，作者曾就职于阿里巴巴.此项目严重缺少维护和推广（作者有个官方博客，很多用户反馈的问题发现作者不理睬）.

## cobar
阿里巴巴于2012年6月19日，正式对外开源的数据库中间件Cobar，前身是早已经开源的Amoeba，不过其作者陈思儒离职去盛大之后，阿里巴巴内部考虑到Amoeba的稳定性、性能和功能支持，以及其他因素，重新设立了一个项目组并且更换名称为Cobar.
https://github.com/alibaba/cobar 最后更新时间 2016.3.8

- [Cobar正式开源](http://it.100xuexi.com/view/otdetail/20120921/8d198588-97cc-4c22-ac5e-d775126a295e.html)

## Mycat
http://www.mycat.org.cn
https://github.com/MyCATApache/Mycat-Server
Mycat 是基二开源 cobar 演发耄来,我们对 cobar 癿今码迕行了彻底癿重极,使用 NIO 重极了网络模坑,幵丏 优化了 Buffer 内核,增强了聚吅,Join 等基本特忓,同时兼容绝多夗数数捤库成为途用癿数捤库中闱件。
支持 SQL 92标准 支持Mysql集群，可以作为Proxy使用 支持JDBC连接ORACLE、DB2、SQL Server，将其模拟为MySQL Server使用 支持galera for mysql集群，percona-cluster或者mariadb cluster，提供高可用性数据分片集群，自动故障切换，高可用性 ，支持读写分离，支持Mysql双主多从，以及一主多从的模式 ，支持全局表，数据自动分片到多个节点，用于高效表关联查询 ，支持独有的基于E-R 关系的分片策略，实现了高效的表关联查询多平台支持，部署和实施简单。

抛开TDDL不说，Amoeba、Cobar、MyCAT这三者的渊源比较深，若Amoeba能继续下去，Cobar就不会出来；若Cobar那批人不是都走光了的话，MyCAT也不会再另起炉灶。所以说，在中国开源的项目很多，但是能坚持下去的非常难，MyCAT社区现在非常活跃，也真是一件蛮难得的事。

- [TDDL、Amoeba、Cobar、MyCAT架构比较](http://blog.csdn.net/lichangzhen2008/article/details/44708227)
- [mycat分布式mysql中间件（mysql中间件研究)](http://songwie.com/articlelist/44)

## Atlas
### 简介

[Atlas](https://github.com/Qihoo360/Atlas/blob/master/README_ZH.md)是由 Qihoo 360公司Web平台部基础架构团队开发维护的一个基于MySQL协议的数据中间层项目。它在MySQL官方推出的MySQL-Proxy 0.8.2版本的基础上，修改了大量bug，添加了很多功能特性。目前该项目在360公司内部得到了广泛应用，很多MySQL业务已经接入了Atlas平台，每天承载的读写请求数达几十亿条。同时，有超过50家公司在生产环境中部署了Atlas.
最后更新时间 2015.9.29

QQ群326544838, QQ群不怎么活跃

主要功能：
1.读写分离
2.从库负载均衡
3.IP过滤
4.自动分表
5.DBA可平滑上下线DB
6.自动摘除宕机的DB

自己实现读写分离
（1）为了解决读写分离存在写完马上就想读而这时可能存在主从同步延迟的情况，Altas中可以在SQL语句前增加 /*master*/ 就可以将读请求强制发往主库。
（2）主库可设置多项，用逗号分隔，从库可设置多项和权重，达到负载均衡。
```
proxy-backend-address = 127.0.0.1:3306
proxy-read-only-backend-addresses = 127.0.0.1:3307@1,127.0.0.1:3308@2
```

### Atlas相对于官方MySQL-Proxy的优势

1.将主流程中所有Lua代码用C重写，Lua仅用于管理接口
2.重写网络模型、线程模型
3.实现了真正意义上的连接池
4.优化了锁机制，性能提高数十倍


# 配置主从库
## 方案一 ReplicationDriver
[spring MVC、mybatis配置读写分离](http://www.cnblogs.com/fx2008/p/4099143.html)

当后端MYSQL服务器群是master-master双向同步机制时，前端应用使用JDBC连接数据库可以使用loadbalance方式，如下所示：
```
jdbc:mysql:loadbalance://dbnode_1:port，dbnode_2:port，dbnode_3:port，dbnode_n:port/dbname？user=xxxx；password=xxxxxxx；loadBalanceBlacklistTimeout=3000；&amp；characterEncoding=utf-8
```
loadbalance方式有两种负载均衡算法，一种是随机式的轮询算法，另一种是最短响应时间算法。

当后端MYSQL服务器群是master-slave机制时，不能在使用loadbalance方式，这种情况下需要实现“主读写、从只读”的模式，为此可以使用replication方式，如下所示：
```
jdbc:mysql:replication://master:port,slave1:port,slave2:port,slaven:port/dbname?user=xxxx;password=xxxxxxxx;&amp;characterEncoding=utf-8;&amp;allowMasterDownConnections=true
```
replication方式可以很安全的实现写操作只发送到主机执行，而从机只会接收到读操作。ReplicationDriver 是通过Connection对象的readOnly属性来判断该操作是否为更新操作。

通过annotation标注readOnly
```java
@Override
@Transactional(rollbackFor=Exception.class,readOnly=true)
public Sample getSample(SampleKey sampleKey) throws SampleException {
   //Call MyBastis based DAO  with "select" queries.
}
```
通过xml配置
```xml
<!-- 定义事务通知 -->    
<tx:advice id="txAdvice" transaction-manager="transactionManager">    
    <!-- 定义方法的过滤规则 -->    
    <tx:attributes>    
        <!-- 所有方法都使用事务 -->    
        <tx:method name="*" propagation="REQUIRED"/>    
        <!-- 定义所有get开头的方法都是只读的 -->    
        <tx:method name="get*" read-only="true"/>    
    </tx:attributes>    
</tx:advice>    
    
<!-- 定义AOP配置 -->    
<aop:config>    
    <!-- 定义一个切入点 -->    
    <aop:pointcut expression="execution (* com.most.service.*.*(..))" id="services"/>    
    <!-- 对切入点和事务的通知，进行适配 -->    
    <aop:advisor advice-ref="txAdvice" pointcut-ref="services"/>    
</aop:config>    
```

Even for the "readOnly" transactions ReplicationDriver first hits master，The issue with that is that the MySQL replication driver will attempt to reconnect to the master each time the connection is returned to the pool. This happens when read-only mode is cleared.

- First, DBCP is creating a single JDBC connection through the MySQL driver. This connection will point to the master until set to read-only at which point it will switch over to the slave.
- Second, Spring is getting a connection from the pool and writing to the debug log that it has acquired a connection. Because the connection has not yet been set to read-only mode, it will route queries to the master.
- Third, Spring is changing the connection over to read-only mode at which point queries will be routed to the slave.
- Next, your application (or iBatis or w/e) is given the connection to perform some work with the database.
After you return control to Spring, the transaction on the connection will be committed. Because the connection is in read-only mode, you can see the transaction debug message showing that queries will be routed to the slave server.
- Finally, the connection is reset before being returned to the pool. The read-only mode is cleared and the last log message once again reflects that the connection will route queries to the master server.

[Mysql master/slave replication .Connect to master even for read queries](http://stackoverflow.com/questions/22495722/mysql-master-slave-replication-connect-to-master-even-for-read-queries-does-d)
    
The simplest workaround I can see for this situation is to use a separate data source (and transaction manager) for the master and the slaves

## 继承AbstractRoutingDataSource

通过继承`org.springframework.jdbc.datasource.lookup.AbstractRoutingDataSource`，自定义动态数据源。
```xml
<bean id="parentDataSource" abstract="true" class="com.mchange.v2.c3p0.ComboPooledDataSource">  
    //***c3p0配置 
</bean>  
 <!-- 主数据源-->  
<bean id="masterDataSource" parent="parentDataSource">  
    <property name="driverClass" value="${master.jdbc.driverClassName}" />  
    <property name="jdbcUrl" value="${master.jdbc.url}" />  
    <property name="user" value="${master.jdbc.username}" />  
    <property name="password" value="${master.jdbc.password}" />  
</bean>  
<!-- 从数据源-->  
<bean id="slaveDataSource" parent="parentDataSource">  
    <property name="driverClass" value="${slave.jdbc.driverClassName}" />  
    <property name="jdbcUrl" value="${slave.jdbc.url}" />  
    <property name="user" value="${slave.jdbc.username}" />  
    <property name="password" value="${slave.jdbc.password}" />  
</bean>  
  
<bean id="dataSource" class="com.company.datasource.DynamicDataSource">  
    <property name="targetDataSources">  
        <map key-type="java.lang.String">  
            <entry key="slave" value-ref="slaveDataSource" />  
        </map>  
    </property>  
    <property name="defaultTargetDataSource" ref="masterDataSource" />  
</bean>  
```
