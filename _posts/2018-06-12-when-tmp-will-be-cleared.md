---
title: Linux 何时清理 /tmp 目录？
tags:  ["Linux"]
---

下午突然收到一条阿里云监控报警，一台上线不久的SLB后端服务器健康检查失败，停止提供服务。

我们在 web 应用内打包了一张 HTML 页面专门用于健康测试。尝试使用浏览器请求此页面，服务器提示 404 错误。但是根据设想，服务端应当完全无响应（SNR）才对，这显然是一次误报。

参考 Jetty 服务器（我们使 Jetty 作为 Servlet 容器）邮件列表中的讨论，我们发现 Jetty 默认使用 `/tmp` 作为工作目录，
每次部署 web 应用时在工作目录中新建一个二级目录，并将 WAR 文件解压至该目录。Jetty 从 web 应用对应二级目录下读取并返回 HTML 页面给客户端。

于是，`cd` 进入二级目录下，发现除了 `WEB-INF` 目录外其余文件都不见了。

我们以往使用 Linux 系统（主要是 Ubuntu ）的经验是系统开机引导时才会清理 `/tmp` 目录，排查系统日志并没有发现系统意外重启过，
唯一可疑之处是这台新上线的机器使用了基于RedHat的 Aliyun Linux 操作系统，完全不同于我们之前使用的 Linux 发行版。

搜索引擎最后给出了确切的答案———— Linux 各发行版有着迥然不同的临时文件清理策略！

为了省事，下面提供了不同 Linux 发行版的`/tmp` 目录清理策略：

发行版 | 何时删除 | 如何配置
--- | --- | ---
Ubuntu 14.04 | 系统开机引导 | 在 `/etc/default/rcS` 中指定`TMPTIME` 参数
Ubuntu 16.10 | 系统开机引导 | 在 `/etc/tmpfiles.d/tmp.conf` 中指定
RedHat-like RHEL6 | 每日定时 | /etc/cron.daily/tmpwatch
RedHat-like RHEL7 | 每日定时 | /usr/lib/tmpfiles.d/tmp.conf
Gentoo | / | /etc/conf.d/bootmisc

建议使用新的Linux 发行版前，先搞清`/tmp` 目录清理策略，以免重蹈覆辙。







