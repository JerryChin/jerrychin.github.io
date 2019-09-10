---
title: 更新 MySQL 从数据库的同步配置信息
tags:  ["MySQL"]
---

如果主数据库主机连接信息出现变化，可以参考如下方式更新从数据库的同步配置信息：

首先，需要注意的是一旦主数据库主机名或者 IP 变化，其它信息将不再保留。


1. 停止同步操作

    STOP SLAVE;
    
2. 打印当前同步信息    
    SHOW SLAVE STATUS;
    
    记下其中的 Master_Log_File 和 Read_Master_Log_Pos 字段
    Master_Log_File: mysql-bin.000101 Read_Master_Log_Pos: 591523680 
    
    
3. 执行更新 MASTER 信息指令    
    CHANGE MASTER TO MASTER_HOST='NEW IP ADDRESS', MASTER_LOG_FILE='刚刚记下的字段信息', MASTER_LOG_POS=刚刚记下的字段信息; 
    
4. 开始同步
    START SLAVE;
    
    