# 说明
- 因为rabbitMq配置比较复杂，这里引用[`operator`模式](https://kubernetes.io/zh/docs/concepts/extend-kubernetes/operator/)部署
- 先运行 cluster-operator.yml，在执行`rabbitmq.yml`
- 此文件是我提取整理后得出，原地址可以见[部署方案网站](https://www.rabbitmq.com/kubernetes/operator/using-operator.html)
- 部署后可以使用`get_user_pwd.sh`获取原始密码
- 注意因为我们mq需要支持延迟队列，里面配置有`community-plugins`相关的，如果你项目不需要支持延迟队列，直接删除即可
