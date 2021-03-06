---
title: DriverManager 在 Servlet 容器环境下可能导致 Classloader 内存泄露
tags:  ["JDBC"]
---

开始说明问题之前，先介绍两个概念。

### Classloader 内存泄露
根据 Java Servlet 规范，Servlet 容器中必须为每一个应用提供私有的 Classloader，容器运行期间应用可能关闭或再次部署，相应的 Classloader 将会被 GC 掉。
如果该 Classloader 加载的类或其实例没有被及时回收，将导致 Classloader 内存泄露。


### DriverManager，自动注册机制
DriverManager 首次初始化首先获取当前上下文类加载器，然后使用该加载器通过 SPI 机制加载并注册所有符合 [JDBC 4.0+](https://docs.oracle.com/javadb/10.8.3.0/ref/rrefjdbc4_0summary.html) 规范的数据库驱动。
JDBC 4.0 之前版本，应用开发者请求数据库连接前必须手动注册数据库驱动，这种机制一定程度减轻了应用开发者的工作量。

自动注册流程如下：

1. 应用程序调用 DriverManager 相关接口
2. JVM 加载 DriverManager 类定义，开始执行初始化
3. 获取当前线程上下文类加载器，调用 ServiceLocator 获取所有可用 JDBC 驱动
4. 初始化 JDBC 驱动，开始执行 JDBC 初始化


下面用伪代码和时序图来准备表达自动注册流程：

```java

 +----------------+            +----------------+              +----------------+                                 +----------------+
 |  Container     |            |  Application   |              |  DriverManager |                                 |  JDBC Driver   |
 +----------------+            +----------------+              +----------------+                                 +----------------+
           | Thread.setContextLoader(Application's private Classloader) |                                                  |
           |      init                   |                              |                                                  |
           | ---------------------->     |                              |                                                  |
           |                             | Get database connection      |                                                  |
           |                             |--------------------------->  |  init(执行自动注册)                               |
           |                             |                              |------------                                      |
           |                             |                              |           |                                      |
           |                             |                              |           V                                      |
           |                             |                              |   CL = Thread.getContextLoader()                 |
           |                             |                              |   Load all drivers with                          |
           |                             |                              |   ServiceLocator.load(Driver.class, CL)          |
           |                             |                              |         ------------------------------------>    |                                
           |                             |                              |                                                  |  执行初始化，注册到 DriverManger
           |                             |                              |       RegisterDriver()                           |
           |                             |                              | <----------------------------------------        |
           |                             |                              |                                                  |
            
```


引用链如下（箭头指向被引用对象）：

```
DriverManager --------> Driver Object ------> Driver class -----> ClassLoader -----> 所有此 ClassLoader 加载的类
```

### 揭示谜底

通常来说， Web 应用运行时其线程上下文类加载器就是其私有的 Classloder，这意味着自动注册流程第 3 步将导致 `DriverManager` 继续间接引用该 Web 应用的 Classloader 产生内存泄露，除非应用关闭（undeploy）时主动反注册驱动程序，

Apache Tomcat [官方文档](http://tomcat.apache.org/tomcat-9.0-doc/jndi-datasource-examples-howto.html#DriverManager,_the_service_provider_mechanism_and_memory_leaks)详细论述了这个问题，并提出规避措施，有兴趣的话可以继续阅读。



