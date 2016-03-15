
# trival
namenode http://111.13.47.171:50070 
datanode http://111.13.47.171:50075
resourcemanager http://111.13.47.171:8088
nodemanager http://111.13.47.171:8042

hdfs dfs -mkdir -p /user/work
hdfs dfs -put readme.md .
