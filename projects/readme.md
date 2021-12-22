
- 运行 `sh deploy.sh auth 8210` 生成标准的yml配置文件
- 配置成活和就绪探测器
- 配置有状态的日志输出
- 可自定义配置`JAVA_OPTS`
- 需要配置`ClusterFirst`便于通过服务名查找ip
- 暴漏通用的日志归档策略，便于挂载底成本的`PV/PVC`对象存储进行日志归档


更新：

```
kubectl patch statefulset echo-activity -n xxxx-prod --type=json '-p=[{"op": "replace", "path": "/spec/template/spec/containers/0/image", "value":"xxxx.tencentcloudcr.com/prod/echo-activity:07006da"}]'
```
