# 说明

- 部署方案官方`https://strimzi.io/`
- 其提供一整套官方解决方案，且都是加密的
- 默认模式不能支持对外访问，例如如果需要部署kafka-manager工具，需要使用`zoo-entrance.yml`，然后才能对外暴漏，否则即使在集群内，也因为secret问题你也访问不了
