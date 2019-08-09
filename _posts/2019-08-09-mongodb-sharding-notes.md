---
title: MongoDB Sharding（分片）笔记
tags: ["MongoDB"]
---

Sharding 是一种将数据分散到多台主机上的方法，使得 MongoDB 能够支持处理超大数据集和超高吞吐量。实质上 Sharding 实现了横向扩展能力。



## Sharding 结构

Sharding 集群由以下组件构成：
* shard —— 每个 shard 节点存储了分片数据的一部分。
* mongos —— 可以看做查询路由器，mongos 是客户端应用程序和shard 集群之间的接口
* config servers —— 配置服务器保存了集群的元信息和配置信息。

<img src="/assets/img/sharded-cluster-production-architecture.bakedsvg.svg" title="sharded-cluster-production-architecture"/>

MongoDB 在 collection 层面分片，将 collection 中的数据分散到不同 shard.


## 分片键
为了划分 collection，MDB(MongoDB) 需要分片键来分区 collection，分片键由不可变字段或者出现在每一个文档中的字段构成。
你可以在分片collection 时选择一个分片键，一旦选择不可更改，一个集合只能有一个分片键。
分片非空集合，要求该集合必须必须存在一个以分片键起始的索引。分片键的选择可能对性能产生影响，务必小心。


分块 —— MDB 将分片数据划分为块，每一块都有一个上（包含）下（不包含）界。

自动均衡 —— MDB 支持自动迁移分块，以便实现自均衡。

优势

* R/W 速度提升
* 存储能力提升
* 高可用


注意点
* 一旦 shard 便无法撤销


## 分片和非分片集合混合

MDB 允许混合集合，非分片集合存储在 PRIMARY SHARD（默认是可用空间最多的，用 MOVEPRIMARY 改变）。

<img src="/assets/img/sharded-cluster-primary-shard.bakedsvg.svg"  title="sharded-cluster-primary-shard"/>



## 连接分片集群

你必须连接至 mongos 路由器以便读取或写入任何分片集群中的集合。客户端永远都不应该直接访问 SHARD!!!!!

<img src="/assets/img/sharded-cluster-mixed.bakedsvg.svg"  title="sharded-cluster-mixed"/>



## 分片策略


MDB 支持两种分片策略，分别是 散列分片 和 区域分片。


散列分片需要先计算出分片键的哈希值，基于哈希值，每个分块都被指定一段区域。（意思应该是每个分块对应一段区域，如果散列值落到此区域这存储到这个分块）

（MDB 将自动计算散列值！ Nice）


基于散列值的数据分布更加均匀，特别是分片键递增的场合。这也意味着，基于分片键的区域查询操作更加耗时。

<img src="/assets/img/sharding-hash-based.bakedsvg.svg"  title="sharding-hash-based"/>

区域分片基于分片键将数据划分成区域，同上。一段区域的分片键更容易保存到同一片chunk。


## 部署成员数量说明

| 组件 | 数量 | 默认端口 |
|------|------|------|
| Shard    |   sharding 至少需要 2个 shard |27018|
| mongos    |   一个即可，可以更多 |27017|
| config server    |   1 个（完全无备份） 3个（safe!） |27019|

## 常用指令

```
// 初始化 Config 服务器所属 Replica Set


rs.initiate(
  {
    _id: "helloworld",
    configsvr: true,
    version: 1,
    members: [
      { _id : 0, host : "10.252.107.239:27019" },
    ]
  }
)


// 查询 config 最近都干了什么
use config
db.changelog.find().sort({time: -1}).limit(5).pretty()
db.actionlog.find().sort({time: -1}).limit(5).pretty()


// 修改分块大小
use config 
db.settings.save( { _id:"chunksize", value: <,MB> } ) 


// 手动移动分块，必须先停止 Balancer
use admin 
db.runCommand({ moveChunk: "db.collection", bounds : [ { "shardKey" : NumberLong("-7580132945406171168") }, { "shardKey" : NumberLong("-5939573624981956557") } ], to: "new_shard_" })    




// 创建散列索引（用于分片）
db.collection.createIndex({"key": "hashed"});




// 获取分片集合分片情况
db.collection.getShardDistribution()

```




帮助链接：
* [部署以散列值为分片键类型的分片集群](https://docs.mongodb.com/v3.4/tutorial/deploy-sharded-cluster-hashed-sharding/#deploy-hashed-sharded-cluster-shard-collection)
* [部署分片集群](https://docs.mongodb.com/manual/tutorial/deploy-shard-cluster/)
* [分片集群查询路由器](https://docs.mongodb.com/manual/core/sharded-cluster-query-router/#sharding-mongos-broadcast)
* [如何管理分片集群](https://docs.mongodb.com/manual/tutorial/manage-sharded-cluster-balancer/)
* [调整分片节点容量](https://docs.mongodb.com/manual/tutorial/manage-sharded-cluster-balancer/#sharded-cluster-config-max-shard-size)