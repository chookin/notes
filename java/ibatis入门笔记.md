[TOC]
 
# 简介
[MyBatis](http://www.mybatis.org/)是支持普通SQL查询，存储过程和高级映射的优秀持久层框架。MyBatis消除了几乎所有的JDBC代码和参数的手工设置以及结果集的检索。MyBatis使用简单的XML或注解用于配置和原始映射，将接口和Java的POJOs（Plan Old Java Objects，普通的Java对象）映射成数据库中的记录.

# Spring与ibatis整合
ibatis在此工程中的作用相当于hibernate,就是进行数据库的访问，因此，常说的ssh结构也可用ssl取代，只是ibatis是一个轻量级的框架。

## SqlMapClientFactoryBean
在spring中有`org.springframework.orm.ibatis.SqlMapClientFactoryBean`类，该类可用于读取ibatis的配置文件`sqlMapConfig.xml`（命名为其他名字也是可以的），具体的配置位置是在`applicationContext.xml中：
```xml
<bean id="sqlMapClient" class="org.springframework.orm.ibatis.SqlMapClientFactoryBean">
    <!-- 此处应注入ibatis配置文件，而非sqlMap文件，否则会出现“there is no statement.....异常” -->
    <property name="configLocation">
        <value>classpath:sqlMapConfig.xml</value>
    </property>
</bean>
```
`SqlMapClientFactoryBean`类实现了两个接口：`FactoryBean`和`InitializingBean`.

`InitializingBean`只有一个方法`afterPropertiesSet()`.`afterPropertiesSet`的实现中根据ibatis的配置文件、映射文件、属性文件创建`sqlMapClient`.
```java
public void afterPropertiesSet() throws Exception {
    if (this.lobHandler != null) {
        // Make given LobHandler available for SqlMapClient configuration.
        // Do early because because mapping resource might refer to custom types.
        configTimeLobHandlerHolder.set(this.lobHandler);
    }

    try {
        this.sqlMapClient = buildSqlMapClient(this.configLocations, this.mappingLocations, this.sqlMapClientProperties);

        // Tell the SqlMapClient to use the given DataSource, if any.
        if (this.dataSource != null) {
            TransactionConfig transactionConfig = (TransactionConfig) this.transactionConfigClass.newInstance();
            DataSource dataSourceToUse = this.dataSource;
            if (this.useTransactionAwareDataSource && !(this.dataSource instanceof TransactionAwareDataSourceProxy)) {
                dataSourceToUse = new TransactionAwareDataSourceProxy(this.dataSource);
            }
            transactionConfig.setDataSource(dataSourceToUse);
            transactionConfig.initialize(this.transactionConfigProperties);
            applyTransactionConfig(this.sqlMapClient, transactionConfig);
        }
    }

    finally {
        if (this.lobHandler != null) {
            // Reset LobHandler holder.
            configTimeLobHandlerHolder.set(null);
        }
    }
}
```
`FactoryBean`接口的主要方法是`public Object getObject()`。`SqlMapClientFactoryBean`是一个工厂Bean，所以bean `sqlMapClient`对应的是其`getObject`方法所返回的对象，即`sqlMapClient`。
```java
public Object getObject() {
    return this.sqlMapClient;
}
```

## sqlMapConfig.xml
### 示例
```xml
<?xml version="1.0" encoding="UTF-8"?>

<!DOCTYPE sqlMapConfig 
PUBLIC "-//iBATIS.com//DTD SQL Map Config 2.0//EN" 
"http://www.ibatis.com/dtd/sql-map-config-2.dtd">
<sqlMapConfig>
    <settings cacheModelsEnabled="true" enhancementEnabled="true"
        lazyLoadingEnabled="true" maxRequests="32" maxSessions="10"
        maxTransactions="5" useStatementNamespaces="false" />
    <sqlMap resource="chookin/stock/dao/mapping/ActionSqlMap.xml" />
</sqlMapConfig>
```

### 分析
1. Settings 节点

    + cacheModelsEnabled 是否启用SqlMapClient 上的缓存机制。建议设为"true"
    + enhancementEnabled 是否针对POJO启用字节码增强机制以提升getter/setter的调用效能，避免使用JavaReflect所带来的性能开销。同时，这也为Lazy Loading带来了极大的性能提升。建议设为"true"
    + errorTracingEnabled 是否启用错误日志，在开发期间建议设为"true" 以方便调试
    + lazyLoadingEnabled 是否启用延迟加载机制，建议设为"true"
    + maxRequests 最大并发请求数（Statement 并发数）
    + maxTransactions 最大并发事务数
    + maxSessions 最大Session 数。即当前最大允许的并发 SqlMapClient 数。 maxSessions设定必须介于maxTransactions和maxRequests之间.

2. sqlMap
    - sqlMap元素的resource属性告诉Spring去哪找POJO映射文件.

### POJO映射文件
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE sqlMap PUBLIC "-//ibatis.apache.org//DTD SQL Map 2.0//EN" "http://ibatis.apache.org/dtd/sql-map-2.dtd" >
<sqlMap>
    <typeAlias type="chookin.stock.bean.ActionDto" alias="actionDto" />
    <resultMap class="actionDto" id="actionMap">
        <result property="actionId" column="actionId" />
        <result property="actionName" column="actionName" />
    </resultMap>
    <select id="queryAction" resultMap="actionMap">
        SELECT * FROM tb_sys_action 
    </select>
    <insert id="insertAction" parameterClass="actionDto">
        INSERT INTO tb_sys_action (actionName) VALUES (#actionName#)
        <selectKey resultClass="Integer" keyProperty="actionId">
        SELECT @@IDENTITY AS actionId
        </selectKey>
    </insert>
    <update id="updateAction" ></update>
    <delete id="deleteAction" ></delete>
    <select id="selActionByName"  resultMap="actionMap">
        SELECT * FROM tb_sys_action  where ActionName=#actionName#
    </select>
    <select id="queryAllActionName" resultClass="String">
        SELECT ActionName FROM tb_sys_action  
    </select>
</sqlMap>
```

- 通过insert、delete、update、select节点，分别定义了增删改查操作。
- id设定使得在一个配置文件中定义两个同名节点成为可能（多个select节点，以不同id区分）；
- parameterClass 指定了操作的输入参数类型,必须是值对象、；
- typeAlias 定义了类的别名;
- resultMap用来提供数据库查询结果和java对象属性之间的映射，該例中，查詢`queryAction`的結果被映射為java对象`actionDto`,其中，数据表列`actionId`映射为对象`actionDto`的属性`actionId`,数据表列`actionName`被映射为属性`actionName`;
- \#actionName#将在运行期由传入的actionDto对象的actionName属性填充。

```java
public class ActionDto implements Serializable {
    /**action编号**/
    private Integer actionId;

    public Integer getActionId() {
        return actionId;
    }

    public void setActionId(Integer actionId) {
        this.actionId = actionId;
    }

    public String getActionName() {
        return actionName;
    }

    public void setActionName(String actionName) {
        this.actionName = actionName;
    }
    /**action名字**/
    private String actionName;
}
```

## SqlMapClient
SqlMapClient对象是ibatis持久层操作的基础，相当于hibernate中的session，提供对SQL映射的方法。 

- insert()方法实现对插入SQL语句的映射；
- delete()方法实现对删除SQL语句的映射；
- update()方法实现对更新SQL语句的映射；
- queryForList()、queryForMap()、queryForObject()、queryForPaginatedList()等方法提供了一组查询SQL语句的映射。

`SqlMapClientDaoSupport`类有`setSqlMapClient`方法，通过如下配置，再结合Spring的IOC功能，bean `sqlMapClient`传递到了bean `actionDao`，所以bean `actionDao`通过调用`getSqlMapClientTemplate`方法就可以获得ibatis的SqlMapClient对象，从而能够操作数据库。
```xml
<bean id="actionDao" class="chookin.stock.dao.impl.ActionDaoImpl">
    <property name="dataSource">
        <ref bean="dataSource" />
    </property>
    <property name="sqlMapClient">
        <ref bean="sqlMapClient" />
    </property>
</bean>
```
```java
public class ActionDaoImpl extends SqlMapClientDaoSupport implements ActionDao {

    @Override
    public List<ActionDto> queryAction(ActionDto dto) {
        return getSqlMapClientTemplate().queryForList("queryAction", dto);
    }
    ...

public abstract class SqlMapClientDaoSupport extends DaoSupport {
    public final void setSqlMapClient(SqlMapClient sqlMapClient) {
        if (!this.externalTemplate) {
            this.sqlMapClientTemplate.setSqlMapClient(sqlMapClient);
        }
    }
    protected final void checkDaoConfig() {
        if (!this.externalTemplate) {
            this.sqlMapClientTemplate.afterPropertiesSet();
        }
    }
    ...
```

 
