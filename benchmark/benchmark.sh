#!/bin/bash

((!$#)) && { echo "Usage: $0 <rounds> <test_duration>"; exit 1; }

ROUNDS=$1
TEST_DURATION=$2

BATCH_SIZE=512

# cleanup
rm -f ../logs/*
rm data/throughput.dat

# n = 1
sudo ./sequencer.sh 0 1 $BATCH_SIZE $TEST_DURATION $ROUNDS ../logs/n_1.log

# n = 2
sudo ./sequencer.sh 0 2 $BATCH_SIZE $TEST_DURATION $ROUNDS ../logs/n_2.log

# n = 4
sudo ./sequencer.sh 0 4 $BATCH_SIZE $TEST_DURATION $ROUNDS ../logs/n_4.log

# n = 8
sudo ./sequencer.sh 0 8 $BATCH_SIZE $TEST_DURATION $ROUNDS ../logs/n_8.log

# n = 16
sudo ./sequencer.sh 0 16 $BATCH_SIZE $TEST_DURATION $ROUNDS ../logs/n_16.log

# n = 32
sudo ./sequencer.sh 0 32 $BATCH_SIZE $TEST_DURATION $ROUNDS ../logs/n_32.log

# n = 64
sudo ./sequencer.sh 0 64 $BATCH_SIZE $TEST_DURATION $ROUNDS ../logs/n_64.log

# get averages

echo "n = 1"
avg=$(cat ../logs/n_1.log | grep "out_avg" | grep -v "per" | awk '{print $2}' | python get_average.py)
echo "1 $avg" >> data/throughput.dat

echo "n = 2"
avg=$(cat ../logs/n_2.log | grep "out_avg" | grep -v "per" | awk '{print $2}' | python get_average.py)
echo "2 $avg" >> data/throughput.dat

echo "n = 4"
avg=$(cat ../logs/n_4.log | grep "out_avg" | grep -v "per" | awk '{print $2}' | python get_average.py)
echo "4 $avg" >> data/throughput.dat

echo "n = 8"
avg=$(cat ../logs/n_8.log | grep "out_avg" | grep -v "per" | awk '{print $2}' | python get_average.py)
echo "8 $avg" >> data/throughput.dat

echo "n = 16"
avg=$(cat ../logs/n_16.log | grep "out_avg" | grep -v "per" | awk '{print $2}' | python get_average.py)
echo "16 $avg" >> data/throughput.dat

echo "n = 32"
avg=$(cat ../logs/n_32.log | grep "out_avg" | grep -v "per" | awk '{print $2}' | python get_average.py)
echo "32 $avg" >> data/throughput.dat

echo "n = 64"
avg=$(cat ../logs/n_64.log | grep "out_avg" | grep -v "per" | awk '{print $2}' | python get_average.py)
echo "64 $avg" >> data/throughput.dat
