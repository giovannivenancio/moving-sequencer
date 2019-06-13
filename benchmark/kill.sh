#!/bin/bash

echo "killing processes"
sudo pkill -f replica.py
sudo pkill -f fd.py
sudo pkill -f client.py
sudo pkill -f sequencer.py
sudo pkill -f collector.sh
rm ../src/metrics.log

echo "killing containers"
docker kill $(docker ps -a | awk '{print $1}' | grep -v -i cont)

echo "removing containers"
docker rm $(docker ps -a | awk '{print $1}' | grep -v -i cont)

