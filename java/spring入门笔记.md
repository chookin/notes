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

