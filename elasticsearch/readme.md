# 说明

- elasticsearch 使用的7.16.1版本,这个镜像我已经破解了，仅供自己学习使用如果侵权请联系删除
- 默认挂载3个PVC，最多挂载10个盘，可以在`elastic.yml`里配置 `path.data`,进而达到磁盘分担压力，避免磁盘成为瓶颈
- 默认每个Pod挂载3个磁盘，最低3个节点，如果配置添加请自动添加`cluster.initial_master_nodes`，当前磁盘是900G
- elk-consumer为自己用go写的kafka消费者，通过消费kafka到es里


## 配置

Dockerfile

```Dockerfile
FROM centos:7
MAINTAINER vroom
RUN useradd elasticsearch
COPY elasticsearch-7.16.1  /usr/local/elasticsearch
RUN chown -R elasticsearch:elasticsearch /usr/local/elasticsearch/
RUN sh /usr/local/elasticsearch/init_elasticsearch.sh
USER elasticsearch
CMD sysctl -w vm.max_map_count=262144
EXPOSE 9200 9300
CMD ["/usr/local/elasticsearch/bin/elasticsearch"]





## 其他配置
```

init_elasticsearch.sh
``` sh
#!/bin/sh
for i in {1..10}; do
	dir=/data$i
	if [ ! -d "$dir" ]; then
		mkdir $dir;
	fi
	chown elasticsearch.elasticsearch -R /data$i
done
```



## 其他
- 启动es和kinbain

```
kubectl apply -f elastic.yaml

```


- 进入其中一个elasicsearch设置用户名密码

e<*7Y^Vroom:;$3

```
cd /usr/local/elasticsearch/
bin/elasticsearch-setup-passwords interactive


```


- 设置kibana ldap
```
bin/elasticsearch-keystore add xpack.security.authc.realms.ldap.ldap1.secure_bind_password

H#K5^X#d2gWFbvow
```

- kinaba创建关掉对应ip
```
PUT _ingest/pipeline/geoip
{
  "description" : "Add geoip info",
  "processors" : [
    {
      "geoip" : {
        "field" : "ip"
      }
    }
  ]
}

```
## elasticsearch集群手动维护

- 为了便于维护且让集群自动归档冷热数据，需要创建索引规程策略和声明周期，分为3不，这里我直接写到py脚本里了

``` py
#!/usr/bin/python
# -*- coding: UTF-8 -*-
import requests
API_USER = "elastic"
API_PASS = "pass"
HOST= 'http://es:9200/'=
def run_cmd(index, hold_day=3, number_of_shards=3):
    # 添加生命周期策略
    json_body = {
        "policy": {
            "phases": {
                "hot": {
                    "actions": {
                        "rollover": {
                            "max_size": "18GB",
                            "max_age": "1d"
                        }
                    }
                },
                "delete": {
                    "min_age": "%dd" % hold_day,
                    "actions": {
                        "delete": {}
                    }
                }
            }
        }
    }
    url = HOST + '_ilm/policy/%s' % index
    response = requests.put(url,
                            auth=(API_USER, API_PASS),
                            headers={'Content-Type': 'application/json'},
                            json=json_body)
    if response.status_code != 200:
        print("\n\nstatus_code=%d, error url=%s  json_bod=%s response=%s  context=%s" % (
            response.status_code, url, json_body, response, response.text))
    else:
        print("status_code=%d, success url=%s  \njson_bod=%s \nresponse=%s\n" % (
            response.status_code, url, json_body, response.text))

    ## 添加模板

    url = HOST + "_template/%s" % index
    json_body = {
        "index_patterns": [
            index + "*"
        ],
        "settings": {
            "index": {
                "lifecycle": {
                    "name": index,
                    "rollover_alias": index
                },
                "number_of_shards": "%d" % number_of_shards,
                "number_of_replicas": "0"
            }
        },
    }
    response = requests.put(url,
                            auth=(API_USER, API_PASS),
                            headers={'Content-Type': 'application/json'},
                            json=json_body)
    if response.status_code != 200:
        print("\n\nstatus_code=%d, error url=%s  json_bod=%s response=%s  context=%s" % (
            response.status_code, url, json_body, response, response.text))
        return exit()
    else:
        print("status_code=%d, success url=%s  \njson_bod=%s \nresponse=%s\n" % (
            response.status_code, url, json_body, response.text))

    # # 添加自动归档
    url = HOST + "%3C" + index + "-%7Bnow%2Fd%7D-000001%3E"
    json_body = {
        "aliases": {
            index: {
                "is_write_index": True
            }
        }
    }
    response = requests.put(url,
                            auth=(API_USER, API_PASS),
                            headers={'Content-Type': 'application/json'},
                            json=json_body)
    if response.status_code != 200:
        print("\n\nstatus_code=%d, error url=%s  json_bod=%s response=%s  context=%s" % (
            response.status_code, url, json_body, response, response.text))
        return exit()
    else:
        print("status_code=%d, success url=%s  \njson_bod=%s \nresponse=%s\n" % (
            response.status_code, url, json_body, response.text))


def create_index(base_index):

    run_cmd("%s" % base_index, hold_day=7)


create_index("你的索引")

```


- `POST {你的索引_alias_name}/_rollover`  手动滚动索引

## 自动消费kafka且自动创建索引规则


- kafka 内容必须是json
- kafka的topic就是索引
- 去除logstash，logstash消耗较大，在设计上就消除掉格式问题
- elk-consumer为自己用go写的kafka消费者，通过消费kafka到es里


```yml 
---
kind: ConfigMap
apiVersion: v1
metadata:
  name: elk-config
  namespace: elk
  annotations:
    kubesphere.io/creator: admin
data:
  elk-config.yaml: |-
    brokers:
      - kafka-kafka-brokers.kafka:9092
    urls:
      - http://elasticsearch-master-headless:9200
    topicGroup:
      - topic: user_topic_data_dot
        pipeline: geoip
      - topic: user_topic_data_info
        pipeline: geoip
      - topic: user_topic_data_visit
        pipeline: geoip
    # kafka group
    groupId: elk-consumer
    elkUser: elasticUser
    elkPassword: "es密码"
    #显示统计日志
    statEnable: true
    #kafka版本
    version: "2.2.0"
    #显示消费日志
    showMessage: true

---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: elk-consumer
  name: elk-consumer
  namespace: elk
spec:
  replicas: 1
  selector:
    matchLabels:
      app: elk-consumer 
  template:
    metadata:
      labels:
        app: elk-consumer   
    spec:
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      containers:
      - env:
        - name: HOSTNAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        name: elk-consumer
        image: hai046/elk-consumer:latest
        imagePullPolicy: Always
        imagePullPolicy: IfNotPresent
        resources:
          limits:
            cpu: 1
            memory: 512Mi
          requests:
            memory: 512Mi
        volumeMounts:
        - mountPath: /etc/localtime
          name: localtime
          readOnly: true
        - mountPath: /run/secrets/elk-config.yaml
          name: elk-consumer-config
          subPath: elk-config.yaml
        - mountPath: "/data/log/consumer"
          name: elk-consumer-log
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File   
      imagePullSecrets:
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 10
      volumes:
      - hostPath:
          path: /etc/localtime
          type: File
        name: localtime
      - name: elk-consumer-config
        configMap:  
          name: elk-config
      - name: elk-consumer-log
        hostPath:
           path: /data/log/consumer
```

