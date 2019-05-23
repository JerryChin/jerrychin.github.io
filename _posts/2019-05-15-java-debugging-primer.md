---
title: 浅谈 Java 调试原理
tags:  ["Java"]
---

Java 平台调试架构（JPDA）由三种接口组成，共同为应用开发调试提供支持。 其中 JVM TI （Tools Interface）定义了 JVM 必须提供的调试接口，JDWP 又名 Java 调试通信协议（Java Debug Wire Protocol），它定义了调试器和目标 JVM （被调试者）之间的通信协议格式与语义，最后 JDI （Java Debug Interface）定义了实现调试所需的应用层接口。

[![JPDA.png](https://i.postimg.cc/9QNn7hr9/JPDA.png)](https://postimg.cc/mPCwvK3Z)

其中的 JPDA Transport 定义了调试器和目标 JVM 之间的通信方式。 此通信是面向连接的，被调试者（又称 debuggee）作为服务端在指定端口侦听调试指令，调试者作为客户端连接此端口发送调试指令、接受调试状态信息。这个架构允许用户轻松调试本地或远程主机上的 JVM。

主要有两种通信方式，socket 通信和共享内存方式。下面演示如何通过 socket 方式调试目标主机。

### 追加以下 JVM 参数，启动目标 JVM

JVM 5.0 或者更新

    -agentlib:jdwp=transport=dt_socket,address=8888,server=y,suspend=y
    
JVM  5.0 之前

    -Xdebug -Xrunjdwp:transport=dt_socket,address=8888,server=y,suspend=y
    
* transport - 调试通信机制，JVM 通常支持两种调试通信机制 ———— socket 通信和共享内存通信，后者要求调试器和目标 JVM 必须同处一台主机。
指定 dt_socket 使用 socket 通信，dt_shmem 使用共享内存通信。
* address - 调试通信地址，如果 server 为 n 则尝试把此地址附加到调试器，进入调试；server 为 y 是监听此地址传入的连接。
对于 socket 通信，这里填写主机名和端口号；否则填写名称。
* suspend - 暂停 JVM 执行，直到有调试器传入连接。 如果调试一些初始化代码，这个选项非常有用。


上面参数的含义是使用 socket 通信方式，侦听 8888 端口调试请求，暂停 JVM 初始化直到调试器传入连接。


### 将通信地址附加到调试器，开始调试

    jdb -attach 8888


参考链接：
1. [Java Debug Wire Protocol (JDWP)](https://docs.oracle.com/javase/8/docs/technotes/guides/troubleshoot/introclientissues005.html)
2. [Connection and Invocation Details](https://docs.oracle.com/javase/7/docs/technotes/guides/jpda/conninv.html#Transports)

