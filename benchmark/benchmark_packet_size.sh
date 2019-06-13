#!/bin/bash

((!$#)) && { echo "Usage: $0 <num_replicas> <rounds> <test_duration>"; exit 1; }

REPLICAS=$1
ROUNDS=$2
TEST_DURATION=$3

BUFFER=64

# cleanup
rm -f ../logs/bs_*.log
rm data/throughput_bs.dat
rm data/latency_bs.dat

# batch size = 256
sudo ./sequencer.sh 0 $REPLICAS 256 $BUFFER $TEST_DURATION $ROUNDS ../logs/bs_256.log

# batch size = 512
sudo ./sequencer.sh 0 $REPLICAS 512 $BUFFER $TEST_DURATION $ROUNDS ../logs/bs_512.log

# batch size = 1024
sudo ./sequencer.sh 0 $REPLICAS 1024 $BUFFER $TEST_DURATION $ROUNDS ../logs/bs_1024.log

# batch size = 2048
sudo ./sequencer.sh 0 $REPLICAS 2048 $BUFFER $TEST_DURATION $ROUNDS ../logs/bs_2048.log

# batch size = 4096
sudo ./sequencer.sh 0 $REPLICAS 4096 $BUFFER $TEST_DURATION $ROUNDS ../logs/bs_4096.log

# batch size = 8192
sudo ./sequencer.sh 0 $REPLICAS 8192 $BUFFER $TEST_DURATION $ROUNDS ../logs/bs_8192.log

# batch size = 16384
sudo ./sequencer.sh 0 $REPLICAS 16384 $BUFFER $TEST_DURATION $ROUNDS ../logs/bs_16384.log

# get averages

echo "n = 256"
throughout_avg=$(cat ../logs/bs_256.log | grep "tx/s" | awk '{print $3}' | python get_average.py)
latency_avg=$(cat ../logs/bs_256.log | grep "latency" | awk '{print $5}' | python get_average.py)
echo "256 $throughout_avg" >> data/throughput_bs.dat
echo "256 $latency_avg" >> data/latency_bs.dat

echo "n = 512"
throughout_avg=$(cat ../logs/bs_512.log | grep "tx/s" | awk '{print $3}' | python get_average.py)
latency_avg=$(cat ../logs/bs_512.log | grep "latency" | awk '{print $5}' | python get_average.py)
echo "512 $throughout_avg" >> data/throughput_bs.dat
echo "512 $latency_avg" >> data/latency_bs.dat

echo "n = 1024"
throughout_avg=$(cat ../logs/bs_1024.log | grep "tx/s" | awk '{print $3}' | python get_average.py)
latency_avg=$(cat ../logs/bs_1024.log | grep "latency" | awk '{print $5}' | python get_average.py)
echo "1024 $throughout_avg" >> data/throughput_bs.dat
echo "1024 $latency_avg" >> data/latency_bs.dat

echo "n = 2048"
throughout_avg=$(cat ../logs/bs_2048.log | grep "tx/s" | awk '{print $3}' | python get_average.py)
latency_avg=$(cat ../logs/bs_2048.log | grep "latency" | awk '{print $5}' | python get_average.py)
echo "2048 $throughout_avg" >> data/throughput_bs.dat
echo "2048 $latency_avg" >> data/latency_bs.dat

echo "n = 4096"
throughout_avg=$(cat ../logs/bs_4096.log | grep "tx/s" | awk '{print $3}' | python get_average.py)
latency_avg=$(cat ../logs/bs_4096.log | grep "latency" | awk '{print $5}' | python get_average.py)
echo "4096 $throughout_avg" >> data/throughput_bs.dat
echo "4096 $latency_avg" >> data/latency_bs.dat

echo "n = 8192"
throughout_avg=$(cat ../logs/bs_8192.log | grep "tx/s" | awk '{print $3}' | python get_average.py)
latency_avg=$(cat ../logs/bs_8192.log | grep "latency" | awk '{print $5}' | python get_average.py)
echo "8192 $throughout_avg" >> data/throughput_bs.dat
echo "8192 $latency_avg" >> data/latency_bs.dat

echo "n = 16384"
throughout_avg=$(cat ../logs/bs_16384.log | grep "tx/s" | awk '{print $3}' | python get_average.py)
latency_avg=$(cat ../logs/bs_16384.log | grep "latency" | awk '{print $5}' | python get_average.py)
echo "16384 $throughout_avg" >> data/throughput_bs.dat
echo "16384 $latency_avg" >> data/latency_bs.dat
