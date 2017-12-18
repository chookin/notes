[TOC]

#  大数据开发面试题

## zookeeper

Zookeeper是分布式的、开源的分布式应用程序协调服务，原本是Hadoop、HBase的一个重要组件。它为分布式应用提供一致性服务的软件，包括：配置维护、域名服务、分布式同步、组服务等。

- zookeeper选举过程？

> 当leader崩溃或者leader失去大多数的follower，这时候zk进入恢复模式，恢复模式需要重新选举出一个新的leader，让所有的Server都恢复到一个正确的状态。Zk的选举算法使用ZAB协议：
>
> 1. 选举线程由当前Server发起选举的线程担任，其主要功能是对投票结果进行统计，并选出推荐的Server；
> 2. 选举线程首先向所有Server发起一次询问(包括自己)；
> 3. 选举线程收到回复后，验证是否是自己发起的询问(验证zxid是否一致)，然后获取对方的id(myid)，并存储到当前询问对象列表中，最后获取对方提议的leader相关信息(id,zxid)，并将这些信息存储到当次选举的投票记录表中；
> 4. 收到所有Server回复以后，就计算出zxid最大的那个Server，并将这个Server相关信息设置成下一次要投票的Server；
> 5. 线程将当前zxid最大的Server设置为当前Server要推荐的Leader，如果此时获胜的Server获得n/2 + 1的Server票数， 设置当前推荐的leader为获胜的Server，将根据获胜的Server相关信息设置自己的状态，否则，继续这个过程，直到leader被选举出来。

- 为什么zookeeper服务建议部署奇数个？
> 所谓的zookeeper容错是指，当宕掉几个zookeeper服务器之后，剩下的个数必须大于宕掉的个数，也就是剩下的服务数必须大于n/2，zookeeper才可以继续使用，无论奇偶数都可以选举leader。
>
> 5台机器最多宕掉2台，还可以继续使用，因为剩下3台大于5/2。说为什么最好为奇数个，是在以最大容错服务器个数的条件下，会节省资源，比如，最大容错为2的情况下，对应的zookeeper服务数，奇数为5，而偶数为6，也就是6个zookeeper服务的情况下最多能宕掉2个服务，所以从节约资源的角度看，没必要部署6（偶数）个zookeeper服务。

- 怎么查看zookeeper的状态，leader, follower

```sh
$ zkServer.sh status
JMX enabled by default
Using config: /home/hadoop/hbase-installed/zookeeper-3.4.5/bin/../conf/zoo.cfg
Mode: follower
```

## hadoop

Hadoop是一个Apache旗下的分布式系统基础架构。

Hadoop1由HDFS和MapReduce构成；

Hadoop2框架核心设计有HDFS、MapReduce、YARN。

Hadoop2主要改进了以下四部分：YARN、NameNode HA、HDFS federation、Hadoop RPC序列化扩展性。详细解释如下：

- YARN是Hadoop2中的资源管理系统，它可以使Hadoop2可以运行更多的处理框架；
- NameNode HA提高了Hadoop的可靠性，当action NameNode宕机时，可立即切换到standby NameNode提供服务；
- HDFS federation让多个NameNode共同管理DataNode，增加了Hadoop的集群规模；
- Hadoop RPC序列化扩展性的提高，是指将数据类型独立可插拔。

### hdfs

HDFS是一个分布式文件系统，具有高容错性，提供高吞吐率的数据访问，能够有效处理海量数据集。

它支持超大文件，能够检测并应对硬件故障，采用流式数据访问，并使用了简化了的一致性模型。但它不适合低延迟环境，大量小文件的读写，并且不支持多用户写入以及随机修改文件。

HDFS由NameNode和DataNode构成；NameNode保存HDFS的元数据，任何修改操作都记录在NameNode中；DataNode把每个HDFS数据块（HDFS处理单元，默认128MB）存储在本地文件系统的单独文件中，以此来存储HDFS数据。

- 如何通过命令查看hdfs集群的健康状况？

> hdfs fsck /

- HDFS数据上传流程？
> 1. Client端发送一个加入文件到HDFS的请求给NameNode；
> 2. NameNode告诉Client端怎样来分发数据块以及分发到哪里；
> 3. Client端把数据分为块（block）然后把这些块分发到DataNode中。
> 4. DataNode在NameNode的指导下复制这些块，保持冗余。

- hdfs集群如何节点下架？
> 配置`hdfs-site.xml`
>
> ```xml
> <property>
> 　　<name>dfs.hosts.exclude</name>
> 　　<value>/home/hadoop/hadoop-installed/conf/excludes</value>
> 　　<description>Names a file that contains a list of hosts that are
> 　　not permitted to connect to the namenode.  The full pathname of the
> 　　file must be specified.  If the value is empty, no hosts are
> 　　excluded.</description>
> </property>
> ```
>
> 在由`dfs.hosts.exclude`指定的文件中填写需要下架的节点名或者IP，一行一条，这将阻止他们去连接Namenode。例如：
>
> ```shell
> $ cat excludes
> lab15
> lab16
> ```
>
> 通知namenode集群节点发生调整。
>
> ```shell
> $ hadoop dfsadmin -refreshNodes
> ```
>
> 这个将阻止他们去连接Namenode。
>
> 查看要下架机器的实时状态
>
> ```shell
> $ hadoop dfsadmin -report
> ```

- hadoop集群的服务器一般需要优化哪些服务器参数？

> 1. 配置`/etc/security/limits.conf`，增加用户的文件数`nofile `和进程数`nproc`；
> 2. 修改``/etc/sysctl.conf`，配置`vm.swappiness = 0`，禁用交换区，该项配置为建议。

### mapreduce

MapReduce是面向大型数据处理的并行计算模型和方法。

Hadoop1中的MapReduce有以下四大缺点：

JobTracker同时负责资源管理和作业控制，导致其扩展性差；

MapReduce采用Master/Slave结构存在的单点故障问题会使整个集群不可用，所以它可靠性差；

MapReduce资源分配基于槽位，两种Map槽位和Reduce槽位工作时间不同却不可共享资源，降低了资源的利用率；

它无法支持多种计算框架，只能使用基于磁盘的离线计算，不支持内存计算、流式计算和迭代式计算。



**map阶段：**

1） InputFormat确定输入数据应该被分为多少个分片。而且为每一个分片创建一个InputSplit实例；

2） 针对每一个InputSplit实例MR框架使用一个map任务来进行处理。在InputSplit中的每一个KV键值对被传送到Mapper的map函数进行处理；

3） map函数产生新的序列化后的KV键值对到一个没有排序的内存缓冲区中；

4） 当缓冲区装满或者map任务完毕后。在该缓冲区的KV键值对就会被排序同一时候流入到磁盘中，形成spill文件，溢出文件；

5） 当有不止一个溢出文件产生后，这些文件会全部被排序，而且合并到一个文件里；

6） 文件里排序后的KV键值对等待被Reducer取走；

**reduce阶段：**

主要包含三个小阶段：

1） shuffle：或者称为fetch阶段（获取阶段），在这个阶段全部拥有同样键的记录都被合并而且发送到同一个Reducer中；

2） sort： 和shuffle同一时候发生，在记录被合并和发送的过程中，记录会依照key进行排序；

3） reduce：针对每一个键会进行reduce函数调用。

**reduce数据流：**

1） 当Mapper完毕map任务后，Reducer開始获取记录，同一时候对他们进行排序并存入自己的JVM内存中的缓冲区；

2） 当一个缓冲区数据装满，则会流入到磁盘；

3） 当全部的Mapper完毕而且Reducer获取到全部和他相关的输入后，该Reducer的全部记录会被合并和排序，包含还在缓冲区中的；

4） 合并、排序完毕后调用reduce方法；输出到HDFS或者依据作业配置到其它地方。

### yarn

YARN包含的组件有：ResourceManager、NodeManager、ApplicationMaster。

Hadoop1.X中的JobTracker被分为两部分：ResourceManager和ApplicationMaster。前者提供集群资源给应用，后者为应用提供执行时环境。

YARN应用生命周期：

1）   client提交一个应用请求到ResourceManager；

2）   ResourceManager中的ApplicationsManager在集群中寻找一个可用的、负载较小的NodeManager；

3）   被找到的NodeManager创建一个ApplicationMaster实例；

4）   ApplicationMaster向ResourceManager发送一个资源请求。ResourceManager回复一个Container的列表。包含这些Container是在哪些NodeManager上启动的信息。

5）   ApplicationMaster在ResourceManager的指导下在每一个NodeManager上启动一个Container，Container在ApplicationMaster的控制下执行一个任务。

Tips：

a.  client能够从ApplicationMaster中获取任务信息；

b. 一个作业一个ApplicationMaster，一个Application能够有多个Container，一个NodeManager也能够有多个Container；

## hbase

Hbase是bigtable的开源版本，是建立的hdfs之上，提供高可靠性、高性能、列存储、可伸缩、实时读写的数据库系统。它介于nosql和RDBMS之间，仅能通过主键(row key)和主键的range来检索数据，仅支持单行事务(可通过hive支持来实现多表join等复杂操作)，主要用来存储非结构化和半结构化的松散数据。与hadoop一样，Hbase目标主要依靠横向扩展，通过不断增加廉价的商用服务器，来增加计算和存储能力。

- hbase 的特点是什么?

> - Hbase一个分布式的基于列式存储的数据库,基于Hadoop的hdfs存储，zookeeper进行管理；
> - Hbase适合存储半结构化或非结构化数据，对于数据结构字段不够确定或者杂乱无章很难按一个概念去抽取的数据；
> - 基于的表包含rowkey，时间戳，和列族。新写入数据时，时间戳更新，同时可以查询到以前的版本；
> - hbase是主从架构。hmaster作为主节点，hregionserver作为从节点。

- hbase读写流程?

> 读：找到要读取数据的region所在的RegionServer，然后按照以下顺序进行读取：先去BlockCache读取，若BlockCache没有，则到Memstore读取，若MemStore中没有，则到HFile中读取。
>
> 写：找到要写入数据的region所在的RegionServer，然后将数据先写到WAL中，然后再将数据写到MemStore等待刷新，回复客户端写入完成。

- hbase首次读写流程?

> - Client从ZooKeeper中读取hbase:meta表
> - Client从hbase:meta中获取想要操作的region的位置信息，并且将hbase:meta缓存在Client端，用于后续的操作；
> - 当一个RegionServer宕机而执行重定位之后，Client需要重新获取新的hase:meta信息进行缓存

- 请描述如何解决Hbase中region太小和region太大带来的冲突?

> Region过大会发生多次compaction，将数据读一遍并重写一遍到hdfs 上，占用io，region过小会造成多次split，region 会下线，影响访问服务。

- HBASE中compact用途是什么，什么时候触发，分为哪两种，有什么区别？

> 在hbase中每当有memstore数据flush到磁盘之后，就形成一个storefile，当storeFile的数量达到一定程度后，就需要将 storefile 文件来进行 compaction 操作。
>
> Compact 的作用：
>
> 1. 合并文件
> 2. 清除过期，多余版本的数据
> 3. 提高读写数据的效率
>
> HBase 中实现了两种 compaction 的方式：minor and major. 这两种 compaction 方式的区别是：
>
> 1. Minor 操作只用来做部分文件的合并操作以及包括 minVersion=0 并且设置 ttl 的过期版本清理，不做任何删除数据、多版本数据的清理工作。
> 2. Major 操作是对 Region 下的HStore下的所有StoreFile执行合并操作，最终的结果是整理合并出一个文件。

- rowkey设计原则？

> RowKey设计：应该具备以下几个属性
>
> 散列性：散列性能够保证相同相似的rowkey聚合，相异的rowkey分散，有利于查询
> 简短性：rowkey作为key的一部分存储在HFile中，如果为了可读性将rowKey设计得过长，那么将会增加存储压力
>
> 唯一性：rowKey必须具备明显的区别性
>
> 业务性：举些例子
>
> 假如我的查询条件比较多，而且不是针对列的条件，那么rowKey的设计就应该支持多条件查询
> 如果我的查询要求是最近插入的数据优先，那么rowKey则可以采用叫上Long.Max-时间戳的方式，这样rowKey就是递减排列

- 列族的设计？

> 列族的设计需要看应用场景
>
> 多列族设计的优劣
>
> - 优势：HBase中数据时按列进行存储的，那么查询某一列族的某一列时就不需要全盘扫描，只需要扫描某一列族，减少了读I/O；其实多列族设计对减少的作用不是很明显，适用于读多写少的场景
> - 劣势：降低了写的I/O性能。原因如下：数据写到store以后是先缓存在memstore中，同一个region中存在多个列族则存在多个store，每个store都一个memstore，当其实memstore进行flush时，属于同一个region的store中的memstore都会进行flush，增加I/O开销

- BloomFilter？

> 主要功能：提供随机读的性能
> 存储开销：BloomFilter是列族级别的配置，一旦表格中开启BloomFilter，那么在生成StoreFile时同时会生成一份包含BloomFilter结构的文件MetaBlock，所以会增加一定的存储开销和内存开销
> 粒度控制：ROW和ROWCOL
> BloomFilter的原理：
>
> - 内部是一个bit数组，初始值均为0
> - 插入元素时对元素进行hash并且映射到数组中的某一个index，将其置为1，再进行多次不同的hash算法，将映射到的index置为1，同一个index只需要置1次
> - 查询时使用跟插入时相同的hash算法，如果在对应的index的值都为1，那么就可以认为该元素可能存在，注意，只是可能存在
>
> 所以BlomFilter只能保证过滤掉不包含的元素，而不能保证误判包含
> 设置：在建表时对某一列设置BloomFilter即可

## spark
- 基本概念

Application:基于Spark的用户程序，包含了一个driver program和集群中多个executor
Driver Program：运行Application的main()函数并创建SparkContext。通常SparkContext代表driver program
Executor：为某Application运行在worker node上的一个进程。该进程负责运行Task，并负责将数据存在内存或者磁盘上。每个Application都有自己独立的executors
Cluster Manager: 在集群上获得资源的外部服务（例如 Spark Standalon，Mesos、Yarn）
Worker Node: 集群中任何可运行Application代码的节点
Task：被送到executor上执行的工作单元。
Job：可以被拆分成Task并行计算的工作单元，一般由Spark Action触发的一次执行作业。
Stage：每个Job会被拆分成很多组Task，每组任务被称为stage，也可称TaskSet。该术语可以经常在日志中看打。
RDD ：Spark的基本计算单元，通过Scala集合转化、读取数据集生成或者由其他RDD经过算子操作得到。

- standalone模式下的组件交互流程？

> 1. 在应用本地启动driver；
> 2. 一个Driver负责跟踪管理该Application运行过程中所有的资源状态和任务状态
> 3. 一个Driver会管理一组Executor
> 4. 一个Executor只执行属于一个Driver的Task

- 宽依赖、窄依赖是什么？stage怎么划分的？

> - 窄依赖，即Narrow Dependency指的是 child RDD只依赖于parent RDD(s)固定数量的partition；
> - 宽依赖，Wide Dependency指的是child RDD的每一个partition都依赖于parent RDD(s)所有partition；
> - 根据宽依赖和窄依赖， 整个job，会划分为不同的stage，像是用篱笆隔开了一样， 如果中间有宽依赖，就用刀切一刀， 前后划分为两个 stage；
> - stage 分为两种， ResultStage 和 ShuffleMapStage， spark job 中产生结果最后一个阶段生成的stage 是ResultStage ， 中间阶段生成的stage 是 ShuffleMapStage。

- checkpoint

## scala
- case class

> 当你声明了一个 case class，Scala 编译器为你做了这些：
> 创建 case class 和它的伴生 object
> 实现了 apply 方法让你不需要通过 new 来创建类实例
> 默认为主构造函数参数列表的所有参数前加 val
> 添加天然的 hashCode、equals 和 toString 方法。由于 == 在 Scala 中总是代表 equals，所以 case class 实例总是可比较的
> 生成一个 copy 方法以支持从实例 a 生成另一个实例 b，实例 b 可以指定构造函数参数与 a 一致或不一致
> 由于编译器实现了 unapply 方法，一个 case class 支持模式匹配

[Scala case class那些你不知道的知识](http://www.jianshu.com/p/deb8ca125f6c)

- 函数返回值

> 块的最后一个表达式的值就是函数的返回值
> 如果使用return返回，那么需要明确指定函数返回类型
> 如果是递归函数，同样需要指定返回类型

[Scala基础之函数](http://blog.csdn.net/wangmuming/article/details/35289997)
## kafka

- 消息队列是什么，为什么需要引入消息队列？

> 当系统中出现“生产“和“消费“的速度或稳定性等因素不一致的时候，就需要消息队列，作为抽象层，弥合双方的差异。“ **消息** ”是在两台计算机间传送的数据单位。消息可以非常简单，例如只包含文本字符串；也可以更复杂，可能包含嵌入对象。消息被发送到队列中，“ **消息队列** ”是在消息的传输过程中保存消息的**容器** 。
>
> 引入消息队列的目的：
>
> 1. 解耦，消息队列在处理过程中间插入了一个隐含的、基于数据的接口层，两边的处理过程都要实现这一接口。这允许你独立的扩展或修改两边的处理过程，只要确保它们遵守同样的接口约束。
> 2. 冗余，消息队列把数据进行持久化直到它们已经被完全处理，通过这一方式规避了数据丢失风险。
> 3. 扩展性，因为消息队列解耦了你的处理过程，所以增大消息入队和处理的频率是很容易的；只要另外增加处理过程即可。
> 4. 可恢复性，消息队列降低了进程间的耦合度，所以即使一个处理消息的进程挂掉，加入队列中的消息仍然可以在系统恢复后被处理。
> 5. 缓冲，消息队列通过一个缓冲层来帮助任务最高效率的执行—写入队列的处理会尽可能的快速，而不受从队列读的预备处理的约束。
> 6. 异步通信，消息队列提供了异步处理机制，允许你把一个消息放入队列，但并不立即处理它。

- 解释一下，在数据制作过程中，你如何能从Kafka得到准确的信息?

> 在数据中，为了精确地获得Kafka的消息，你必须遵循两件事: 在数据消耗期间避免重复，在数据生产过程中避免重复。
>
> 这里有两种方法，可以在数据生成时准确地获得一个语义:
>
> - 每个分区使用一个单独的写入器，每当你发现一个网络错误，检查该分区中的最后一条消息，以查看您的最后一次写入是否成功
> - 在消息中包含一个主键(UUID或其他)，并在用户中进行反复制

- kafka中topic、partion和consumer group的关系

> Topic在逻辑上可以被认为是一个queue，每条消费都必须指定它的Topic，可以简单理解为必须指明把这条消息放进哪个queue里。为了使得Kafka的吞吐率可以线性提高，物理上把Topic分成一个或多个Partition，每个Partition在物理上对应一个文件夹，该文件夹下存储这个Partition的所有消息和索引文件。
> Producer发送消息到broker时，会根据Paritition机制选择将其存储到哪一个Partition。如果Partition机制设置合理，所有消息可以均匀分布到不同的Partition里，这样就实现了负载均衡。如果一个Topic对应一个文件，那这个文件所在的机器I/O将会成为这个Topic的性能瓶颈，而有了Partition后，不同的消息可以并行写入不同broker的不同Partition里，极大的提高了吞吐率。
> consumer接受数据的时候是按照group来接受，kafka确保每个partition只能同一个group中的一个consumer消费，如果想要重复消费，那么需要其他的组来消费。Zookeerper中保存这每个topic下的每个partition在每个group中消费的offset
> - 可以在kafka的`server.properties`中配置默认的partion数量`num.partitions=2`
> - 也可以在生产消息时设定topic数量`kafka-topics.sh --create --zookeeper zk01:2181,zk02:2181,zk03:2181/chroot/kafka --replication-factor 1 --partitions 1 --topic test `

参考：[kafka partition（分区）与 group](https://www.cnblogs.com/liuwei6/p/6900686.html)

- kafka中消息怎么删除的？删除过期消息是否会提高性能？

> - 对于传统的message queue而言，一般会删除已经被消费的消息，而Kafka集群会保留所有的消息，无论其被消费与否。当然，因为磁盘限制，不可能永久保留所有数据（实际上也没必要），因此Kafka提供两种策略删除旧数据。一是基于时间，二是基于Partition文件大小。可以通过配置$KAFKA_HOME/config/server.properties，让Kafka删除一周前的数据，也可在Partition文件超过1GB时删除旧数据，配置如下所示。
> - 因为Kafka读取特定消息的时间复杂度为O(1)，即与文件大小无关，所以这里删除过期文件与提高Kafka性能无关。选择怎样的删除策略只与磁盘以及具体的需求有关。另外，Kafka会为每一个Consumer Group保留一些metadata信息——当前消费的消息的position，也即offset。这个offset由Consumer控制。正常情况下Consumer会在消费完一条消息后递增该offset。当然，Consumer也可将offset设成一个较小的值，重新消费一些消息。因为offet由Consumer控制，所以Kafka broker是无状态的，它不需要标记哪些消息被哪些消费过，也不需要通过broker去保证同一个Consumer Group只有一个Consumer能消费某一条消息，因此也就不需要锁机制，这也为Kafka的高吞吐率提供了有力保障。

```sh
############################# Log Retention Policy #############################

# The following configurations control the disposal of log segments. The policy can
# be set to delete segments after a period of time, or after a given size has accumulated.
# A segment will be deleted whenever *either* of these criteria are met. Deletion always happens
# from the end of the log.

# The minimum age of a log file to be eligible for deletion due to age
log.retention.hours=168

# A size-based retention policy for logs. Segments are pruned from the log unless the remaining
# segments drop below log.retention.bytes. Functions independently of log.retention.hours.
#log.retention.bytes=1073741824

# The maximum size of a log segment file. When this size is reached a new log segment will be created.
log.segment.bytes=1073741824

# The interval at which log segments are checked to see if they can be deleted according
# to the retention policies
log.retention.check.interval.ms=300000
```


## 负载均衡

- 负载均衡的目的？

> 负载均衡集群指使用多台提供相同服务的服务器组成集群系统，提高服务的并发处理能力。负载均衡集群的前端使用一个调度器，将客户端请求平均分配到后端的服务器中，同时调度器可能还具有后端服务器状态检测的功能，将故障的服务器自动下线，使得集群具有一定的容错能力。
>
> 使用负载均衡集群能够有效的扩展服务的并发能力，负载均衡集群中的主机间应该尽量的「低耦合」，最好是「无状态」的，这样就能够方便的增加主机实现扩展。

- 你用过或了解的负载均衡技术有哪些？

> - lvs，四层负载均衡，根据请求报文中的目标地址和端口进行调度
> - nginx，七层负载均衡，根据请求报文的内容进行调度
> - mysql 主从
> - ...

- lvs有哪三种模式？

> 1. NAT：地址转换类型，主要是做地址转换，类似于iptables的DNAT类型，当客户端请求的是集群服务时，LVS 修改请求报文的目标地址为 RIP，转发至后端的 RealServer，并修改后端响应报文的源地址为 VIP，响应至客户端。
>
> 2. DR：DR 值 Direct Routing，直接路由，DR 模型中，Director 和 Realserver 处在同一网络中，对于 Director，VIP 用于接受客户端请求，DIP 用于和 Realserver 通信。对于 Realserver，**每个 Realserver 都配有和 Director 相同的 VIP（此 VIP 隐藏，关闭对 ARP 请求的响应）**，仅用于返回数据给客户端，RIP 用于和 Director 通信。
>
>    当客户端请求集群服务时，请求报文发送至 Director 的 VIP（Realserver的 VIP 不会响应 ARP 请求），Director 将客户端报文的目标 MAC 地址进行重新封装，将报文转发至 Realserver。**Realserver 接收转发的报文，此时报文的源 IP 和目标 IP 都没有被修改，因此 Realserver 接受到的请求报文的目标 IP 地址为本机配置的 VIP，它将使用自己的 VIP 直接响应客户端**。
>
>    LVS-DR 模型中，客户端的响应报文不会经过 Director，因此 Director 的并发能力有很大提升。
>
> 3. TUN：和 DR 模型类似，Realserver 都配有不可见的 VIP，Realserver 的 RIP 是公网地址，且可能和 DIP 不再同一网络中。当请求到达 Director 后，Director 不修改请求报文的源 IP 和目标 IP 地址，而是使用 IP 隧道技术，使用 DIP 作为源 IP，RIP 作为目标 IP 再次封装此请求报文，转发至 RIP 的 Realserver 上，Realserver 解析报文后仍然使用 VIP 作为源地址响应客户端。
