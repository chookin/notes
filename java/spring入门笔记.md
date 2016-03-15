[TOC]
# 概念
## 什么是DI机制
依赖注入（Dependecy Injection）和控制反转（Inversion of Control）是同一个概念，具体的讲：当某个角色需要另外一个角色协助的时候，在传统的程序设计过程中，通常由调用者来创建被调用者的实例。但在spring中创建被调用者的工作不再由调用者来完成，因此称为控制反转。创建被调用者的工作由spring来完成，然后注入调用者，因此也称为依赖注入。
spring以动态灵活的方式来管理对象，注入的两种方式，设置注入和构造注入。
设置注入的优点：直观，自然
构造注入的优点：可以在构造器中决定依赖关系的顺序。
## 什么是AOP
面向切面编程（aop）是对面向对象编程（oop）的补充，
面向对象编程将程序分解成各个层次的对象，面向切面编程将程序运行过程分解成各个切面。
AOP从程序运行角度考虑程序的结构，提取业务处理过程的切面，oop是静态的抽象，aop是动态的抽象，
是对应用执行过程中的步骤进行抽象，，从而获得步骤之间的逻辑划分。

aop框架具有的两个特征：
1.各个步骤之间的良好隔离性
2.源代码无关性 

# 基本语法
## Spring中的FactoryBean
Spring中有两种类型的Bean，一种是普通Bean，一种是工厂Bean，即FactoryBean，这两种Bean都被容器管理，但工厂Bean跟普通Bean不同，其返回的对象不是指定类的一个实例，其返回的是该FactoryBean的getObject方法所返回的对象。在
## parent bean
spring bean定义可以和对象一样进行继承。

# applicationContext.xml
## 配置数据源
```xml
<bean id="conndb"
    class="org.springframework.beans.factory.config.PropertyPlaceholderConfigurer">
    <property name="location">
        <value>classpath:conndb.properties
        </value>
    </property>
</bean>

<bean id="dataSource" class="org.apache.commons.dbcp.BasicDataSource">
    <property name="driverClassName" value="com.mysql.jdbc.Driver"></property>
    <property name="url"
        value="${url}?useUnicode=true&amp;characterEncoding=utf-8"></property>
    <property name="username" value="${username}"></property>
    <property name="password" value="${password}"></property>
    <property name="maxActive" value="${maxActive}"></property>
    <property name="maxIdle" value="${maxIdle}"></property>
    <property name="maxWait" value="${maxWait}"></property>
    <property name="defaultAutoCommit" value="true"></property>
    <!-- 验证连接是否可用 -->
    <property name="validationQuery" value="select 1" />
</bean>
```

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

