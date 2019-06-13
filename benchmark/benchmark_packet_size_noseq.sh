#!/bin/bash

((!$#)) && { echo "Usage: $0 <num_replicas> <rounds> <test_duration>"; exit 1; }

REPLICAS=$1
ROUNDS=$2
TEST_DURATION=$3

BUFFER=1

# cleanup
rm -f ../logs/bs_*_noseq.log
rm data/throughput_bs_noseq.dat
rm data/latency_bs_noseq.dat

# batch size = 256
sudo ./rbcast.sh $REPLICAS 256 $BUFFER $TEST_DURATION $ROUNDS ../logs/bs_256_noseq.log

# batch size = 512
sudo ./rbcast.sh $REPLICAS 512 $BUFFER $TEST_DURATION $ROUNDS ../logs/bs_512_noseq.log

# batch size = 1024
sudo ./rbcast.sh $REPLICAS 1024 $BUFFER $TEST_DURATION $ROUNDS ../logs/bs_1024_noseq.log

# batch size = 2048
sudo ./rbcast.sh $REPLICAS 2048 $BUFFER $TEST_DURATION $ROUNDS ../logs/bs_2048_noseq.log

# batch size = 4096
sudo ./rbcast.sh $REPLICAS 4096 $BUFFER $TEST_DURATION $ROUNDS ../logs/bs_4096_noseq.log

# batch size = 8192
sudo ./rbcast.sh $REPLICAS 8192 $BUFFER $TEST_DURATION $ROUNDS ../logs/bs_8192_noseq.log

# batch size = 16384
sudo ./rbcast.sh $REPLICAS 16384 $BUFFER $TEST_DURATION $ROUNDS ../logs/bs_16384_noseq.log

# get averages

echo "n = 256"
throughout_avg=$(cat ../logs/bs_256_noseq.log | grep "tx/s" | awk '{print $3}' | python get_average.py)
latency_avg=$(cat ../logs/bs_256_noseq.log | grep "latency" | awk '{print $5}' | python get_average.py)
echo "256 $throughout_avg" >> data/throughput_bs_noseq.dat
echo "256 $latency_avg" >> data/latency_bs_noseq.dat

echo "n = 512"
throughout_avg=$(cat ../logs/bs_512_noseq.log | grep "tx/s" | awk '{print $3}' | python get_average.py)
latency_avg=$(cat ../logs/bs_512_noseq.log | grep "latency" | awk '{print $5}' | python get_average.py)
echo "512 $throughout_avg" >> data/throughput_bs_noseq.dat
echo "512 $latency_avg" >> data/latency_bs_noseq.dat

echo "n = 1024"
throughout_avg=$(cat ../logs/bs_1024_noseq.log | grep "tx/s" | awk '{print $3}' | python get_average.py)
latency_avg=$(cat ../logs/bs_1024_noseq.log | grep "latency" | awk '{print $5}' | python get_average.py)
echo "1024 $throughout_avg" >> data/throughput_bs_noseq.dat
echo "1024 $latency_avg" >> data/latency_bs_noseq.dat

echo "n = 2048"
throughout_avg=$(cat ../logs/bs_2048_noseq.log | grep "tx/s" | awk '{print $3}' | python get_average.py)
latency_avg=$(cat ../logs/bs_2048_noseq.log | grep "latency" | awk '{print $5}' | python get_average.py)
echo "2048 $throughout_avg" >> data/throughput_bs_noseq.dat
echo "2048 $latency_avg" >> data/latency_bs_noseq.dat

echo "n = 4096"
throughout_avg=$(cat ../logs/bs_4096_noseq.log | grep "tx/s" | awk '{print $3}' | python get_average.py)
latency_avg=$(cat ../logs/bs_4096_noseq.log | grep "latency" | awk '{print $5}' | python get_average.py)
echo "4096 $throughout_avg" >> data/throughput_bs_noseq.dat
echo "4096 $latency_avg" >> data/latency_bs_noseq.dat

echo "n = 8192"
throughout_avg=$(cat ../logs/bs_8192_noseq.log | grep "tx/s" | awk '{print $3}' | python get_average.py)
latency_avg=$(cat ../logs/bs_8192_noseq.log | grep "latency" | awk '{print $5}' | python get_average.py)
echo "8192 $throughout_avg" >> data/throughput_bs_noseq.dat
echo "8192 $latency_avg" >> data/latency_bs_noseq.dat

echo "n = 16384"
throughout_avg=$(cat ../logs/bs_16384_noseq.log | grep "tx/s" | awk '{print $3}' | python get_average.py)
latency_avg=$(cat ../logs/bs_16384_noseq.log | grep "latency" | awk '{print $5}' | python get_average.py)
echo "16384 $throughout_avg" >> data/throughput_bs_noseq.dat
echo "16384 $latency_avg" >> data/latency_bs_noseq.dat
