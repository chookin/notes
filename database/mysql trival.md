# replication driver

Even for the "readOnly" transactions ReplicationDriver first hits master，The issue with that is that the MySQL replication driver will attempt to reconnect to the master each time the connection is returned to the pool. This happens when read-only mode is cleared.

- First, DBCP is creating a single JDBC connection through the MySQL driver. This connection will point to the master until set to read-only at which point it will switch over to the slave.
- Second, Spring is getting a connection from the pool and writing to the debug log that it has acquired a connection. Because the connection has not yet been set to read-only mode, it will route queries to the master.
- Third, Spring is changing the connection over to read-only mode at which point queries will be routed to the slave.
- Next, your application (or iBatis or w/e) is given the connection to perform some work with the database.
After you return control to Spring, the transaction on the connection will be committed. Because the connection is in read-only mode, you can see the transaction debug message showing that queries will be routed to the slave server.
- Finally, the connection is reset before being returned to the pool. The read-only mode is cleared and the last log message once again reflects that the connection will route queries to the master server.

The simplest workaround I can see for this situation is to use a separate data source (and transaction manager) for the master and the slaves

参考：

- [Mysql master/slave replication .Connect to master even for read queries](http://stackoverflow.com/questions/22495722/mysql-master-slave-replication-connect-to-master-even-for-read-queries-does-d)

# `AbstractRoutingDataSource`
通过spring管理datasource的route,由aop或程序控制读写数据源。通过继承`org.springframework.jdbc.datasource.lookup.AbstractRoutingDataSource`，自定义动态数据源。

#### `AbstractRoutingDataSource`分析
`AbstractRoutingDataSource`继承于`AbstractDataSource`,而AbstractDataSource又是`DataSource`的子类。DataSource是`javax.sql`的数据源接口，定义如下：

```java
public interface DataSource  extends CommonDataSource,Wrapper {

  /**
   * <p>Attempts to establish a connection with the data source that
   * this <code>DataSource</code> object represents.
   *
   * @return  a connection to the data source
   * @exception SQLException if a database access error occurs
   */
  Connection getConnection() throws SQLException;

  /**
   * <p>Attempts to establish a connection with the data source that
   * this <code>DataSource</code> object represents.
   *
   * @param username the database user on whose behalf the connection is
   *  being made
   * @param password the user's password
   * @return  a connection to the data source
   * @exception SQLException if a database access error occurs
   * @since 1.4
   */
  Connection getConnection(String username, String password)
    throws SQLException;

}
```

DataSource 接口定义了2个方法，都是获取数据库连接。我们在看下AbstractRoutingDataSource 如何实现了DataSource接口：
```java
public Connection getConnection() throws SQLException {
    return determineTargetDataSource().getConnection();
}

public Connection getConnection(String username, String password) throws SQLException {
    return determineTargetDataSource().getConnection(username, password);
}
```

很显然就是调用自己的 `determineTargetDataSource()` 方法获取到Connection。`determineTargetDataSource` 方法定义如下：

```java
/**
 * Retrieve the current target DataSource. Determines the
 * {@link #determineCurrentLookupKey() current lookup key}, performs
 * a lookup in the {@link #setTargetDataSources targetDataSources} map,
 * falls back to the specified
 * {@link #setDefaultTargetDataSource default target DataSource} if necessary.
 * @see #determineCurrentLookupKey()
 */
protected DataSource determineTargetDataSource() {
    Assert.notNull(this.resolvedDataSources, "DataSource router not initialized");
    Object lookupKey = determineCurrentLookupKey();
    DataSource dataSource = this.resolvedDataSources.get(lookupKey);
    if (dataSource == null && (this.lenientFallback || lookupKey == null)) {
        dataSource = this.resolvedDefaultDataSource;
    }
    if (dataSource == null) {
        throw new IllegalStateException("Cannot determine target DataSource for lookup key [" + lookupKey + "]");
    }
    return dataSource;
}

```

determineCurrentLookupKey方法返回lookupKey,resolvedDataSources方法就是根据lookupKey从Map中获得数据源。resolvedDataSources 和determineCurrentLookupKey定义如下：

```java
private Map<Object, DataSource> resolvedDataSources;
protected abstract Object determineCurrentLookupKey()
```

#### 数据源定义

```xml
<bean id="parentDataSource" abstract="true" class="org.apache.commons.dbcp.BasicDataSource">
    <property name="driverClassName" value="${jdbc.driverClassName}" />
    <property name="maxActive" value="${maxActive}" />
    <property name="maxIdle" value="${maxIdle}" />
    <property name="maxWait" value="${maxWait}" />
    <property name="defaultAutoCommit" value="true" />
    <property name="validationQuery" value="select 1" />
</bean>
<!-- 主数据源-->
<bean id="masterDataSource" parent="parentDataSource">
    <property name="driverClassName" value="${master.jdbc.driverClassName}" />
    <property name="url" value="${slave.jdbc.url}" />
    <property name="username" value="${master.jdbc.username}" />
    <property name="password" value="${master.jdbc.password}" />
</bean>
<!-- 从数据源-->
<bean id="slaveDataSource" parent="parentDataSource">
    <property name="driverClassName" value="${slave.jdbc.driverClassName}" />
    <property name="url" value="${slave.jdbc.url}" />
    <property name="username" value="${slave.jdbc.username}" />
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

<bean id="dynamicDataSourceAdvice" class="com.chinamobile.dao.DynamicDataSourceAdvice"/>

<aop:config proxy-target-class="true">
    <aop:advisor
            advice-ref="dynamicDataSourceAdvice"
            pointcut="execution(public * com.chinamobile.websurvey.service.*Service.*(..))"/>
</aop:config>
```

注意:

- 在spring3以上版本中使用spring的依赖注入(注解或者xml方式)和aop功能时，发现了一个问题，如果不设置`proxy-target-class="true"`那么在获取bean时一直报错：`no matching editors or conversion strategy found`;
- 主库同步数据到从库是有时延的，同一service方法可能会依次调用两个不同数据源的dao方法，若选用dao方法为数据源切换的切点，将导致这些service获取到的数据紊乱。建议同一事务里还是不要切换数据源，还是在service方法上切换数据源。

参考：

- [spring 使用AbstractRoutingDataSource实现数据库读写分离及事务介绍](http://zhanghua.1199.blog.163.com/blog/static/4644980720150341159923/)
- [Spring+Hibernate框架下Mysql读写分离、主从数据库配置](http://lujia35.iteye.com/blog/969466)
- [Spring 实现数据库读写分离](http://www.cnblogs.com/surge/p/3582248.html)
- [MyBatis多数据源配置(读写分离)](http://blog.csdn.net/isea533/article/details/46815385)
- [spring+mybatis利用interceptor(plugin)兑现数据库读写分离](http://blog.csdn.net/keda8997110/article/details/16827215)
- [在应用层通过spring解决数据库读写分离](http://www.iteye.com/topic/1127642)
- [mysql中间件研究（Atlas，cobar，TDDL）](http://www.guokr.com/blog/475765/)
- [使用mysql-proxy 快速实现mysql 集群 读写分离](http://www.open-open.com/lib/view/open1345864902321.html)
- [Chapter 1 Introduction to MySQL Proxy](http://dev.mysql.com/doc/mysql-proxy/en/mysql-proxy-introduction.html)

