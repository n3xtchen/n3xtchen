---
date: "2023-08-09T00:00:00Z"
description: ""
draft: true
tags: []
title: elasticsearch perf opti example
---

一、优化流程

1）确认数据规模

```
$ curl -s  "bigdata.elasticsearch.service.consul:9200/_cat/indices?v&s=store.size:desc&h=index,pri,rep,doc.count,store.size,pri.store.size" | head -n 20
index                                     pri rep store.size pri.store.size
store_product_income_log                    9   1      2.1tb            1tb
stock_quantity_of_store_products            9   1      1.7tb        892.5gb
stock_quantity_report                       9   1        1tb        550.6gb
stock_index_of_store_product                9   1        1tb        524.9gb
store_product_marketing                     9   1    394.4gb        200.3gb
usergroupusermap                            9   1    270.4gb        135.5gb
realtime_sale                               5   1    260.9gb        130.5gb
often_buy                                   9   1    247.1gb        123.4gb
activity_statistics_main                    9   1    245.8gb        122.8gb
searchword_user                             9   1    228.4gb        114.2gb
sale_forecast                               9   1    223.8gb        111.9gb
stock_index_of_store_and_tax_category       9   1    216.8gb        108.4gb
store_product_salecount                     9   1    113.5gb         56.7gb
inventory_days                              9   1     90.7gb         45.3gb
stock_index_of_store_product_day            9   1     69.8gb         34.9gb
searchword_user_rank                        9   1     57.7gb         28.8gb
stock_index_of_city_product                 9   1     45.2gb         22.5gb
core_report_user_consumption                9   1     43.9gb           22gb
searchword_store                            9   1       40gb           20gb
```

优化对象

store_product_income_log（单位shard：30G）:
- 城市：4 个
- 当前总量：1T （2.1T）
- 日增量 3 G（6G）
- 月增量  3*30= 90G  3shard
- 季增量  90G*3=270G 9shard
- 年增量 270*4=1080G   36shard

```
$ curl -s  "bigdata.elasticsearch.service.consul:9200/store_product_income_log/_settings"  | jq
{
  "store_product_income_log": {
    "settings": {
      "index": {
        "search": {
          "slowlog": {
            "threshold": {
              "fetch": {
                "warn": "1s",
                "info": "500ms"
              },
              "query": {
                "warn": "1s",
                "info": "500ms"
              }
            }
          }
        },
        "refresh_interval": "-1",
        "indexing": {
          "slowlog": {
            "source": "5000"
          }
        },
        "number_of_shards": "9",
        "translog": {
          "flush_threshold_size": "2gb",
          "durability": "async"
        },
        "provided_name": "store_product_income_log",
        "creation_date": "1573207890275",
        "number_of_replicas": "1",
        "uuid": "D4q-tm0kTPy4efx6l16iCA",
        "version": {
          "created": "6070199"
        }
      }
    }
  }
}
```


2）确认ES的配置

```
$ curl  -s  "bigdata.elasticsearch.service.consul:9200/_cat/nodes?h=ip,node.role,cpu,ram.max,heap.max,disk.total,jdk&v"
ip            node.role cpu ram.max heap.max disk.total jdk
172.16.27.84  di          5  59.9gb     32gb      1.7tb 12
172.16.31.247 di          5  59.9gb     32gb      1.7tb 12
172.16.16.79  mdi        11  59.9gb     32gb      1.7tb 12
172.16.16.170 mdi         7  59.9gb     32gb      1.7tb 12
172.16.17.170 di          5  59.9gb     32gb      1.7tb 12
172.16.16.173 mdi         7  59.9gb     32gb      1.7tb 12
172.16.19.240 di          5  59.9gb     32gb      1.7tb 12
172.16.22.219 di          6  59.9gb     32gb      1.7tb 12
```

Master: 3个
数据节点：8个
ingest 节点： 8个

索引最大的分数：3*数据节点数：24个

集群配置

```
$ curl -s  "bigdata.elasticsearch.service.consul:9200/_cluster/settings"  | jq
{
  "persistent": {
    "cluster": {
      "routing": {
        "allocation": {
          "cluster_concurrent_rebalance": "1",
          "node_concurrent_recoveries": "4",
          "node_initial_primaries_recoveries": "8",
          "enable": "all"
        }
      }
    },
    "indices": {
      "recovery": {
        "max_bytes_per_sec": "10mb"
      }
    },
    "xpack": {
      "monitoring": {
        "collection": {
          "enabled": "true"
        }
      }
    }
  },
  "transient": {
    "cluster": {
      "routing": {
        "allocation": {
          "disk": {
            "threshold_enabled": "false",
            "watermark": {
              "low": "20gb",
              "flood_stage": "5gb",
              "high": "10gb"
            }
          },
          "enable": "all",
          "exclude": {
            "_name": ""
          }
        }
      },
      "info": {
        "update": {
          "interval": "1m"
        }
      }
    },
    "logger": {
      "org": {
        "elasticsearch": {
          "index": {
            "fielddata": "TRACE"
          }
        }
      }
    }
  }
}
```

3）确定优化范围和优化方案

性能测试
- 插入性能
- 查询性能

具体方案

store_product_income_log:

最大节点数（单位shard：30G，shard 数量小于最大节点数：24）：
- [x] 月：3 * 2 = 6 （接近我们当前的节点数）
- [ ] 季：9 * 2 = 18
- [ ] 年：36 * 2 = 72

4）方案执行

1. 创建 Template

```
curl -XPUT -H "Content-Type: application/json" bigdata.elasticsearch.service.consul:9200/_template/template_store_product_income_log_m -d @template_store_product_income_log.json
{
  "store_product_income_log": {
    "settings": {
      "index": {
        "search": {
          "slowlog": {
            "threshold": {
              "fetch": {
                "warn": "1s",
                "info": "500ms"
              },
              "query": {
                "warn": "1s",
                "info": "500ms"
              }
            }
          }
        },
        "refresh_interval": "-1",
        "number_of_shards": "5",
        "routing_partition_size": "1",
        "translog": {
          "flush_threshold_size": "3gb",
          "durability": "async"
        },
        "provided_name": "store_product_income_log",
        "creation_date": "1583739660656",
        "number_of_replicas": "0",
        "uuid": "bRFm9pySSi6soWLL2dTvpA",
        "version": {
          "created": "6070199"
        }
      }
    }
  }
}
```

1. 明确细节
    1. 分索引
        - 索引分片数
    2. 路由字段确定
        - 需要服务端介入
2. 确定重建时机
    - 确保对现有系统最低的影响
3. 确定索引速率
4. 按计划执行

）定期优化

清楚删除文档（forcemerge）

```
$ curl -s  "bigdata.elasticsearch.service.consul:9200/_cat/indices?v&s=docs.deleted:desc&h=index,docs.count,docs.deleted,store.size" | head -n 20
index                                     docs.count docs.deleted store.size
stock_index_of_store_product              2256126379    309627016        1tb
store_product_income_log                   688907626    162718186      2.1tb
stock_quantity_of_store_products          4921926281     36662962      1.7tb
store_product_marketing                    554574806     24021868    394.4gb
sale_forecast                              803962997     13446099    223.8gb
searchword_city                            110291776      4369388     20.5gb
core_report_user_consumption                57807976      3141569     43.9gb
knight_statistics                           10822355      2812092     15.4gb
stock_quantity_report                      230331237      2366684        1tb
data_report_tax_category_income             22469420      2308493     23.6gb
stock_index_of_store_and_tax_category      525596921      1975930    216.8gb
often_buy                                  488481416      1146042    247.1gb
knight_tag                                  77408941      1101526     20.1gb
dm_sf_city_product                          12117906       953358      3.5gb
picking_statistics                          10521707       941997      6.9gb
realtime_sale                              597261672       925684    260.9gb
order_count_statistics                      16906469       584575        6gb
knight_score_tag                            51094013       475148     11.8gb
marketing_common_info                        3562116       474642      1.2gb
```


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



