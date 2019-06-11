#!/bin/bash

((!$#)) && { echo "Usage: $0 <num_replicas> <batch_size> <test_duration> <rounds>"; exit 1; }

NUM_REPLICAS=$1
BATCH_SIZE=$2
BUFFER=$3
TEST_DURATION=$4
ROUNDS=$5
LOG_FILE=$6

for num_exec in $(seq 1 $ROUNDS); do
    echo "killing processes"
    sudo pkill -f replica.py
    sudo pkill -f client.py

    repl_addresses=""
    repl_port=9001
    for repl in $(seq 1 $NUM_REPLICAS); do
        echo "starting replica on port $repl_port"
        python replica.py $repl tx.log $TEST_DURATION $repl_port $BUFFER &
        repl_addresses="$repl_addresses 192.168.100.4:$repl_port "
        repl_port=$((repl_port+1))
    done

    echo "snapshoting bandwidth"
    snap1=$(python -c "from utils import Performance; p = Performance(); print p.get_bandwidth_snapshot()")
    echo $snap1
    echo "starting client"
    python client.py $BATCH_SIZE $BUFFER $repl_addresses &
    echo "sleeping..."
    sleep $TEST_DURATION

    echo "terminating client"
    sudo pkill -f replica.py
    sudo pkill -f client.py
    sleep 5

    echo "snapshoting bandwidth"
    snap2=$(python -c "from utils import Performance; p = Performance(); print p.get_bandwidth_snapshot()")
    echo $snap2
    echo -e "evaluating\n"
    echo "Round $num_exec" >> $LOG_FILE
    python -c "from utils import Performance; p = Performance(); p.eval_bandwidth($snap1, $snap2, $TEST_DURATION, $NUM_REPLICAS)" >> $LOG_FILE
    echo "tx/s = "$(tail -n1 tx.log | awk '{print $1}') >> $LOG_FILE
    echo "avg latency (msec) = "$(tail -n1 tx.log | awk '{print $2}') >> $LOG_FILE
    echo -e "\n" >> $LOG_FILE

done

echo "exiting benchmark"
