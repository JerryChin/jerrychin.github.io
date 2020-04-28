---
title: Maven PMD 插件集成阿里巴巴 JAVA 规约
tags:  ["CS"]
---

阿里巴巴于 2017 年面向全球开发者发布 Java 编码规约（Alibaba Java Coding Guidelines），全球华人为之雀跃，但千万不要以为阿里巴巴是第一个吃螃蟹的人哦！

事实上，早在 1997年 Java 亲爸爸即升阳公司（Sun Microsystems, Inc.）就提出了 [Java 编码规约概念](https://www.oracle.com/technetwork/java/codeconventions-150003.pdf)，多年之后业界大佬谷歌（Google. Inc.）也不甘人后，也提出了一套自己的[Java 编码规约](https://google.github.io/styleguide/javaguide.html)。

Sun 和 Google 编码规约的着力点都集中在 Java 命名和语法形式上，关于非常有价值的编码实践（Programming Practices）部分浅尝辄止。

这次阿里巴巴提成的编码规约大部分篇章其实都是在谈论最佳实践，关于集合、并发、日志等等，怎么样做才好，这些经验可以迅速提高普通程序员编写的软件质量。

私以为这份规约和 Johua Bloch 所著的《Effective In Java》是一回事儿，如果你觉得这份规约对你很有帮助，那么不妨试试读读这本书。


正如芒格所言人类确实太擅长说废话了，让我们立刻步入正题吧！

阿里巴巴为 [Eclipse 和 Idea 提供了配套的插件以及 PMD 实现](https://github.com/alibaba/p3c)，安装和使用插件都是可视化操作也没什么坑点，我们来看看 PMD 怎么集成阿里巴巴 Java 编码规约。



Step 1. 首先，Maven 引入 PMD 插件


```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-pmd-plugin</artifactId>
    
    <!--- 这里的版本号比较关键 --->
    <version>3.0</version>
</plugin>
```

Step 2. 把阿里巴巴的 PMD 实现添加到 PMD 插件依赖，同时配置 rulesets

```xml
<configuration>
    <printFailingErrors>true</printFailingErrors>
    <rulesets>
        <ruleset>/rulesets/java/ali-comment.xml</ruleset>
        <ruleset>/rulesets/java/ali-concurrent.xml</ruleset>
        <ruleset>/rulesets/java/ali-constant.xml</ruleset>
        <ruleset>/rulesets/java/ali-exception.xml</ruleset>
        <ruleset>/rulesets/java/ali-flowcontrol.xml</ruleset>
        <ruleset>/rulesets/java/ali-naming.xml</ruleset>
        <ruleset>/rulesets/java/ali-oop.xml</ruleset>
        <ruleset>/rulesets/java/ali-orm.xml</ruleset>
        <ruleset>/rulesets/java/ali-other.xml</ruleset>
        <ruleset>/rulesets/java/ali-set.xml</ruleset>
    </rulesets>
</configuration>

<dependencies>
    <dependency>
        <groupId>com.alibaba.p3c</groupId>
        <artifactId>p3c-pmd</artifactId>
        
        <!-- 这里的版本号比较关键 -->
        <version>1.3.6</version>
    </dependency>
</dependencies>
```

这里需要注意阿里巴巴的 PMD 实现引用了 `net.sourceforge.pmd` 包下的依赖，而 PMD 插件也引用了这些依赖，如果两边引入的包版本不一致则可能发生版本冲突。

通过检查阿里巴巴的 PMD 实现 和 PMD 插件 POM 来确认两边版本是否一致。


Step 3. PMD 插件默认项目执行到 verify 阶段才执行，如果你需要测试之前先检查则需要如下配置：

```xml
<executions>
    <execution>
        <phase>validate</phase>
        <goals>
            <goal>check</goal>
        </goals>
    </execution>
</executions>
```

Step 4.  下面是完整的配置(以下示例双方引用的 `net.sourceforge.pmd` 包下的依赖版本一致）

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-pmd-plugin</artifactId>
    <version>3.0</version>
    <configuration>
        <printFailingErrors>true</printFailingErrors>
        <rulesets>
            <ruleset>/rulesets/java/ali-comment.xml</ruleset>
            <ruleset>/rulesets/java/ali-concurrent.xml</ruleset>
            <ruleset>/rulesets/java/ali-constant.xml</ruleset>
            <ruleset>/rulesets/java/ali-exception.xml</ruleset>
            <ruleset>/rulesets/java/ali-flowcontrol.xml</ruleset>
            <ruleset>/rulesets/java/ali-naming.xml</ruleset>
            <ruleset>/rulesets/java/ali-oop.xml</ruleset>
            <ruleset>/rulesets/java/ali-orm.xml</ruleset>
            <ruleset>/rulesets/java/ali-other.xml</ruleset>
            <ruleset>/rulesets/java/ali-set.xml</ruleset>
        </rulesets>
    </configuration>
    <executions>
        <execution>
            <phase>validate</phase>
            <goals>
                <goal>check</goal>
            </goals>
        </execution>
    </executions>
    <dependencies>
        <dependency>
            <groupId>com.alibaba.p3c</groupId>
            <artifactId>p3c-pmd</artifactId>
            <version>1.3.6</version>
        </dependency>
    </dependencies>
</plugin>
```

