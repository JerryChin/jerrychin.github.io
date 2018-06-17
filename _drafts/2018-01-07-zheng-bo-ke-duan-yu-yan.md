---
title: 《郑伯克段于鄢》之我见
tags:  ["国学"]
---

因出生时逆产，姜氏几乎憎恶其长子郑庄公一辈子，这完全不是一个心志健全的母亲之举，可以说姜氏不是称职，公平对待共叔段和郑庄公怎么落得兄弟拔刀。

郑武公从申国讨武姜做老婆，郑武公身份显赫可以推测姜氏在当时必定时申国王侯将相之女，




一张用于排查半天后发现不同系统清理 /tmp 目录千差万别，而。




今天Jetty 默认工作目录中HTML 网页文件，也就是WAR解压后存放的位置，







一条报警短信让神经立即绷了起来，根据提示，迅速连上了这次异常的后端节点，但彻底检查发现服务正常，倒是健康检查的HTML静态页面莫名地返回404。

经查询发现，如果没有明确配置，Jetty 默认使用/tmp 作为工作目录，静态页面就解压到此目录，操作系统显然刚刚清理了此目录。

不同系统下 /tmp 清理策略也不同，见以下总结：

That depends on your distribution. On some system, it's deleted only when booted, others have cronjobs running deleting items older than n hours.

On Debian-like systems: on boot (the rules are defined in /etc/default/rcS).
On RedHat-like systems: by age (, called by systemd-tmpfiles-clean.service).


知道了原因，现在只需重新配置 Jetty 工作目录即可，如何配置见参考链接2

参考链接
1. https://stackoverflow.com/questions/19232182/jetty-starts-in-c-temp/19232771#19232771
2. https://serverfault.com/questions/377348/when-does-tmp-get-cleared
