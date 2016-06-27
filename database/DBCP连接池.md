
# 配置参数

- initialSize 连接池启动时创建的初始化连接数量（默认值为0）
- maxActive 连接池中可同时连接的最大的连接数
- minIdle 连接池中最小的空闲的连接数，低于这个数量会被创建新的连接（默认为0，调整为5，该参数越接近maxIdle，性能越好，因为连接的创建和销毁，都是需要消耗资源的；但是不能太大，因为在机器很空闲的时候，也会创建低于minidle个数的连接，类似于jvm参数中的Xmn设置）
- maxIdle 连接池中最大的空闲的连接数，超过的空闲连接将被释放，如果设置为负数表示不限制（默认为8个，maxIdle不能设置太小，因为假如在高负载的情况下，连接的打开时间比关闭的时间快，会引起连接池中idle的个数 上升超过maxIdle，而造成频繁的连接销毁和创建，类似于jvm参数中的Xmx设置)
- defaultAutoCommit 连接池创建的连接的默认的auto-commit状态
- logAbandoned 连接被泄露时是否打印
- removeAbandoned 超过removeAbandonedTimeout时间后，是否进行没用连接（废弃）的回收
- removeAbandonedTimeout 超过时间限制，回收没有用(废弃)的连接，单位秒
- maxWait 超时等待时间以毫秒为单位
- timeBetweenEvictionRunsMillis 设置的Evict线程的时间，单位ms，大于0才会开启evict检查线程
- numTestsPerEvictionRun 在每次空闲连接回收器线程(如果有)运行时检查的连接数量
- minEvictableIdleTimeMillis 连接池中连接，在时间段内一直空闲，被逐出连接池的时间
- validationQuery `select 1` SQL查询,用来验证从连接池取出的连接,在将连接返回给调用者之前.如果指定,则查询必须是一个SQL SELECT并且必须返回至少一行记录
- testOnBorrow 指明是否在从池中取出连接前进行检验,如果检验失败,则从池中去除连接并尝试取出另一个
- testOnReturn 在进行returnObject对返回的connection进行validateObject校验
- poolPreparedStatements：开启池的prepared（默认是false，未调整，经过测试，开启后的性能没有关闭的好。）
- maxOpenPreparedStatements：开启池的prepared 后的同时最大连接数（默认无限制，同上，未配置）

参考：

- [dbcp基本配置和重连配置](http://agapple.iteye.com/blog/772507)
- [BasicDataSource Configuration Parameters](http://commons.apache.org/proper/commons-dbcp/configuration.html)
