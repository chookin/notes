
# MySQL Connector/J 5.1
replication连接会自动将slave hosts组队为loadbalance连接。在选用slave host,如果其连接失败，将把其加入到黑名单中，并把其从白名单中移除。

属性参数的说明文件：`com/mysql/jdbc/LocalizedErrorMessages.properties`

- **autoReconnect** 当数据库连接异常中断时，是否自动重新连接,<font color='red'>不建议设置为`true`</font>.If enabled the driver will throw an exception for a queries issued on a stale or dead connection, which belong to the current transaction, but will attempt reconnect before the next query issued on the connection in a new transaction. The use of this feature is not recommended, because it has side effects related to session state and data consistency when applications don't handle SQLExceptions properly, and is only designed to be used when you are unable to configure your application to handle SQLExceptions resulting from dead and stale connections properly. Alternatively, as a last option, investigate setting the MySQL server variable "wait_timeout" to a high value, rather than the default of 8 hours.
- **autoReconnectForPools** Use a reconnection strategy appropriate for connection pools (defaults to 'false')
- useUnicode
- characterEncoding 当useUnicode设置为true时，指定字符编码。
- **allowMultiQueries** Allow the use of ';' to delimit multiple queries during one statement (true/false), defaults to 'false', and does not affect the addBatch() and executeBatch() methods, which instead rely on rewriteBatchStatements.
- **connectTimeout** Timeout for socket connect (in milliseconds), with 0 being no timeout. Only works on JDK-1.4 or newer. Defaults to '0'.
- **socketTimeout** Timeout on network socket operations (0, the default means no timeout).

# Replication and load balance
## 配置参数

- **failOverReadOnly** 默认是true；该参数用于确定访问主库失败时从库的访问模式。另外，访问模式可由`Connection.setReadOnly(boolean)`修改：
    - 当`failOverReadOnly`为`true`时，若当前连接为主库，用`Connection.setReadOnly(boolean)`修改访问模式可立即生效，若当前连接为从库，若修改访问模式为`read/write`时不是立即生效，而是待重连主库时再匹配`Connection.setReadOnly(boolean)`所设置的访问模式；
    - 当`failOverReadOnly`为`false`时，用`Connection.setReadOnly(boolean)`修改访问模式可以立即生效。
    > The connection access mode can be changed any time at runtime by calling the method Connection.setReadOnly(boolean), which partially overrides the property failOverReadOnly. When failOverReadOnly=false and the access mode is explicitly set to either true or false, it becomes the mode for every connection after a host switch, no matter what host type are we connected to; but, if failOverReadOnly=true, changing the access mode to read/write is only possible if the driver is connecting to the primary host; however, even if the access mode cannot be changed for the current connection, the driver remembers the client's last intention and, when falling back to the primary host, that is the mode that will be used. 
- **profileSQL** Trace queries and their execution/fetch times to the configured logger (true/false) defaults to 'false'
- **allowMasterDownConnections** By default, a replication-aware connection will fail to connect when configured master hosts are all unavailable at initial connection. Setting this property to 'true' allows to establish the initial connection, by failing over to the slave servers, in read-only state. It won't prevent subsequent failures when switching back to the master hosts i.e. by setting the replication connection to read/write state.
- **allowSlaveDownConnections** By default, a replication-aware connection will fail to connect when configured slave hosts are all unavailable at initial connection. Setting this property to 'true' allows to establish the initial connection. It won't prevent failures when switching to slaves i.e. by setting the replication connection to read-only state. The property 'readFromMasterWhenNoSlaves' should be used for this purpose. 
- **retriesAllDown** 当所有数据库服务器节点均不连接失败时，尝试连接的最大次数。
- **readFromMasterWhenNoSlaves** Replication-aware connections distribute load by using the master hosts when in read/write state and by using the slave hosts when in read-only state. If, when setting the connection to read-only state, none of the slave hosts are available, an SQLExeception is thrown back. Setting this property to 'true' allows to fail over to the master hosts, while setting the connection state to read-only, when no slave hosts are available at switch instant.
- **loadBalanceConnectionGroup** Logical group of load-balanced connections within a classloader, used to manage different groups independently.  If not specified, live management of load-balanced connections is disabled.
- **loadBalanceEnableJMX**  是否启用jmx监控，可用于在线添加或移除节点。
> Enables JMX-based management of load-balanced connection groups, including live addition/removal of hosts from load-balancing pool.
- **replicationEnableJMX** Enables JMX-based management of replication connection groups, including live slave promotion, addition of new slaves and removal of master or slave hosts from load-balanced master and slave connection pools.
- **loadBalanceStrategy** 平衡策略，有`random`和`bestResponseTime`,默认是'random'。当然，还可以使用自定义的平衡策略。
- **loadBalanceBlacklistTimeout** 节点黑名单的超时时间，单位为毫秒；<font color='red'>当配置为正整数时，才启用黑名单机制，即当slave连接失败时，将其加入到黑名单；默认值为0，即不启用黑名单</font>。
> Time in milliseconds between checks of servers which are unavailable, by controlling how long a server lives in the global blacklist.
- **loadBalancePingTimeout** Time in milliseconds to wait for ping response from each of load-balanced physical connections when using load-balanced Connection.
- **loadBalanceAutoCommitStatementThreshold**
- **loadBalanceAutoCommitStatementRegex**
- **loadBalanceHostRemovalGracePeriod**
- **loadBalanceExceptionChecker** 默认是com.mysql.jdbc.StandardLoadBalanceExceptionChecker
> Fully-qualified class name of custom exception checker.  The class must implement com.mysql.jdbc.LoadBalanceExceptionChecker interface, and is used to inspect SQLExceptions and determine whether they should trigger fail-over to another host in a load-balanced deployment.

retriesAllDown 连接失败时的重试次数，默认是120

# 源码分析
## 识别master host
支持配置多个master,通过属性`type`去标识。

```java
class NonRegisteringDriver{
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
`LoadBalancedConnectionProxy#LoadBalancedConnectionProxy`中根据`loadBalanceStrategy`的配置选用平衡策略。

```java
/**
 + Creates a proxy for java.sql.Connection that routes requests between the given list of host:port and uses the given properties when creating connections.
 + 
 + @param hosts
 +            The list of the hosts to load balance.
 + @param props
 +            Connection properties from where to get initial settings and to be used in new connections.
 + @throws SQLException
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

`bestResponseTime`策略实现中，是依次连接所有可用的节点，之后，再从中选用响应时间最短的。这样的话每次访问都要与所有可用的节点建立连接，当为短连接时，响应时间损耗较为严重。
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
`Connection.setReadOnly(boolean readOnly)`将调用`ReplicationConnectionProxy#setReadOnly`方法，该方法中根据是否只读做节点切换。在切换时，根据平衡策略选择相应的数据库节点去尝试获取连接。

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
`LoadBalancedConnectionProxy#getGlobalBlacklist`中，在获取节点黑名单时，如果所有节点（该方法中的所有节点是同一类型的节点，如同为master节点，或同为slave节点）均不可用，则返回的黑名单为空。此处将导致一个性能问题，例如若只有一个slave节点，那么当slave节点访问失败时，每次的只读请求将依然去尝试连接slave；若一个http请求中有多次readonly请求时，则http 响应将非常的慢。

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

# 注意事项

由于jdk1.7 `DriverManger#getDriver`会优先选择第一个能适用于jdbc.url的driver,然而该版本(<= 5.1.39)的mysql driver只是在`NonRegisteringDriver`中判定jdbc.url是否匹配，没有区分`com.mysql.jdbc.ReplicationDriver`、`com.mysql.jdbc.Driver`。

如果`com.mysql.jdbc.Driver`在`com.mysql.jdbc.ReplicationDriver`之后被注册，那么它永远都不能被使用。此时，当使用`com.mysql.jdbc.Driver`的jdbc.url时，将报错`java.sql.SQLException: Must specify at least one slave host to connect to for master/slave replication load-balancing functionality`，这是因为该jdbc.url确实是没有配置从库。因此，不建议同时使用`com.mysql.jdbc.ReplicationDriver`和`com.mysql.jdbc.Driver`。

```java
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

# MySQL Connector/J 6.0

driver统一为`com.mysql.cj.jdbc.Driver`.

目前只支持jdk1.8版本。

# 参考
- [Configuring Server Failover](http://dev.mysql.com/doc/connector-j/5.1/en/connector-j-config-failover.html)
- [Connector/J Versions, and the MySQL and Java Versions They Support](http://dev.mysql.com/doc/connector-j/6.0/en/connector-j-versions.html)
- [Mysql Replication基本原理（一)](http://shift-alt-ctrl.iteye.com/blog/2266908)
