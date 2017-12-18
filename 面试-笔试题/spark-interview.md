# 内存
## oom

java.lang.OutOfMemoryError: Java heap space
java.lang.OutOfMemoryError：GC overhead limit exceeded

standalone模式部署时，默认使用standalone clint模式提交任务，driver在client端维护，如果处理的数据或者加重的数据过大，driver就可能会内存溢出。
解决办法：

1. 在spark-submit时，指定`--driver-memory memSize`参数设定driver的内存大小，
2. 在配置文件`spark-defaults.conf`文件中设置`spark.driver.memory memSize`属性来改变driver的内存大小；
3. 使用更多的partions
4. Decrease the fraction of memory reserved for caching, using spark.storage.memoryFraction. If you don't use cache() or persist in your code, this might as well be 0. It's default is 0.6, which means you only get 0.4 * 4g memory for your heap. IME reducing the mem frac often makes OOMs go away. UPDATE: From spark 1.6 apparently we will no longer need to play with these values, spark will determine them automatically.
5. Similar to above but shuffle memory fraction. If your job doesn't need much shuffle memory then set it to a lower value (this might cause your shuffles to spill to disk which can have catastrophic impact on speed). Sometimes when it's a shuffle operation that's OOMing you need to do the opposite i.e. set it to something large, like 0.8, or make sure you allow your shuffles to spill to disk (it's the default since 1.0.0).
6. Related to above; use broadcast variables if you really do need large objects.
7. (Advanced) Related to above, avoid String and heavily nested structures (like Map and nested case classes). If possible try to only use primitive types and index all non-primitives especially if you expect a lot of duplicates. Choose WrappedArray over nested structures whenever possible. Or even roll out your own serialisation - YOU will have the most information regarding how to efficiently back your data into bytes, USE IT!
8. (bit hacky) Again when caching, consider using a Dataset to cache your structure as it will use more efficient serialisation. This should be regarded as a hack when compared to the previous bullet point. Building your domain knowledge into your algo/serialisation can minimise memory/cache-space by 100x or 1000x, whereas all a Dataset will likely give is 2x - 5x in memory and 10x compressed (parquet) on disk.
9. jmap -heap [pid] 查看运行过程中内存的使用情况


参考：

- https://stackoverflow.com/questions/21138751/spark-java-lang-outofmemoryerror-java-heap-space
- http://spark.apache.org/docs/latest/configuration.html

> spark.driver.memory: Amount of memory to use for the driver process, i.e. where SparkContext is initialized. (e.g. 1g, 2g).
Note: In client mode, this config must not be set through the SparkConf directly in your application, because the driver JVM has already started at that point. Instead, please set this through the --driver-memory command line option or in your default properties file.

# partion

# DataFrame
# Dataset
