[TOC]

# Java程序中MySql主从集群读写分离方案选择

(2016-06, created by [Zhu Yin](mailto:zhuyin@chinamobile.com))

---

# 候选方案
## 1 使用第三方中间件
### mysql proxy
mysql-proxy是官方提供的mysql中间件产品，可以实现负载平衡、读写分离、故障切换等。mysql-proxy通过其自带的lua脚本进行sql判断。

虽然是mysql官方产品，但是mysql官方尚不建议将mysql-proxy用到生产环境。

### 分布式数据层TDDL
淘宝根据自己的业务特点开发了[TDDL](https://github.com/alibaba/tb_tddl)（Taobao Distributed Data Layer）框架，主要解决分库分表对应用的透明化以及异构数据库之间的数据复制，它是一个基于集中式配置的 jdbc datasource实现，具有主备、读写分离、动态数据库配置等功能。

2012年，阿里将TDDL体系输出到阿里云，也有了个新的名字：分布式关系型数据库服务（Distribute Relational Database Service，简称DRDS).

TDDL最后更新时间是2012.4.27，现已不再维护。

### amoeba
由陈思儒开发，作者曾就职于阿里巴巴。此项目严重缺少维护和推广。

### cobar
阿里于2012年6月19日，正式对外开源数据库中间件[Cobar](https://github.com/alibaba/cobar)，其前身是早已经开源的Amoeba，不过其作者陈思儒离职去盛大之后，阿里巴巴内部考虑到Amoeba的稳定性、性能和功能支持，以及其他因素，重新设立了一个项目组并且更换名称为Cobar.

现在COBAR已经停止更新了，没人维护，原来的项目人员或走了，或转做Mycat。

### Mycat
[Mycat](http://www.mycat.org.cn)基于阿里开源的Cobar产品而研发,是国内最活跃的、性能最好的开源数据库中间件。

关键特性

- 支持SQL92标准
- 遵守Mysql原生协议，跨语言，跨平台，跨数据库的通用中间件代理。
- 基于心跳的自动故障切换，支持读写分离，支持MySQL主从，以及galera cluster集群。
- 基于Nio实现，有效管理线程，高并发问题。
- 支持数据的多片自动路由与聚合，支持sum,count,max等常用的聚合函数,支持跨库分页。
- 支持单库内部任意join，支持跨库2表join，甚至基于caltlet的多表join。
- 支持通过全局表，ER关系的分片策略，实现了高效的多表join查询。
- 支持多租户方案。
- 支持分布式事务（弱xa）。
- 支持全局序列号，解决分布式下的主键生成问题。

目前Mycat版本在快速迭代中。

### Atlas
[Atlas](https://github.com/Qihoo360/Atlas/blob/master/README_ZH.md)是由 Qihoo 360公司Web平台部基础架构团队开发维护的一个基于MySQL协议的数据中间层项目。它在MySQL官方推出的MySQL-Proxy 0.8.2版本的基础上，修改了大量bug，添加了很多功能特性。目前该项目在360公司内部得到了广泛应用，很多MySQL业务已经接入了Atlas平台，每天承载的读写请求数达几十亿条。

主要功能：

- 读写分离
- 从库负载均衡
- IP过滤
- 自动分表
- DBA可平滑上下线DB
- 自动摘除宕机的DB

实现读写分离需做的配置：

- 为了解决读写分离存在写完马上就想读而这时可能存在主从同步延迟的情况，Altas中可以在SQL语句前增加 /\*master*/，可以将读请求强制发往主库。
- 主库可设置多项，用逗号分隔，从库可设置多项和权重，达到负载均衡。

```shell
proxy-backend-address = 127.0.0.1:3306
proxy-read-only-backend-addresses = 127.0.0.1:3307@1,127.0.0.1:3308@2
```

Atlas相对于官方MySQL-Proxy的优势

- 将主流程中所有Lua代码用C重写，Lua仅用于管理接口
- 重写网络模型、线程模型
- 实现了真正意义上的连接池
- 优化了锁机制，性能提高数十倍

Atlas的github项目最后更新时间是2015.9.29，社区也不怎么活跃。

## 2 程序内部实现
修改程序代码内部实现读写分离：在代码中控制读操作分发到从库；其它操作由主库执行。这种方法的优点是：可控，对其他组件依赖较少.

### 方案一 业务代码中手动指定数据源

该方案可能是最先被想到的。该方案在小项目中易于实施。但是，该方案把数据源的选择耦合到业务逻辑中，当项目变得庞大时，不易维护。

### 方案二 使用两组数据源
通过继承`org.springframework.jdbc.datasource.lookup.AbstractRoutingDataSource`自定义动态数据源，并且通过aop或程序控制，为只读操作选择从库数据源，为其他操作选择主库数据源。

生产系统中，mysql主从集群有一个主库，多个从库。若使用MySQL的jdbc驱动Connector/J，主库只有一个，需使用`com.mysql.jdbc.Driver`；从库有多个，这涉及到了负载均衡，需使用`com.mysql.jdbc.ReplicationDriver`的loadbalance连接。然而，Connector/J的现有各版本的实现中，均不能同时使用`com.mysql.jdbc.ReplicationDriver`和`com.mysql.jdbc.Driver`。因此，该方法不具有可行性。

### 方案三 使用ReplicationDriver直连主从集群
MySQL的官方jdbc驱动[Connector/J](https://dev.mysql.com/doc/connector-j/5.1/en/connector-j-master-slave-replication-connection.html)提供了ReplicationDriver，可连接主从数据库并做读写操作分发，其`jdbc url`格式如下：

```
jdbc:mysql:replication://[master host][:port],[slave host 1][:port][,[slave host 2][:port]]...[/[database]][?propertyName1=propertyValue1[&propertyName2=propertyValue2]...]
```

ReplicationDriver保证写操作只发送到主库，而从库只会收到读操作。当配置了多个同类型的数据库时，如配置了多个从库，ReplicationDriver基于负载均衡算法选择数据库建立连接。ReplicationDriver内置了两种负载均衡算法，一种是随机式的轮询算法，另一种是最短响应时间算法。

**ReplicationDriver通过Connection对象的readOnly属性来判断该操作是否为更新操作**。

对于采用spring框架的程序，设定connection为readOnly的方式有：

1) 通过annotation设置readOnly

```java
@Override
@Transactional(readOnly=true)
public Sample getSample(SampleKey sampleKey) throws SampleException {
  ...
}
```

2) 通过xml配置文件定义aop切面

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

3) 定义切面通知类，与方法2大同小异，在此不再详述。



当spring程序使用了 `[activity + ] service + dao的架构`时，使用如下策略：

```
ReplicationDriver + Spring + 通过aop设置connection为readonly
```

可在不修改业务逻辑的情况下，方便地增加数据库读写分离逻辑。

# 总结

在程序中增加MySQL读写分离的方案可分为两种：

1. 使用第三方数据库中间件；
2. 在程序中实现读写分离控制。

目前，尚没有非常成熟的开源数据库中间件可供使用。若使用了不成熟的数据库中间件，且对该组件的源码不是非常熟悉，那风险非常大。

关于在程序中实现读写分离，比较好上手的方案是直接修改业务代码中的数据源，但是对于大项目，该方案维护成本太高。切实可行的方案是，使用ReplicationDriver直连MySQL主从集群，并且在程序中增加Spring切面，统一控制各方法是访问主库还是从库，实现读写分离。
