# 1、k8s部署架构说明

- 使用功能springcloud作为基础框架
- [apollo作为配置中心](apollo/readme.md)
- [consul作为注册中心](consul/readme.md)
- [rabbitMQ作为消息总线](rabbitmq/readme.md)
- [kafka作为日志消费队列](kafka/readme.md)
- mysql作为关系数据库存储
- mybatisPlus作为ORM框架
- redis作为NoSql缓存和业务KV支撑
- [filebeat作为日志收集](filebeat/readme.md)
- elasticsearch作为日志分析
- [grpc作为RPC](grpc.md)
- xxl-job作为分布式任务框架
- spring gateway+sentinel作为网关和限流
- [微服务项目部署模板](projects/readme.md)
- 使用对象服务作为日志备份
- 其他常用模块

# 2、标准架构设计

 基础服务架构
![整体架构设计](images/整体架构设计.png)
# 3、grpc框架

grpc 