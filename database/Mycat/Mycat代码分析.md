
# 启动
MycatStartup.main() -> MycatStartup#startup()

```java
MySQLFrontConnectionFactory frontFactory = new MySQLFrontConnectionFactory(
        new MySQLFrontConnectionHandler());
NIOAcceptor server = new NIOAcceptor(BufferPool.LOCAL_BUF_THREAD_PREX
        * NAME + "Server", system.getBindIp(), system.getServerPort(),
        frontFactory, reactorPool);
server.start();
```

# 读写分离
查询`slave`，找到`Mycat-Server/src/main/java/io/mycat/backend/PhysicalDBNode.java`,可看到在方法`getConnection`中，根据是否有注解`/*db_type=master/slave*/`来确定是否访问主库。

在`HintMasterDBHandler#route`中，根据`hintSQLValue`（由sql命令中的注解`/*db_type=master/slave*/`解析得到），决定是否需要访问主库。没有根据之前对sql命令解析得到的sql执行类型确定是否走主库。

```java
@Override
public RouteResultset route(SystemConfig sysConfig, SchemaConfig schema,
                            int sqlType, String realSQL, String charset,
                            MySQLFrontConnection sc, LayerCachePool cachePool,
                            String hintSQLValue)throws SQLNonTransientException {
    
    RouteResultset rrs = RouteStrategyFactory.getRouteStrategy()
                                .route(sysConfig, schema, sqlType, 
                                    realSQL, charset, sc, cachePool);
    
    Boolean isRouteToMaster = null; // 默认不施加任何影响
    
    if(StringUtils.isNotBlank(hintSQLValue)){
        if(hintSQLValue.trim().equalsIgnoreCase("master"))
            isRouteToMaster = true;
        if(hintSQLValue.trim().equalsIgnoreCase("slave")){
            if(sqlType == ServerParse.DELETE || sqlType == ServerParse.INSERT
                    ||sqlType == ServerParse.REPLACE || sqlType == ServerParse.UPDATE
                    || sqlType == ServerParse.DDL){
                LOGGER.warn("should not use hint 'db_type' to route 'delete', 'insert', 'replace', 'update', 'ddl' to a slave db.");
                isRouteToMaster = null; // 不施加任何影响好
            }else{
                isRouteToMaster = false;
            }
        }
    }
    
    if(isRouteToMaster == null){    // 默认不施加任何影响好
        LOGGER.warn(" sql hint 'db_type' error, ignore this hint.");
        return rrs;
    }
    
    if(isRouteToMaster) // 强制走 master 
        rrs.setRunOnSlave(false);
    
    if(!isRouteToMaster)// 强制走slave
        rrs.setRunOnSlave(true);
    
    LOGGER.debug("isRouteToMaster:::::::::" + isRouteToMaster); // false
    return rrs;
}
```



