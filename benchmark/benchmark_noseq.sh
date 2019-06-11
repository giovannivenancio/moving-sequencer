#!/bin/bash

((!$#)) && { echo "Usage: $0 <rounds> <test_duration>"; exit 1; }

ROUNDS=$1
TEST_DURATION=$2

BATCH_SIZE=512
BUFFER=1

# cleanup
rm -f ../logs/n_*_noseq.log
rm data/throughput_noseq.dat
rm data/latency_noseq.dat

# n = 1
sudo ./rbcast.sh 1 $BATCH_SIZE $BUFFER $TEST_DURATION $ROUNDS ../logs/n_1_noseq.log

# n = 2
sudo ./rbcast.sh 2 $BATCH_SIZE $BUFFER $TEST_DURATION $ROUNDS ../logs/n_2_noseq.log

# n = 4
sudo ./rbcast.sh 4 $BATCH_SIZE $BUFFER $TEST_DURATION $ROUNDS ../logs/n_4_noseq.log

# n = 8
sudo ./rbcast.sh 8 $BATCH_SIZE $BUFFER $TEST_DURATION $ROUNDS ../logs/n_8_noseq.log

# n = 16
sudo ./rbcast.sh 16 $BATCH_SIZE $BUFFER $TEST_DURATION $ROUNDS ../logs/n_16_noseq.log

# n = 32
sudo ./rbcast.sh 32 $BATCH_SIZE $BUFFER $TEST_DURATION $ROUNDS ../logs/n_32_noseq.log

# n = 64
sudo ./rbcast.sh 64 $BATCH_SIZE $BUFFER $TEST_DURATION $ROUNDS ../logs/n_64_noseq.log

# get averages

echo "n = 1"
throughout_avg=$(cat ../logs/n_1_noseq.log | grep "tx/s" | awk '{print $3}' | python get_average.py)
latency_avg=$(cat ../logs/n_1_noseq.log | grep "latency" | awk '{print $5}' | python get_average.py)
echo "1 $throughout_avg" >> data/throughput_noseq.dat
echo "1 $latency_avg" >> data/latency_noseq.dat

echo "n = 2"
throughout_avg=$(cat ../logs/n_2_noseq.log | grep "tx/s" | awk '{print $3}' | python get_average.py)
latency_avg=$(cat ../logs/n_2_noseq.log | grep "latency" | awk '{print $5}' | python get_average.py)
echo "2 $throughout_avg" >> data/throughput_noseq.dat
echo "2 $latency_avg" >> data/latency_noseq.dat

echo "n = 4"
throughout_avg=$(cat ../logs/n_4_noseq.log | grep "tx/s" | awk '{print $3}' | python get_average.py)
latency_avg=$(cat ../logs/n_4_noseq.log | grep "latency" | awk '{print $5}' | python get_average.py)
echo "4 $throughout_avg" >> data/throughput_noseq.dat
echo "4 $latency_avg" >> data/latency_noseq.dat

echo "n = 8"
throughout_avg=$(cat ../logs/n_8_noseq.log | grep "tx/s" | awk '{print $3}' | python get_average.py)
latency_avg=$(cat ../logs/n_8_noseq.log | grep "latency" | awk '{print $5}' | python get_average.py)
echo "8 $throughout_avg" >> data/throughput_noseq.dat
echo "8 $latency_avg" >> data/latency_noseq.dat

echo "n = 16"
throughout_avg=$(cat ../logs/n_16_noseq.log | grep "tx/s" | awk '{print $3}' | python get_average.py)
latency_avg=$(cat ../logs/n_16_noseq.log | grep "latency" | awk '{print $5}' | python get_average.py)
echo "16 $throughout_avg" >> data/throughput_noseq.dat
echo "16 $latency_avg" >> data/latency_noseq.dat

echo "n = 32"
throughout_avg=$(cat ../logs/n_32_noseq.log | grep "tx/s" | awk '{print $3}' | python get_average.py)
latency_avg=$(cat ../logs/n_32_noseq.log | grep "latency" | awk '{print $5}' | python get_average.py)
echo "32 $throughout_avg" >> data/throughput_noseq.dat
echo "32 $latency_avg" >> data/latency_noseq.dat

echo "n = 64"
throughout_avg=$(cat ../logs/n_64_noseq.log | grep "tx/s" | awk '{print $3}' | python get_average.py)
latency_avg=$(cat ../logs/n_64_noseq.log | grep "latency" | awk '{print $5}' | python get_average.py)
echo "64 $throughout_avg" >> data/throughput_noseq.dat
echo "64 $latency_avg" >> data/latency_noseq.dat
