---
title: 关于 Linux 何时清理 /tmp 目录引发的思考
tags:  ["Linux"]
---

工作中发生的一次小插曲让我意识到关键业务切不可押宝依赖的服务或系统的默认行为，否则一旦升级后的系统或服务默认行为有所变化，将可能中断服务。

一切要从一条阿里云监控报警短信说起，一台上线不久的[SLB](https://en.wikipedia.org/wiki/Load_balancing_(computing)#Server-side_load_balancers)后端服务器健康检查失败，被停止对外提供服务。

我们立即使用浏览器模拟健康检查请求，服务端并未按设想完全失去响应（SNR），反倒是返回了令人费解 404 错误。
不过，幸好我们有 1台冗余后端服务器，此时对外服务并未完全中断。

参考服务器邮件列表中的讨论，我们发现当前版本的服务器默认使用系统变量 `java.io.tmpdir`中指定的目录作为工作目录。对于Linux，如果没有明确指定，默认`/tmp` ，真是个严重纰漏。

显然，我们过于依赖服务器的默认行为，对使用的服务器原理认识不足是这次误报的首要原因，吃一堑长一智。


附表（常见Linux 发行版 `/tmp` 清理策略）：

发行版 | 何时删除 | 如何配置
--- | --- | ---
Ubuntu 14.04 | 系统开机引导 | 在 `/etc/default/rcS` 中指定`TMPTIME` 参数
Ubuntu 16.10 | 系统开机引导 | 在 `/etc/tmpfiles.d/tmp.conf` 中指定
RedHat-like RHEL6 | 每日定时 | /etc/cron.daily/tmpwatch
RedHat-like RHEL7 | 每日定时 | /usr/lib/tmpfiles.d/tmp.conf
Gentoo | / | /etc/conf.d/bootmisc






