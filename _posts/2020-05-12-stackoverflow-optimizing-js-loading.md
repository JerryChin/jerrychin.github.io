---
title: Stackoverflow 开始优化外部 JavaScript 依赖加载体验
tags:  ["Comments"]
---

Stackoverflow（SO）使用了基于 Googleapis 域名托管的 jQuery 库，由于众所周知的原因，该域名无法在中国大陆访问，导致每次访问 SO 加载都极度缓慢。

对于中国大陆的开发者来说，如果不翻墙的情况下使用 Stackoverflow 简直毫无用户体验可言（中国大陆开发者也是开发者啊！），如果翻墙则使用成本变高，比如像我如果不是遇到太棘手的问题基本就放弃 SO了。

也许你会说国内不是有 [Segmentfault](https://segmentfault.com/) 吗？ 我*，不要和我提这个剽窃的家伙！

总的来说这次改进来的还是有点迟（失望脸，因为[早在五年前就有人针对性地提出了这个问题](https://meta.stackoverflow.com/questions/258288/use-of-ajax-googleapis-com-not-china-friendly#)，直至今日才提供了一个变通方案。

[![fallback.png](https://i.postimg.cc/Rh8hJHZH/fallback.png)](https://postimg.cc/Lgt2rhf9)
