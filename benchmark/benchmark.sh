#!/bin/bash

((!$#)) && { echo "Usage: $0 <rounds> <test_duration>"; exit 1; }

ROUNDS=$1
TEST_DURATION=$2

BATCH_SIZE=512
BUFFER=64

# cleanup
rm -f ../logs/n_*.log
rm data/throughput.dat
rm data/latency.dat

# n = 1
sudo ./sequencer.sh 0 1 $BATCH_SIZE $BUFFER $TEST_DURATION $ROUNDS ../logs/n_1.log

# n = 2
sudo ./sequencer.sh 0 2 $BATCH_SIZE $BUFFER $TEST_DURATION $ROUNDS ../logs/n_2.log

# n = 4
sudo ./sequencer.sh 0 4 $BATCH_SIZE $BUFFER $TEST_DURATION $ROUNDS ../logs/n_4.log

# n = 8
sudo ./sequencer.sh 0 8 $BATCH_SIZE $BUFFER $TEST_DURATION $ROUNDS ../logs/n_8.log

# n = 16
sudo ./sequencer.sh 0 16 $BATCH_SIZE $BUFFER $TEST_DURATION $ROUNDS ../logs/n_16.log

# n = 32
sudo ./sequencer.sh 0 32 $BATCH_SIZE $BUFFER $TEST_DURATION $ROUNDS ../logs/n_32.log

# n = 64
sudo ./sequencer.sh 0 64 $BATCH_SIZE $BUFFER $TEST_DURATION $ROUNDS ../logs/n_64.log

# get averages

echo "n = 1"
throughout_avg=$(cat ../logs/n_1.log | grep "tx/s" | awk '{print $3}' | python get_average.py)
latency_avg=$(cat ../logs/n_1.log | grep "latency" | awk '{print $5}' | python get_average.py)
echo "1 $throughout_avg" >> data/throughput.dat
echo "1 $latency_avg" >> data/latency.dat

echo "n = 2"
throughout_avg=$(cat ../logs/n_2.log | grep "tx/s" | awk '{print $3}' | python get_average.py)
latency_avg=$(cat ../logs/n_2.log | grep "latency" | awk '{print $5}' | python get_average.py)
echo "2 $throughout_avg" >> data/throughput.dat
echo "2 $latency_avg" >> data/latency.dat

echo "n = 4"
throughout_avg=$(cat ../logs/n_4.log | grep "tx/s" | awk '{print $3}' | python get_average.py)
latency_avg=$(cat ../logs/n_4.log | grep "latency" | awk '{print $5}' | python get_average.py)
echo "4 $throughout_avg" >> data/throughput.dat
echo "4 $latency_avg" >> data/latency.dat

echo "n = 8"
throughout_avg=$(cat ../logs/n_8.log | grep "tx/s" | awk '{print $3}' | python get_average.py)
latency_avg=$(cat ../logs/n_8.log | grep "latency" | awk '{print $5}' | python get_average.py)
echo "8 $throughout_avg" >> data/throughput.dat
echo "8 $latency_avg" >> data/latency.dat

echo "n = 16"
throughout_avg=$(cat ../logs/n_16.log | grep "tx/s" | awk '{print $3}' | python get_average.py)
latency_avg=$(cat ../logs/n_16.log | grep "latency" | awk '{print $5}' | python get_average.py)
echo "16 $throughout_avg" >> data/throughput.dat
echo "16 $latency_avg" >> data/latency.dat

echo "n = 32"
throughout_avg=$(cat ../logs/n_32.log | grep "tx/s" | awk '{print $3}' | python get_average.py)
latency_avg=$(cat ../logs/n_32.log | grep "latency" | awk '{print $5}' | python get_average.py)
echo "32 $throughout_avg" >> data/throughput.dat
echo "32 $latency_avg" >> data/latency.dat

echo "n = 64"
throughout_avg=$(cat ../logs/n_64.log | grep "tx/s" | awk '{print $3}' | python get_average.py)
latency_avg=$(cat ../logs/n_64.log | grep "latency" | awk '{print $5}' | python get_average.py)
echo "64 $throughout_avg" >> data/throughput.dat
echo "64 $latency_avg" >> data/latency.dat
