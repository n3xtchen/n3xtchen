---
layout: post
title: "elasticsearch-性能优化"
description: ""
category: 
tags: []
---
{% include JB/setup %}

二、规则

建议：
- 分片（Lucense 索引）空间大小  <  ES 最大 JVM 堆空间
  - 一般设置不超过 32G
  - 我们的配置：32G
- 分片数不超过节点数量的3倍
  - 如果分片数过多，大大超过了节点数，很可能会导致一个节点上存在多个分片，一旦该节点故障，即使保持了1个以上的副本，同样有可能会导致数据丢失，集群无法恢复
  - 最优：主分片*（副本+1），这样能保证分片分布在不同的节点上
- Mapping 避免使用 nested（父子更不用考虑了）
  - 默认嵌套字段不超过
    - index.mapping.nested_fields.limit ：50

强制：
- Routing 的分片数 < 索引的分片数


三、小常识

A. 路由查询优化[7]

- 作用：避免不必要的查询，提升查询效率，
- 插入和查询使用：{urll}?routing={路由值}
- 分片算法：shard_num = hash(_routing) % num_primary_shards
- 查询过程：
  1. 确定符合路由的分片，过滤掉不符合要求的分片
  2. 将查询广播到确定的索引分片上进行
  3. 每个分片执行这个搜索查询并返回结果
  4. 结果在通道节点上合并、排序并返回给用户

B. ES 查询的过程[7]
假设你有一个100个分片的索引。当一个请求在集群上执行时会发生什么呢？
1. 这个搜索的请求会被发送到一个节点
2. 接收到这个请求的节点，
    - 没有使用路由：将这个查询广播到这个索引的每个分片上（可能是主分片，也可能是复制分片）
    - 使用路由：将这个查询广播到这个索引的相关路由的每个分片上（可能是主分片，也可能是复制分片）
3. 每个分片执行这个搜索查询并返回结果
4. 结果在通道节点上合并、排序并返回给用户

C. 索引性能优化（写入）

- 减少刷新时长（`refresh_interval`）
- 配置事务（translog）

D. 备份机制（snapshot）[8]

查看备份任务：

```
$ curl -s  "bigdata.elasticsearch.service.consul:9200/_snapshot" | jq
{
  "bigdata_s3_repository": {
    "type": "s3",
    "settings": {
      "bucket": "pupumall",
      "chunk_size": "128mb",
      "endpoint": "s3.cn-north-1.amazonaws.com.cn",
      "max_restore_bytes_per_sec": "80mb",
      "compress": "true",
      "base_path": "es_snapshot/bigdata",
      "max_snapshot_bytes_per_sec": "80mb"
    }
  },
  "order_s3_repository": {
    "type": "s3",
    "settings": {
      "bucket": "pupumall",
      "chunk_size": "128mb",
      "endpoint": "s3.cn-north-1.amazonaws.com.cn",
      "max_restore_bytes_per_sec": "80mb",
      "compress": "true",
      "base_path": "es_snapshot/order",
      "max_snapshot_bytes_per_sec": "80mb"
    }
  }
}
```

查看某个备份的历史：

```
curl -s  "bigdata.elasticsearch.service.consul:9200/_cat/snapshots/bigdata_s3_repository?v" | head
id                      status start_epoch start_time end_epoch  end_time duration indices successful_shards failed_shards total_shards
snap_20200312          SUCCESS 1583946008  17:00:08   1583946237 17:03:57     3.8m     230              1549             0         1549
snap_20200313          SUCCESS 1584032408  17:00:08   1584032633 17:03:53     3.7m     231              1554             0         1554
snap_20200314          SUCCESS 1584118807  17:00:07   1584119108 17:05:08       5m     232              1559             0         1559
snap_20200315          SUCCESS 1584205207  17:00:07   1584205496 17:04:56     4.8m     233              1564             0         1564
snap_20200316          SUCCESS 1584291608  17:00:08   1584291868 17:04:28     4.3m     234              1569             0         1569
snap_20200317          SUCCESS 1584378008  17:00:08   1584378404 17:06:44     6.5m     235              1574             0         1574
snap_20200318          SUCCESS 1584464408  17:00:08   1584464809 17:06:49     6.6m     237              1584             0         1584
snap_20200319          SUCCESS 1584550807  17:00:07   1584551201 17:06:41     6.5m     238              1593             0         1593
snap_20200320          SUCCESS 1584637208  17:00:08   1584637444 17:04:04     3.9m     241              1612             0         1612
```

查看某个备份：

```
$ curl -s  "bigdata.elasticsearch.service.consul:9200/_snapshot/bigdata_s3_repository/snap_20200320" | jq
{
  "snapshots": [
    {
      "snapshot": "snap_20200320",
      "uuid": "m2piM-WWQfenAVAL54rMrQ",
      "version_id": 6070199,
      "version": "6.7.1",
      "indices": [
        "stock_index_of_store_day",
        "idx_raw_knight_position-2020.02.10",
        "core_report_city_user",
        "idx_raw_knight_position-2019.12.07",
        ...
      ],
      "include_global_state": false,
      "state": "SUCCESS",
      "start_time": "2020-03-19T17:00:08.141Z",
      "start_time_in_millis": 1584637208141,
      "end_time": "2020-03-19T17:04:04.770Z",
      "end_time_in_millis": 1584637444770,
      "duration_in_millis": 236629,
      "failures": [],
      "shards": {
        "total": 1612,
        "failed": 0,
        "successful": 1612
      }
    }
  ]
}
```

备份：

PUT /_snapshot/es_backup/snapshot_new?wait_for_completion=true

备份恢复：

POST /_snapshot/my_backup/snapshot_1/_restore?wait_for_completion=true { "indices": "index_1", "rename_replacement": "restored_index_1" }

备份时机：虽然 snapshot 不会占用太多的 cpu、磁盘和网络资源，但还是建议大家尽量在闲时做备份。

E. 持久化变更（translog）[9]

Refresh：写入文件系统 Cache
Flush：执行一个提交并且截断 translog 的行为，写入磁盘
￼
Flush 时机：

- `index.translog.sync_interval`：默认 5s，每 5 秒进行一次磁盘刷新
  - 多少时间间隔内会检查一次translog，来进行一次flush操作。es会随机的在这个值到这个值的2倍大小之间进行一次操作，默认是5s。
- `index.translog.durability`：
  - async:  没 `sync_interval` 时间，进行一次commit ，在发生crash时，可能丢失掉 `sync_interval` 时间段的数据
  - request：手动commit
- `index.translog.flush_threshold_size`：translog 达到该大小自定进行一次刷新
  - 默认，512m

F. 分片分配策略（AllocationDecider）【10】

分片分配就是把一个分片指派到集群中某个节点的过程. 分配决策由主节点完成，分配决策包含两方面：
- 哪些分片应该分配给哪些节点
- 哪个分片作为主分片，哪些作为副本分片

策略如下

- same shard allocation decider
  - 控制一个 shard 的主副本不会分配到同一个节点，提高了数据的安全性
- MaxRetryAllocationDecider
  - 该 Allocationdecider 防止 shard 分配失败一定次数后仍然继续尝试分配。可以通过 `index.allocation.max_retries` 参数设置重试次数。当重试次数达到后，可以通过手动方式重新进行分配。
    - `curl -XPOST "http://localhost:9200/_cluster/reroute?retry_failed"`
- awareness allocation decider
  - 可以确保主分片及其副本分片分布在不同的物理服务器，机架或区域之间，以尽可能减少丢失所有分片副本的风险。
- filter allocation decider
  - 该 decider 提供了动态参数，可以明确指定分片可以分配到指定节点上。
    - `index.routing.allocation.include.{attribute}`
    - `index.routing.allocation.require.{attribute}`
    - `index.routing.allocation.exclude.{attribute}`
  - require 表示必须分配到具有指定 attribute 的节点，include 表示可以分配到具有指定 attribute 的节点，exclude 表示不允许分配到具有指定 attribute 的节点。Elasticsearch 内置了多个 attribute，无需自己定义，包括 _name, _host_ip, _publish_ip, _ip, _host。attribute 可以自己定义到 Elasticsearch 的配置文件。
- disk threshold allocation decider
  - 根据磁盘空间来控制 shard 的分配，防止节点磁盘写满后，新分片还继续分配到该节点。启用该策略后，它有两个动态参数。
    - cluster.routing.allocation.disk.watermark.low参数表示当磁盘空间达到该值后，新的分片不会继续分配到该节点，默认值是磁盘容量的 85%。
    - cluster.routing.allocation.disk.watermark.high参数表示当磁盘使用空间达到该值后，集群会尝试将该节点上的分片移动到其他节点，默认值是磁盘容量的 90%。
- shards limit allocation decider
  - 通过两个动态参数，控制索引在节点上的分片数量。其中 index.routing.allocation.total _ shards_per_node 控制单个索引在一个节点上的最大分片数；
    - cluster.routing.allocation.total_shards_per_node 控制一个节点上最多可以分配多少个分片。
应用中为了使索引的分片相对均衡的负载到集群内的节点，index.routing.allocation.total_shards_per_node 参数使用较多。

G. shard 过多问题[10]

shard 管理并不是 “免费” 的，shard 数量过多会消耗更多的 cpu、内存资源，引发一系列问题

- 引起 master 节点慢
  - 任一时刻，一个集群中只有一个节点是 master 节点，master 节点负责维护集群的状态信息，而且状态的更新是在单线程中运行的，大量的 shard 会导致集群状态相关的修改操作缓慢，比如创建索引、删除索引，更新 setting 等。
  - 单个集群 shard 超过 10 万，这些操作会明显变慢。集群在恢复过程中，会频繁更显状态，引起恢复过程漫长。
  - 我们曾经在单个集群维护 30 多万分片，集群做一次完全重启有时候需要2-4个小时的时间，对于业务来说是难以忍受的。
- 查询慢
  - 查询很多小分片会降低单个 shard 的查询时间，但是如果分片过多，会导致查询任务在队列中排队，最终可能会增加查询的整体时间消耗。
- 起资源占用高
  - Elasticsearch 协调节点接收到查询后，会将查询分发到查询涉及的所有 shard 并行执行，之后协调节点对各个 shard 的查询结果进行归并。
  - 如果有很多小分片，增加协调节点的内存压力，同时会增加整个集群的 cpu 压力，甚至发生拒绝查询的问题。因为我们经常会设置参与搜索操作的分片数上限，以保护集群资源和稳定性，分片数设置过大会更容易触发这个上限。

shard数量（numberofshards）设置过多或过低都会引发一些问题：shard数量过多，则批量写入/查询请求被分割为过多的子写入/查询，导致该index的写入、查询拒绝率上升；对于数据量较大的inex，当其shard数量过小时，无法充分利用节点资源，造成机器资源利用率不高 或 不均衡，影响写入/查询的效率。


H. shard 分片平衡[10]

参数及其作用：

- cluster.routing.rebalance.enable
  - 控制是否可以对分片进行平衡，以及对何种类型的分片进行平衡。可取的值包括：all、primaries、replicas、none，默认值是all。
  - all 是可以对所有的分片进行平衡；primaries 表示只能对主分片进行平衡；replicas 表示只能对副本进行平衡；none表示对任何分片都不能平衡，也就是禁用了平衡功能。该值一般不需要修改。
- cluster.routing.allocation.balance.shard：控制各个节点分片数一致的权重，默认值是 0.45f。增大该值，分配 shard 时，Elasticsearch 在不违反 Allocation Decider 的情况下，尽量保证集群各个节点上的分片数是相近的。
- cluster.routing.allocation.balance.index；控制单个索引在集群内的平衡权重，默认值是 0.55f。增大该值，分配 shard 时，Elasticsearch 在不违反 Allocation Decider 的情况下，尽量将该索引的分片平均的分布到集群内的节点。
- index.routing.allocation.total_shards_per_node：控制单个索引在一个节点上的最大分片数，默认值是不限制。 

当使用cluster.routing.allocation.balance.shard和index.routing.allocation.total_shards_per_node不能使分片平衡时，就需要通过该参数来控制分片的分布。
所以，我们的经验是：创建索引时，尽量将该值设置的小一些，以使索引的 shard 比较平均的分布到集群内的所有节点。
但是也要使个别节点离线时，分片能分配到在线节点，对于有 10 个几点的集群，如果单个索引的主副本分片总数为 10，如果将该参数设置成 1，当一个节点离线时，集群就无法恢复成 Green 状态了。
所以我们的建议一般是保证一个节点离线后，也可以使集群恢复到 Green 状态。

I. shard 操作[10]

- shard 移动：
  - 将分片从一个节点移动到另一个节点，在使用 Elasticsearch 中，鲜有需要使用该接口去移动分片，更多的是使用 AllocationDecider 参数以及平衡参数去自动调整 shard 的位置。
  - 在一些特别的情况下，例如发现大部分热点数据集中在几个节点，可以考虑手工 move 一下。
    - curl -XPOST 'localhost:9200/_cluster/reroute' -d '{"commands" : [ {"move" :{ "index" : "test", "shard" : 0, "from_node" : "node1", "to_node" : "node2"}}]}'
- explain api：Elasticsearch 5.x 以后加入的非常实用的运维接口，可以用来诊断 shard 为什么没有分配，以及 shard 为什么分配在某个节点。
  - `curl -XGET "http://localhost:9200/_cluster/allocation/explain”`
    - { "index": "myindex", "shard": 0, "primary": true }
  - 如果不提供参数调用该 api，Elasticsearch 返回第一个 unassigned shard 未分配的原因：
    - GET /_cluster/allocation/explain
- 分配 stale 分片
  - 在索引过程中，Elasticsearch 首先在 primary shard 上执行索引操作，之后将操作发送到 replica shards 执行，通过这种方式使 primary 和 replica 数据同步。
  - 对于同一个分片的所有 replicas，Elasticsearch 在集群的全局状态里保存所有处于同步状态的分片，称为 in-sync copies。
  - 如果修改操作在 primary shard 执行成功，在 replica 上执行失败，则 primary 和 replica 数据就不在同步，这时 Elasticsearch 会将修改操作失败的 replica 标记为 stale，并更新到集群状态里。
  - 当由于某种原因，对于某个 shard 集群中可用数据只剩 stale 分片时，集群会处于 red 状态，并不会主动将 stale shard 提升为 primary shard，因为该 shard 的数据不是最新的。这时如果不得不将 stale shard 提升为主分片，需要人工介入：
    - curl -XPOST "http://localhost:9200/_cluster/reroute" -d '{"commands":[{ "allocate_stale_primary":{ "index":"my_index","shard":"10", "node":"node_id","accept_data_loss":true }}] }'
- 分配 empty 分片
  - 当由于 lucene index 损坏或者磁盘故障导致某个分片的主副本都丢失时，为了能使集群恢复 green 状态，最后的唯一方法是划分一个空 shard。
    - curl -XPOST "http://localhost:9200/_cluster/reroute" -d '{ "commands":[{ "allocate_empty_primary":{"index":"my_index","shard":"10","node":"node_id", "accept_data_loss":true }}]}’
  - 一定要慎用该操作，会导致对应分片的数据完全清空。

四、引用

[1] Reindex https://www.elastic.co/guide/en/elasticsearch/reference/6.8/docs-reindex.html
[2] alias  https://www.elastic.co/guide/en/elasticsearch/reference/6.7/indices-aliases.html
[3] routing https://www.elastic.co/guide/en/elasticsearch/6.8/current/mapping-routing-field.html
[4] Elasticsearch性能优化总结   https://zhuanlan.zhihu.com/p/43437056
[5] 别再说你不会 ElasticSearch 调优了，都给你整理好了   https://zhuanlan.zhihu.com/p/68512729
[6] 玩转Elasticsearch routing功能  https://zhuanlan.zhihu.com/p/94604871
[7] Elasticsearch分片、副本与路由(shard replica routing) https://www.cnblogs.com/kangoroo/p/7622957.html
[8] Elasticsearch snapshot https://juejin.im/post/6844903939393978381
[9] ES中Refresh和Flush的区别 https://www.jianshu.com/p/15837be98ffd
[10] 高可用 Elasticsearch 集群的分片管理 （Shard）https://www.jianshu.com/p/210465322e18
