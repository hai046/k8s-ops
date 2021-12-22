#!/bin/sh
project_alias=$1

check_result(){
 if [ $? != 0 ]; then
      echo "$1"
      exit 0
 fi
}



project=echo-${project_alias}
env=prod
image_tag=latest
service_port=$2




cat deployment-${env}.yaml |  sed "s/\${PROJECT_NAME}/${project}/g"| sed "s/\${PROJECT_ALIAS}/${project_alias}/g"|sed "s/\${IMAGE_TAG}/${image_tag}/g" |sed "s/\${SERVICE_PORT}/${service_port}/g"  >  deployment-${env}-${project_alias}.yaml

#kubectl delete -n warm-prod -f deployment-${env}-${project_alias}.yaml
#kubectl apply -n warm-prod -f deployment-${env}-${project_alias}.yaml
