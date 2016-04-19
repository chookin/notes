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
        <value>classpath:conndb.properties</value>
    </property>
</bean>

<bean id="dataSource" class="org.apache.commons.dbcp.BasicDataSource">
    <property name="driverClassName" value="${jdbc.driverClassName}"></property>
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

## 获取ApplicationContext的几种方式

- 采用类路径的加载方式获取：
```java
// 此处的文件必须位于classpath路径中
ApplicationContext ctx=new ClassPathXmlApplicationContext("applicationContext.xml");
```
  
- 采用系统文件路径加载的方式获取：
```java
// 此处的文件必须位于系统中一个具体的位置
ApplicationContext ctx=new FileSystemXmlApplicationContext("/tmp/applicationContext.xml");
```

- 在web环境中，获取ApplicationContext
```java
ServletContext servletContext = request.getSession().getServletContext();               
ApplicationContext context = WebApplicationContextUtils.getWebApplicationContext(servletContext); 
```

# 事务

spring 事务管理分为编程式事务管理和声明式事务管理，所为编程式事务管理就是在代码层面控制事务的开始、提交和回滚。声明式事务管理就是通过aop动态代理统一在方法前后做事务操作，而不是写死到代码层面。

## Spring 提供的几种事务控制
1.PROPAGATION_REQUIRED（加入已有事务）
    尝试加入已经存在的事务中，如果没有则开启一个新的事务。

2.RROPAGATION_REQUIRES_NEW（独立事务）
    挂起当前存在的事务，并开启一个全新的事务，新事务与已存在的事务之间彼此没有关系。

3.PROPAGATION_NESTED（嵌套事务）
    在当前事务上开启一个子事务（Savepoint），如果递交主事务。那么连同子事务一同递交。如果递交子事务则保存点之前的所有事务都会被递交。

4.PROPAGATION_SUPPORTS（跟随环境）
    是指 Spring 容器中如果当前没有事务存在，就以非事务方式执行；如果有，就使用当前事务。

5.PROPAGATION_NOT_SUPPORTED（非事务方式）
    是指如果存在事务则将这个事务挂起，并使用新的数据库连接。新的数据库连接不使用事务。

6.PROPAGATION_NEVER（排除事务）
    当存在事务时抛出异常，否则就已非事务方式运行。

7.PROPAGATION_MANDATORY（需要事务）
    如果不存在事务就抛出异常，否则就已事务方式运行。

# 切面
在软件中，日志、安全和事务管理等对于大多数应用是通用的，但是它们是否是业务逻辑必须关心的呢？如果让业务逻辑只关注自己的业务领域问题，而其他方面的问题由其他应用对象来处理，会不会更好呢？

在软件开发中，分布于应用中多处的功能被称为横切关注点（cross-cutting concerns)。通常，这些横切关注点从概念上是与应用的业务逻辑相分离的，将这些横切关注点与业务逻辑相分离正是面向切面编程（AOP）所要解决的。

## 常用术语

描述切面的常用术语有：

- 通知（advice) 通知定义了切面是什么以及何时使用。有5种类型的通知：
    1. before 在方法在被调用之前调用通知后
    2. after 在方法完成之后调用通知，无论方法执行是否成功
    3. after-running  在方法成功执行之后调用通知
    4. after-throwing 在方法抛出异常后调用通知
    5. around 通知包裹了被通知的方法，在被通知的方法调用之前和调用之后执行自定义的行为
- 连接点（joinpoint) 连接点是在应用执行过程中能够插入切面的一个点。切面代码可以利用这些点插入新的行为到应用的正常流程中。
- 切点（pointcut) 切点定了切面是何处使用。切点的定义会匹配通知所要织入的一个或多个连接点。我们通常使用明确的类或方法名称来指定这些切点，或是利用正则表达式定义匹配的类和方法名称模板来指定这些切点。
- 切面 (aspect) 切面是通知和切点的结合。
- 引入 (intruduction) 引入允许我们向现有的类添加新方法或属性。
- 织入 (Weaving) 织入是将切面应用到目标对象来创建新的代理对象的过程。切面在指定的连接点呗织入到目标对象中。在目标对象的生命周期里有个多个点可以进行织入。
    * 编译期
    * 类加载期
    * 运行期 切面在应用运行的某个时刻被织入。一般情况下，在织入切面时，AOP 容器会为目标对象动态的创建一个代理对象.

## spring 对 aop 的支持

- spring 在运行期通知对象。通过在代理类中包裹切面，spring 在运行期将切面织入到spring管理的bean中。在调用目标bean时，代理会先执行切面逻辑，之后才创建代理对象。
- spring 只支持方法连接点
