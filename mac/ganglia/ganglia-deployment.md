# ganglia介绍

Ganglia consists of three components:
- Ganglia monitoring daemon (gmond) – a daemon which needs to run on every single node that is monitored. It collects local monitoring metrics and announce them, and (if configured) receives and aggregates metrics sent to it from other gmonds (and even from itself).
  - gmond communicates on UDP port 8649 (specified in udp_send_channel and udp_recv_channel sections in gmond.conf)
- Ganglia meta daemon (gmetad) – a daemon that polls from one or more data sources (a data source can be a gmond or other gmetad) periodically to receive and aggregate the current metrics. The aggregated results are stored in database and can be exported as XML to other clients – for example, the web frontend.
  - gmetad downloads metrics on TCP port 8649 (specified in tcp_accept_channel section in gmond.conf, and in data_source entry in gmetad.conf)
- Ganglia PHP web frontend – it retrieves the combined metrics from the meta daemon and displays them in form of nice, dynamic HTML pages containing various real-time graphs.

# 配置文件

/usr/share/ganglia/conf_default.php

# ganglia

gmond 经常会出问题，建议配置为定时任务

```shell
# restart ganglia-gmond every 10 minutes
*/10 * * * *  /sbin/service gmond restart 1>/dev/null 2>&1
```

# 图表
network图表中，蓝色的byte_out，绿色的byte_in

# 数据存储rrd文件

ganglia-gmetad默认存储监控数据到rrd文件中.

## 文件路径

默认文件存储位置`/var/lib/ganglia/rrds/<cluster-name>/<node-name>/`，每个度量是一个文件，例如`bytes_in.rrd`

```shell
[root@lab21 172.31.167.101]# ll /var/lib/ganglia/
conf/ dwoo/ rrds/
[root@lab21 172.31.167.101]# ll /var/lib/ganglia/rrds/
total 16
drwxr-xr-x  5 root    root    4096 Mar 18 20:59 ..
drwxr-xr-x  2 ganglia ganglia 4096 Mar 18 21:29 __SummaryInfo__
drwxr-xr-x  4 ganglia ganglia 4096 Mar 18 21:29 .
drwxr-xr-x 46 ganglia ganglia 4096 Mar 22 20:44 labs

[root@lab21 172.31.167.101]# ll /var/lib/ganglia/rrds/labs/
total 184
drwxr-xr-x  4 ganglia ganglia 4096 Mar 18 21:29 ..
drwxr-xr-x  2 ganglia ganglia 4096 Mar 18 21:29 repos_server
drwxr-xr-x  2 ganglia ganglia 4096 Mar 18 21:29 __SummaryInfo__
drwxr-xr-x  2 ganglia ganglia 4096 Mar 18 21:44 172.31.167.103
drwxr-xr-x  2 ganglia ganglia 4096 Mar 18 21:52 172.31.167.106
drwxr-xr-x  2 ganglia ganglia 4096 Mar 18 22:24 172.31.167.122

[root@lab21 172.31.167.101]# ll /var/lib/ganglia/rrds/labs/172.31.167.101
total 28264
drwxr-xr-x 46 ganglia ganglia    4096 Mar 22 20:44 ..
drwxr-xr-x  2 ganglia ganglia    4096 Mar 27 15:30 .
-rw-rw-rw-  1 ganglia ganglia  630760 Mar 27 15:35 proc_run.rrd
-rw-rw-rw-  1 ganglia ganglia  630760 Mar 27 15:35 mem_total.rrd
-rw-rw-rw-  1 ganglia ganglia  630760 Mar 27 15:35 load_one.rrd
-rw-rw-rw-  1 ganglia ganglia  630760 Mar 27 15:35 load_five.rrd
-rw-rw-rw-  1 ganglia ganglia  630760 Mar 27 15:35 swap_total.rrd
-rw-rw-rw-  1 ganglia ganglia  630760 Mar 27 15:35 swap_free.rrd
-rw-rw-rw-  1 ganglia ganglia  630760 Mar 27 15:35 proc_total.rrd
-rw-rw-rw-  1 ganglia ganglia  630760 Mar 27 15:35 pkts_out.rrd
-rw-rw-rw-  1 ganglia ganglia  630760 Mar 27 15:35 pkts_in.rrd
-rw-rw-rw-  1 ganglia ganglia  630760 Mar 27 15:35 part_max_used.rrd
-rw-rw-rw-  1 ganglia ganglia  630760 Mar 27 15:35 mem_shared.rrd
-rw-rw-rw-  1 ganglia ganglia  630760 Mar 27 15:35 mem_free.rrd
-rw-rw-rw-  1 ganglia ganglia  630760 Mar 27 15:35 mem_cached.rrd
-rw-rw-rw-  1 ganglia ganglia  630760 Mar 27 15:35 mem_buffers.rrd
-rw-rw-rw-  1 ganglia ganglia  630760 Mar 27 15:35 load_fifteen.rrd
-rw-rw-rw-  1 ganglia ganglia  630760 Mar 27 15:35 disk_total.rrd
-rw-rw-rw-  1 ganglia ganglia  630760 Mar 27 15:35 disk_free.rrd
-rw-rw-rw-  1 ganglia ganglia  630760 Mar 27 15:35 cpu_wio.rrd
-rw-rw-rw-  1 ganglia ganglia  630760 Mar 27 15:35 cpu_user.rrd
-rw-rw-rw-  1 ganglia ganglia  630760 Mar 27 15:35 cpu_system.rrd
-rw-rw-rw-  1 ganglia ganglia  630760 Mar 27 15:35 cpu_speed.rrd
-rw-rw-rw-  1 ganglia ganglia  630760 Mar 27 15:35 cpu_nice.rrd
-rw-rw-rw-  1 ganglia ganglia  630760 Mar 27 15:35 cpu_idle.rrd
-rw-rw-rw-  1 ganglia ganglia  630760 Mar 27 15:35 cpu_aidle.rrd
-rw-rw-rw-  1 ganglia ganglia  630760 Mar 27 15:35 bytes_out.rrd
-rw-rw-rw-  1 ganglia ganglia  630760 Mar 27 15:35 bytes_in.rrd
-rw-rw-rw-  1 ganglia ganglia  630760 Mar 27 15:35 boottime.rrd
```

## 文件查看

```shell
#查看数据库的信息
[root@lab21 172.31.167.101]# rrdtool info bytes_out.rrd
filename = "bytes_out.rrd"
rrd_version = "0003"
step = 15
last_update = 1490602512
ds[sum].type = "GAUGE"
ds[sum].minimal_heartbeat = 120
ds[sum].min = NaN
ds[sum].max = NaN
ds[sum].last_ds = "27.90"
ds[sum].value = 3.3480000000e+02
ds[sum].unknown_sec = 0
rra[0].cf = "AVERAGE"
rra[0].rows = 5856
rra[0].cur_row = 5854
rra[0].pdp_per_row = 1
rra[0].xff = 5.0000000000e-01
rra[0].cdp_prep[0].value = NaN
rra[0].cdp_prep[0].unknown_datapoints = 0
rra[1].cf = "AVERAGE"
rra[1].rows = 20160
rra[1].cur_row = 6669
rra[1].pdp_per_row = 4
rra[1].xff = 5.0000000000e-01
rra[1].cdp_prep[0].value = 0.0000000000e+00
rra[1].cdp_prep[0].unknown_datapoints = 0
rra[2].cf = "AVERAGE"
rra[2].rows = 52704
rra[2].cur_row = 31680
rra[2].pdp_per_row = 40
rra[2].xff = 5.0000000000e-01
rra[2].cdp_prep[0].value = 6.5970000000e+02
rra[2].cdp_prep[0].unknown_datapoints = 0
```

## 导出文件到xml

To get data from ganglia .rrd files and save it in .xml file, you can use rddtool.

```shell
rrdtool dump filename.rrd [filename.xml] [--header|-h {none,xsd,dtd}] [--no-header] [--daemon address] > filename.xml
```

example:

```shell
sudo rrdtool dump bytes_out.rrd > data.xml
```

## 文件内容

度量文件中，粒度基本依次是15 sec(最近一天的)，1 min（最近半个月的），10 min(最近一年的)

提示：网络流量的单位是Bytes/sec，因此1e3是1KB/s，1e7是10KB/s。

```

<!-- Round Robin Archives -->   <rra>
                <cf> AVERAGE </cf>
                <pdp_per_row> 1 </pdp_per_row> <!-- 15 seconds -->

                <params>
                <xff> 5.0000000000e-01 </xff>
                </params>
                <cdp_prep>
                        <ds>
                        <primary_value> 3.1650000000e+01 </primary_value>
                        <secondary_value> 2.3395000000e+02 </secondary_value>
                        <value> NaN </value>
                        <unknown_datapoints> 0 </unknown_datapoints>
                        </ds>
                </cdp_prep>
                <database>
                        <!-- 2017-03-26 14:45:45 CST / 1490510745 --> <row><v> 3.6327000000e+02 </v></row>
                        <!-- 2017-03-26 14:46:00 CST / 1490510760 --> <row><v> 3.6327000000e+02 </v></row>
        <rra>
                <cf> AVERAGE </cf>
                <pdp_per_row> 4 </pdp_per_row> <!-- 60 seconds -->

                <params>
                <xff> 5.0000000000e-01 </xff>
                </params>
                <cdp_prep>
                        <ds>
                        <primary_value> 2.6242000000e+01 </primary_value>
                        <secondary_value> 3.0298000000e+01 </secondary_value>
                        <value> 6.3300000000e+01 </value>
                        <unknown_datapoints> 0 </unknown_datapoints>
                        </ds>
                </cdp_prep>
                <database>
                        <!-- 2017-03-13 15:10:00 CST / 1489389000 --> <row><v> NaN </v></row>
                        <!-- 2017-03-13 15:11:00 CST / 1489389060 --> <row><v> NaN </v></row>
        <rra>
                <cf> AVERAGE </cf>
                <pdp_per_row> 40 </pdp_per_row> <!-- 600 seconds -->

                <params>
                <xff> 5.0000000000e-01 </xff>
                </params>
                <cdp_prep>
                        <ds>
                        <primary_value> 3.1645166667e+01 </primary_value>
                        <secondary_value> 3.1640000000e+01 </secondary_value>
                        <value> 1.0682480000e+03 </value>
                        <unknown_datapoints> 0 </unknown_datapoints>
                        </ds>
                </cdp_prep>
                <database>
                        <!-- 2016-03-26 15:10:00 CST / 1458976200 --> <row><v> NaN </v></row>
                        <!-- 2016-03-26 15:20:00 CST / 1458976800 --> <row><v> NaN </v></row>
```

参考：

- [rrdtool的使用介绍](http://hongtoushizi.iteye.com/blog/2274043)
