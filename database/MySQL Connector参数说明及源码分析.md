[TOC]

# MySQL Connectors 5.1

(2016-06, created by [Zhu Yin](mailto:zhuyin@chinamobile.com))

---

MySQL提供了ADO.NET Driver for MySQL (Connector/NET)	，ODBC Driver for MySQL (Connector/ODBC)，JDBC Driver for MySQL (Connector/J)等多种类型的数据库驱动。

> [MySQL provides standards-based drivers](http://www.mysql.com/products/connector/) for JDBC, ODBC, and .Net enabling developers to build database applications in their language of choice. In addition, a native C library allows developers to embed MySQL directly into their applications.

本文重点讲的是MySQL的java驱动[MySQL Connector/J](MySQL Connector/J)。MySQ Connector/J目前有两个系列5.1和6.0。

- [MySQL Connector/J 6.0](http://dev.mysql.com/doc/connector-j/6.0/en/)的driver统一为`com.mysql.cj.jdbc.Driver`，目前只支持jdk1.8，此处不再介绍。
- [MySQL Connector/J 5.1](http://dev.mysql.com/doc/connector-j/5.1/en/)是目前应用最广泛的MySQL驱动。

MySQL Connector/J 5.1提供了两种driver：

- 访问单例数据库的`com.mysql.jdbc.Driver`；
- 访问集群数据库的`com.mysql.jdbc.ReplicationDriver`。

访问MySQL主从集群时需要使用ReplicationDriver，且其`jdbc url`格式需如下：

```
jdbc:mysql:replication://[master host][:port],[slave host 1][:port][,[slave host 2][:port]]...[/[database]][?propertyName1=propertyValue1[&propertyName2=propertyValue2]...]
```

ReplicationDriver保证写操作只发送到主库，而从库只会收到读操作。当配置了多个同类型的数据库时，如配置了多个从库，ReplicationDriver基于负载均衡算法选择数据库建立连接。ReplicationDriver内置了两种负载均衡算法，一种是随机式的轮询算法，另一种是最短响应时间算法。

在选用slave host时，如果其连接失败，将把其加入到黑名单中，并把其从白名单中移除。

# 配置参数

在MySQL Connector/J 5.1的源码中可看到属性参数的说明文件：`com/mysql/jdbc/LocalizedErrorMessages.properties`

## 基本参数

- **autoReconnect** 当数据库连接异常中断时，是否自动重新连接，默认false。<font color='red'>不建议设置为`true`</font>

  > If enabled the driver will throw an exception for a queries issued on a stale or dead connection, which belong to the current transaction, but will attempt reconnect before the next query issued on the connection in a new transaction. The use of this feature is not recommended, because it has side effects related to session state and data consistency when applications don't handle SQLExceptions properly, and is only designed to be used when you are unable to configure your application to handle SQLExceptions resulting from dead and stale connections properly. Alternatively, as a last option, investigate setting the MySQL server variable "wait_timeout" to a high value, rather than the default of 8 hours.

- **autoReconnectForPools** 是否使用针对数据库连接池的重连策略。默认false。

- useUnicode，characterEncoding 两者配合使用，如`useUnicode=true&characterEncoding=utf-8`。

- **allowMultiQueries** 是否允许一条语句包含多个查询。默认false。

  > Allow the use of ';' to delimit multiple queries during one statement (true/false), defaults to 'false', and does not affect the addBatch() and executeBatch() methods, which instead rely on rewriteBatchStatements.

- **connectTimeout** 与数据库建立socket连接时的超时，单位：毫秒。 0表示永不超时。默认0.

- **socketTimeout** socket操作（读写）超时，单位：毫秒。 0表示永不超时。默认0.

## 主从复制的参数

-   **failOverReadOnly** 配置访问主库失败时从库的访问模式。默认是true。另外，访问模式可由`Connection.setReadOnly(boolean)`修改：
    - 当`failOverReadOnly`为`true`时，若当前连接为主库，用`Connection.setReadOnly(boolean)`修改访问模式可立即生效，若当前连接为从库，若修改访问模式为`read/write`时不是立即生效，而是待重连主库时再匹配`Connection.setReadOnly(boolean)`所设置的访问模式；
    - 当`failOverReadOnly`为`false`时，用`Connection.setReadOnly(boolean)`修改访问模式可以立即生效。
    > The connection access mode can be changed any time at runtime by calling the method Connection.setReadOnly(boolean), which partially overrides the property failOverReadOnly. When failOverReadOnly=false and the access mode is explicitly set to either true or false, it becomes the mode for every connection after a host switch, no matter what host type are we connected to; but, if failOverReadOnly=true, changing the access mode to read/write is only possible if the driver is connecting to the primary host; however, even if the access mode cannot be changed for the current connection, the driver remembers the client's last intention and, when falling back to the primary host, that is the mode that will be used.

-   **profileSQL** 监测sql语句执行时间，默认`false`。

-   **allowMasterDownConnections** 当master节点挂掉时，是否依然可只读访问slave节点。

-   **allowSlaveDownConnections** 当slave节点挂掉时，是否依然可访问master节点。

-   **retriesAllDown** 当可用的数据库节点（当只读连接时，是 slave hosts，否则为 master hosts）均连接失败时，尝试连接的最大次数。默认是120。情境举例：**若只有一个slave节点，那么当slave节点访问失败时，每次的只读请求将依然去连接slave节点，并尝试`retriesAllDown`次**。

-   **readFromMasterWhenNoSlaves** 当所有从节点均不能访问时，是否切换到主节点。

-   **loadBalanceConnectionGroup** Logical group of load-balanced connections within a classloader, used to manage different groups independently.  If not specified, live management of load-balanced connections is disabled.

-   **loadBalanceEnableJMX**  是否启用jmx监控，可用于在线添加或移除节点。
- **replicationEnableJMX** Enables JMX-based management of replication connection groups, including live slave promotion, addition of new slaves and removal of master or slave hosts from load-balanced master and slave connection pools.
- **loadBalanceStrategy** **平衡策略，有`random`和`bestResponseTime`。默认是`random`**。当然，可以使用自定义的平衡策略。
- **loadBalanceBlacklistTimeout** 节点黑名单的超时时间，单位为毫秒；<font color='red'>当配置为正整数时，才启用黑名单机制，即当slave连接失败时，将其加入到黑名单；默认值为0，即不启用黑名单</font>。


- **loadBalancePingTimeout** Time in milliseconds to wait for ping response from each of load-balanced physical connections when using load-balanced Connection.
- **loadBalanceAutoCommitStatementThreshold**
- **loadBalanceAutoCommitStatementRegex**
- **loadBalanceHostRemovalGracePeriod**
- **loadBalanceExceptionChecker** 默认是com.mysql.jdbc.StandardLoadBalanceExceptionChecker
# Connector/J 源码分析

本次源码分析的MySQL Connector/J为5.1.39版本。

## 识别master host
支持配置多个master，master节点通过字段`type`标识。

```java
class com.mysql.jdbc.NonRegisteringDriver{
    ...
    private boolean isHostMaster(String host) {
        if (NonRegisteringDriver.isHostPropertiesList(host)) {
            Properties hostSpecificProps = NonRegisteringDriver.expandHostKeyValues(host);
            if (hostSpecificProps.containsKey("type") && "master".equalsIgnoreCase(hostSpecificProps.get("type").toString())) {
                return true;
            }
        }
        return false;
    }
}
```

## 平衡策略
`LoadBalancedConnectionProxy#LoadBalancedConnectionProxy`根据参数`loadBalanceStrategy`的配置选择平衡策略。

```java
/**
 Creates a proxy for java.sql.Connection that routes requests between the given list of host:port and uses the given properties when creating connections.

 @param hosts
            The list of the hosts to load balance.
 @param props
            Connection properties from where to get initial settings and to be used in new connections.
 @throws SQLException
 */
private LoadBalancedConnectionProxy(List<String> hosts, Properties props) throws SQLException {
    ...
        String strategy = this.localProps.getProperty("loadBalanceStrategy", "random");
    if ("random".equals(strategy)) {
        this.balancer = (BalanceStrategy) Util.loadExtensions(null, props, "com.mysql.jdbc.RandomBalanceStrategy", "InvalidLoadBalanceStrategy", null)
                .get(0);
    } else if ("bestResponseTime".equals(strategy)) {
        this.balancer = (BalanceStrategy) Util
                .loadExtensions(null, props, "com.mysql.jdbc.BestResponseTimeBalanceStrategy", "InvalidLoadBalanceStrategy", null).get(0);
    } else { // 直接使用`loadBalanceStrategy`所指定的平衡策略类
        this.balancer = (BalanceStrategy) Util.loadExtensions(null, props, strategy, "InvalidLoadBalanceStrategy", null).get(0);
    }
    ...
}
```

`bestResponseTime`策略实现中，是依次连接所有可用的节点，之后，再从中选择响应时间最短的。这意味着每次建立连接都要与所有可用的节点通信，当为短连接时，响应时间损耗较为严重。

```java
// class BestResponseTimeBalanceStrategy
public ConnectionImpl pickConnection(LoadBalancedConnectionProxy proxy, List<String> configuredHosts, Map<String, ConnectionImpl> liveConnections,
            long[] responseTimes, int numRetries) throws SQLException {
    for (int i = 0; i < responseTimes.length; i++) {
        long candidateResponseTime = responseTimes[i];

        if (candidateResponseTime < minResponseTime && !blackList.containsKey(configuredHosts.get(i))) {
            if (candidateResponseTime == 0) {
                bestHostIndex = i;

                break;
            }

            bestHostIndex = i;
            minResponseTime = candidateResponseTime;
        }
    }

    String bestHost = configuredHosts.get(bestHostIndex);
    ...
}
```


## 设置连接是否为只读
`java.sql.Connection.setReadOnly(boolean readOnly)`调用`ReplicationConnectionProxy#setReadOnly`方法，该方法**根据是否只读做节点切换，并在切换时，根据平衡策略选择相应的数据库节点去尝试获取连接**。

```java
public synchronized void setReadOnly(boolean readOnly) throws SQLException {
    if (readOnly) {
        if (!isSlavesConnection() || this.currentConnection.isClosed()) {
            boolean switched = true;
            SQLException exceptionCaught = null;
            try {
                switched = switchToSlavesConnection();
            } catch (SQLException e) {
                switched = false;
                exceptionCaught = e;
            }
            if (!switched && this.readFromMasterWhenNoSlaves && switchToMasterConnection()) {
                exceptionCaught = null; // The connection is OK. Cancel the exception, if any.
            }
            if (exceptionCaught != null) {
                throw exceptionCaught;
            }
        }
    } else {
        if (!isMasterConnection() || this.currentConnection.isClosed()) {
            boolean switched = true;
            SQLException exceptionCaught = null;
            try {
                switched = switchToMasterConnection();
            } catch (SQLException e) {
                switched = false;
                exceptionCaught = e;
            }
            if (!switched && switchToSlavesConnectionIfNecessary()) {
                exceptionCaught = null; // The connection is OK. Cancel the exception, if any.
            }
            if (exceptionCaught != null) {
                throw exceptionCaught;
            }
        }
    }
    this.readOnly = readOnly;

    /*
     + Reset masters connection read-only state if 'readFromMasterWhenNoSlaves=true'. If there are no slaves then the masters connection will be used with
     + read-only state in its place. Even if not, it must be reset from a possible previous read-only state.
     */
    if (this.readFromMasterWhenNoSlaves && isMasterConnection()) {
        this.currentConnection.setReadOnly(this.readOnly);
    }
}
```

## 数据库节点黑名单
`LoadBalancedConnectionProxy#getGlobalBlacklist`中，在获取节点黑名单时，如果所有的节点（该方法中的所有节点是同一类型的节点，如同为master节点，或同为slave节点）均不可用，则返回的黑名单为空。

此处将导致一个性能问题，例如若只有一个slave节点，那么当slave节点访问失败时，每次的只读请求将依然去尝试连接slave；若一个http请求中有多次readonly请求时，则http 响应将非常的慢。

解决办法：
- 使用多个slave节点
- 使用自定义的平衡策略

```java
public synchronized Map<String, Long> getGlobalBlacklist() {
    ...
    if (keys.size() == this.hostList.size()) {
        // return an empty blacklist, let the BalanceStrategy implementations try to connect to everything since it appears that all hosts are
        // unavailable - we don't want to wait for loadBalanceBlacklistTimeout to expire.
        return new HashMap<String, Long>(1);
    }

    return blacklistClone;
}
```

## 同一程序中不建议使用两种driver

由于jdk1.7 `java.sql.DriverManager#getDriver`会优先选择第一个能适用于`jdbc.url`的driver，然而该版本的mysql driver只是在`com.mysql.jdbc.NonRegisteringDriver`中判定`jdbc.url`是否匹配，没有区分`com.mysql.jdbc.ReplicationDriver`、`com.mysql.jdbc.Driver`。

如果`com.mysql.jdbc.Driver`在`com.mysql.jdbc.ReplicationDriver`之后被注册，那么它永远都不能被使用。此时，当使用`com.mysql.jdbc.Driver`的jdbc.url时，将报错`java.sql.SQLException: Must specify at least one slave host to connect to for master/slave replication load-balancing functionality`，这是因为该jdbc.url确实是没有配置从库。因此，不建议同时使用`com.mysql.jdbc.ReplicationDriver`和`com.mysql.jdbc.Driver`。

```java
// java.sql.DriverManager
public static Driver getDriver(String url)
    throws SQLException {

    println("DriverManager.getDriver(\"" + url + "\")");

    Class<?> callerClass = Reflection.getCallerClass();

    // Walk through the loaded registeredDrivers attempting to locate someone
    // who understands the given URL.
    for (DriverInfo aDriver : registeredDrivers) {
        // If the caller does not have permission to load the driver then
        // skip it.
        if(isDriverAllowed(aDriver.driver, callerClass)) {
            try {
                if(aDriver.driver.acceptsURL(url)) {
                    // Success!
                    println("getDriver returning " + aDriver.driver.getClass().getName());
                return (aDriver.driver);
                }

            } catch(SQLException sqe) {
                // Drop through and try the next driver.
            }
        } else {
            println("    skipping: " + aDriver.driver.getClass().getName());
        }

    }

    println("getDriver: no suitable driver");
    throw new SQLException("No suitable driver", "08001");
}
```

# 参考
- [Configuring Server Failover](http://dev.mysql.com/doc/connector-j/5.1/en/connector-j-config-failover.html)
- [Connector/J Versions, and the MySQL and Java Versions They Support](http://dev.mysql.com/doc/connector-j/6.0/en/connector-j-versions.html)
- [Mysql Replication基本原理（一)](http://shift-alt-ctrl.iteye.com/blog/2266908)
