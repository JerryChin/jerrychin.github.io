---
title: Jetty 静态资源文件无故消失
tags:  ["编程"]
---

一条报警短信让神经立即绷了起来，根据提示，迅速连上了这次异常的后端节点，但彻底检查发现服务正常，倒是健康检查的HTML静态页面莫名地返回404。

经查询发现，如果没有明确配置，Jetty 默认使用/tmp 作为工作目录，静态页面就解压到此目录，操作系统显然刚刚清理了此目录。

不同系统下 /tmp 清理策略也不同，见以下总结：

That depends on your distribution. On some system, it's deleted only when booted, others have cronjobs running deleting items older than n hours.

On Debian-like systems: on boot (the rules are defined in /etc/default/rcS).
On RedHat-like systems: by age (RHEL6 it was /etc/cron.daily/tmpwatch ; RHEL7 and RedHat-like with systemd it's configured in /usr/lib/tmpfiles.d/tmp.conf, called by systemd-tmpfiles-clean.service).
On Gentoo /etc/conf.d/bootmisc.

知道了原因，现在只需重新配置 Jetty 工作目录即可，如何配置见参考链接2

参考链接
1. https://stackoverflow.com/questions/19232182/jetty-starts-in-c-temp/19232771#19232771
2. https://serverfault.com/questions/377348/when-does-tmp-get-cleared
