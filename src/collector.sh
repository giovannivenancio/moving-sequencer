#!/bin/bash

while true ; do

  resource_usage=''

  docker stats --no-stream | grep -v "CONTAINER ID" | awk '{print $1}' | ( while read -r container_id ; do
      container_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $container_id)
      cpu_usage=$(docker stats --no-stream | grep $container_id | awk '{print $3}')
      resource_usage="$container_ip $cpu_usage;$resource_usage"
  done

  echo $resource_usage >> metrics.log )

  sleep 1

done
