#!/bin/bash

((!$#)) && { echo "Usage: $0 <num_sequencers> <num_replicas> <test_duration> <rounds>"; exit 1; }

NUM_SEQUENCERS=$1
NUM_REPLICAS=$2
BATCH_SIZE=$3
TEST_DURATION=$4
ROUNDS=$5
LOG_FILE=../logs/$6

cd ../src

for num_exec in $(seq 1 $ROUNDS); do
    echo "killing processes"
    sudo pkill -f replica.py
    sudo pkill -f fd.py
    sudo pkill -f client.py

    echo "killing containers"
    docker kill $(docker ps -a | awk '{print $1}' | grep -v -i cont)

    echo "removing containers"
    docker rm $(docker ps -a | awk '{print $1}' | grep -v -i cont)

    repl_addresses=""
    repl_port=9001
    for repl in $(seq 1 $NUM_REPLICAS); do
        echo "starting replica on port $repl_port"
        python replica.py $repl ../benchmark/tx.log $TEST_DURATION $repl_port &
        repl_addresses="$repl_addresses 192.168.100.4:$repl_port "
        repl_port=$((repl_port+1))
    done

    docker_addresses=""
    docker_host=2
    pid=0
    for seq_id in $(seq 0 $NUM_SEQUENCERS); do
        echo "starting sequencer with pid $pid"
        docker run -d -v /home/gvsouza/Desktop/moving-sequencer:/moving-sequencer -it gvsouza/moving-sequencer /bin/bash -c "python /moving-sequencer/src/sequencer.py $pid $repl_addresses"
        docker_addresses="$docker_addresses 172.17.0.$((docker_host+pid)):8000 "
        pid=$((pid+1))
    done

    echo "starting failure detector"
    python fd.py $docker_addresses &

    echo "snapshoting bandwidth"
    snap1=$(python -c "from utils import Performance; p = Performance(); print p.get_bandwidth_snapshot()")

    echo "starting client"
    #python client.py $docker_addresses &
    python client.py $BATCH_SIZE 172.17.0.2:8002 &
    echo "sleeping..."
    sleep $TEST_DURATION

    echo "terminating client"
    sudo pkill -f client.py
    sleep 5
    sudo ../benchmark/kill.sh

    echo "snapshoting bandwidth"
    snap2=$(python -c "from utils import Performance; p = Performance(); print p.get_bandwidth_snapshot()")

    echo -e "evaluating\n"
    echo "Round $num_exec" >> $LOG_FILE
    python -c "from utils import Performance; p = Performance(); p.eval_bandwidth($snap1, $snap2, $TEST_DURATION, $NUM_REPLICAS)" >> $LOG_FILE
    echo "tx/s = "$(tail -n1 ../benchmark/tx.log) >> $LOG_FILE
    echo -e "\n" >> $LOG_FILE

done

echo "exiting benchmark"
