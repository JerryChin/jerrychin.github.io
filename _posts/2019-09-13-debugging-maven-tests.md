---
title: 调试 Maven 单元测试
tags:  ["CS"]
---

今天是农历八月十五，祝各位同道中秋快乐！

趁着假期两天空闲，尝试在 MacOS 上面写些程序，不料出师不利，单元测试一直跑不成功，尝试 IDE 断点也始终不成功。

之后查询资料得知，Maven 会 fork 一个进程执行单元测试，这时的断点将对新的线程无效。

如果想要对新的线程打断点有两个方式：

**禁止 Fork**

传入 `-DforkCount=0`，将禁止 fork 新的进程，单元测试将在 Maven 进程中执行，这时的断点将起作用。


**设置调试标志**

传入 `-Dmaven.surefire.debug`，单元测试将暂停，直到调试器接入到 5005 端口，如果你想更为精细地控制调试过去，可以尝试以下参数：

   -Dmaven.surefire.debug="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=8000 -Xnoagent -Djava.compiler=NONE" 
   
   