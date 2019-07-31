---
title: 优化 MongoDB 日志服务
tags:  ["MongoDB"]
---

MongoDB 默认输出所有操作日志，这显然不是我们期望的行为，如果没有特别注意这个问题，随意地存放数据库文件和日志文件到相同磁盘，数据库写操作与日志追加操作将会相互争抢 IO 资源，导致系统吞吐率下降。

因此建议将日志文件指定到一块空闲磁盘，或者干脆直接使用系统盘。数据库文件则使用其它空闲磁盘。

```
--logpath /logs/mongodb/mongod.log --logappend --logRotate reopen
```

以上选项代表输出日志到 /logs/mongodb/mongod.log 文件，--logRotate 代表执行 logRotate 操作命令时怎么处理，这里要求重新打开日志文件，也可以指定 rename 表示创建一个新的日志文件， --logappend 表示Mongo 追加日志

另外我们可以善用 MongoDB 提供的一些日志相关[配置选项](https://docs.mongodb.com/manual/reference/program/mongod/)，如 `--quiet` 命令行选项以控制日志信息冗余程度。

```
--quiet
```

表示以安静模式运行 **mongod**，以控制日志输出数量，以下日志将会被屏蔽：

* 数据库命令输出
* 同步复制活动
* 接受连接和关闭链接事件

**mongod** 仍然输出大量 WRITE 操作日志，MongoDB 的日志等级如同其它软件，按严重等级可以化为 致命、错误、警告、提示、调试。

经过一番查询，我找到以下配置文件选项可以调整日志等级

```
systemLog.component.write.verbosity 
```
对应的 Mongod 命令行选项为
```
mongod --setParameter "logComponentVerbosity={write: ... }"
```

但是非常不幸，我们只能在**调试**和**提示**等级之间切换，真的不理解为什么如此设计。

这种情况下，我们可以将日志重定向 `/dev/null` 完全关闭日志输出，等需要时再行开启。

