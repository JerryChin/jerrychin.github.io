---
title: 阿里云解析配置多 A 记录实现 DNS 均衡负载
tags:  ["DNS"]
---


### 前言

A 记录（A record）又名主机记录是互联网上最常见的 DNS 资源记录，用于记录域名或子域名关联的主机地址，通常是 IPv4 地址。

任一域名允许关联多个 A 记录，而请求超过 1 个 A 记录的域名时，云解析 DNS 服务器将自动开启轮询调度。这是一种十分廉价且高效的均衡负载方式，配置方式也很简单。


### A 记录配置
首先，前往阿里云解析控制台，点击「添加记录」将弹出下面的配置界面。


[![aliyun-cloud-resolver-resource-record-settings.png](https://i.postimg.cc/bwb7mVkn/aliyun-cloud-resolver-resource-record-settings.png)](https://postimg.cc/JsrYnqT7)

**主机记录**就是你要配置的域名，在**记录值**处填入 IP 地址，点击「确定」保存第一条 A 记录。我们再次点击「添加记录」，这次主机记录不变，在记录值处填入其它 IP 地址。


### 验证

常言道光说不练假把式，我将手头的空闲域名 `a.equesfile.cc` 关联 5 个 A 记录，地址范围从 `127.0.0.1` 到 `127.0.0.5`，下面使用 `nslookup` 查询试试。

[![dns-query-reults-show-it-works.png](https://i.postimg.cc/RhrPzgF3/dns-query-reults-show-it-works.png)](https://postimg.cc/9RpPdtyV)

执行了两次查询命令，从上图可以看出两次响应结果确实是随机的。

### 结束

DNS 均衡负载虽说简单高效，缺点也不少。

第一点、通常无法动态调整主机地址权重（阿里云解析倒是支持权重设置），如果多台主机性能差异较大，则不能很好地均衡负载。

第二点、DNS 服务器通常会缓存查询响应，以便更迅速地向用户提供查询服务，这种设计导致某台主机宕机情况下，即便第一时间修改 A 记录也无济于事。
 
由于 DNS 均衡负载无法满足高可用性要求，通常被用于第一层简单均衡，第二层采用高可用均衡负载服务如 HAProxy 或者 Nginx.