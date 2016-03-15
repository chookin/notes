配置hbase-env.sh，配置ZooKpeer是否托管。
hmaster http://111.13.47.171:16010
regionserver http://111.13.47.171:16301

hbase-daemon.sh start thrift
Thrift默认监听的端口是9090

注意http端口的变化
https://issues.apache.org/jira/browse/HBASE-10123

    After 0.98 hbase's default ports have changed to be outside of the ephemeral port range:. 

    hbase.master.port : 60000 -> 16000 
    hbase.master.info.port (http): 60010 -> 16010 
    hbase.regionserver.port : 60020 -> 16020 
    hbase.regionserver.info.port (http): 60030 -> 16030 
    hbase.status.multicast.port : 60100 -> 16100 

