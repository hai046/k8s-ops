# 说明
- 依次运行`consul.yaml` 部署基础服务
- `consul-server.yaml` 暴漏给集群内访问
- `consul-ui-service.yaml` 节点ip配置，方便集群外访问，不用LB等其他模式是因为云厂商其他模式收费
- 如果执行需要指定`namespace`，可以使用 `-n {namespace}`配置，例如`kubectl apply -f consuer.yaml -n consul`
# 配置说明
- `-retry-join=consul-n`，n表示节点数，这里配置了3个，如果配置更多节点需要手动添加
- 其实`consul-1.consul.$(NAMESPACE).svc.cluster.local` 其实后面4端可以舍弃，前提`dnsPolicy: ClusterFirst`,不能为none，否则dns就不会配置


