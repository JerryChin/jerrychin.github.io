---
title: 记录一次快速迭代开发历程（灰度转换工具）
tags:  ["CS"]
---

昨天看到了微博小秘书关于[全国性悼念活动倡议](https://weibo.com/sinat?refer_flag=1001030103_)，我非常支持这个倡议。 因为修改灰色头像会有一定技术门槛，于是思考能否开发一个小工具方便大家使用。 考虑到第二天就是哀悼日，准备夜间快速开发上线。

 

### 0X00 废话少说先上东西

有兴趣的老哥可以访问该项目[开源地址](https://github.com/JerryChin/grayscale-photo)

小工具里面记录了项目历程，有兴趣可以阅读。

### 0X01 选型

因为时间相当有限，技术选型必须选择较为成熟的脚手架型框架。

基于这样的原则出发，前端框选用 Element.io，Element.io 优势是支持 CDN 引用，你甚至不需要创建一个 Webpack 项目，提供的组件既有颜值也非常稳定可靠，文档也十分齐全。后端框架则采用 Springboot，通过简单引入 Springboot 依赖就可以轻松创建一个 Java web 项目。


### 0X02 核心算法

技术选型完成之后，开始考虑核心算法也就是如何把彩色图片转为灰度图片。我没有图片处理经验，但经过摸索大致了解了转换方法。转换算法其实就是下面的数学公式：

 

    gray(red, green, blue)  = (red + green + blue)/3
 

主要思路是把求得每个像素的RGB 三色平均值，如此把三维的颜色空间映射到一维的灰度空间。通过逐一转换图片的每一个像素，最终我们得到一副只包含灰度的图片。


具体实现如下：

        int width = img.getWidth();
        int height = img.getHeight();

        for (int i = 0; i < height; i++) {

            for (int j = 0; j < width; j++) {

                int p = img.getRGB(j, i);

                int a = (p >> 24) & 0xff;
                int r = (p >> 16) & 0xff;
                int g = (p >> 8) & 0xff;
                int b = p & 0xff;

                int avg = (r + g + b)/3;

                //replace RGB value with avg
                p = (a << 24) | (avg << 16) | (avg << 8) | avg;

                img.setRGB(j, i, p);
            }
        }
 

 

### 0X03 对抗恶意刷流

第二个难点是如何既保证使用体验又避免恶意刷流量，考虑到应用的生命周期极短，我采用的方法是带宽采用按流量计费，应用中增加单 IP 下载次数限制， Guava 的 Cache 类很好的满足了我需求。

 

具体实现如下：

         // Cache 定义，注意到 expireAfterWrite 非常关键，它用来控制限流周期。
         private final LoadingCache<String, AtomicInteger> cache = CacheBuilder.newBuilder().expireAfterWrite(1, TimeUnit.DAYS).build(new CacheLoader<String, AtomicInteger>() {
            @Override
            public AtomicInteger load(final String s) throws Exception {
                return new AtomicInteger(0);
            }
        });


        // 超限检查
        String ip = request.getRemoteAddr();
        AtomicInteger counter = cache.get(ip);

        if (counter.getAndIncrement() > 50) {
            log.error("ip {} try too many time, rejected!", ip);
            throw new RuntimeException("try too many!");
        }
　

### 0X04 总结

该工具流量统计情况如下，最终为 200多人提供了服务。

[![traffic.png](https://i.postimg.cc/q7vYFSRH/traffic.png)](https://postimg.cc/jDBZw8PM)

这是我的第一个作品，甚至我还获得的人生的第一粒金（有慷慨老哥支持了 0.1 元），这个项目技术难度不高，最难的部分其实是推广，即如何让更多的人了解到你的作品，这个是我的短板。


 
