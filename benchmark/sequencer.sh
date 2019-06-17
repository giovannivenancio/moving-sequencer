#!/bin/bash

((!$#)) && { echo "Usage: $0 <num_sequencers> <num_replicas> <batch_size> <test_duration> <rounds>"; exit 1; }

NUM_SEQUENCERS=$1
NUM_REPLICAS=$2
BATCH_SIZE=$3
BUFFER=$4
TEST_DURATION=$5
ROUNDS=$6
LOG_FILE=../logs/$7

cd ../src

for num_exec in $(seq 1 $ROUNDS); do
    echo "killing processes"
    sudo pkill -f replica.py
    sudo pkill -f fd.py
    sudo pkill -f client.py
    sudo pkill -f sequencer.py

    echo "killing containers"
    docker kill $(docker ps -a | awk '{print $1}' | grep -v -i cont)

    echo "removing containers"
    docker rm $(docker ps -a | awk '{print $1}' | grep -v -i cont)

    rm metrics.log
    rm ../benchmark/replica.log

    repl_addresses=""
    repl_port=9001
    for repl in $(seq 1 $NUM_REPLICAS); do
        echo "starting replica on port $repl_port"
        python replica.py $repl ../benchmark/tx.log $TEST_DURATION $repl_port $BUFFER &
        repl_addresses="$repl_addresses 192.168.100.4:$repl_port "
        repl_port=$((repl_port+1))
    done

    docker_addresses=""
    cli_docker_addresses=""
    docker_host=2
    pid=0
    for seq_id in $(seq 0 $NUM_SEQUENCERS); do
        echo "starting sequencer with pid $pid"
        docker run -d -v /home/gvsouza/Projects/moving-sequencer:/moving-sequencer -it gvsouza/moving-sequencer /bin/bash -c "python /moving-sequencer/src/sequencer.py $pid $BUFFER $repl_addresses"
        # &> /moving-sequencer/output_$pid.log
        docker_addresses="$docker_addresses 172.17.0.$((docker_host+pid)):8000 "
        cli_docker_addresses="$cli_docker_addresses 172.17.0.$((docker_host+pid)):8002 "
        pid=$((pid+1))
    done

    echo "starting failure detector"
    sudo python fd.py $docker_addresses &

    sleep 10

    echo "snapshoting bandwidth"
    snap1=$(python -c "from utils import Performance; p = Performance(); print p.get_bandwidth_snapshot()")

    echo "starting client on $cli_docker_addresses"
    python client.py $BATCH_SIZE $cli_docker_addresses &
    #python client.py $BATCH_SIZE 172.17.0.2:8002 &
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
    echo "tx/s = "$(tail -n1 ../benchmark/tx.log | awk '{print $1}') >> $LOG_FILE
    echo "avg latency (msec) = "$(tail -n1 ../benchmark/tx.log | awk '{print $2}') >> $LOG_FILE

    if [ "$NUM_SEQUENCERS" -gt 0 ]; then
      echo "over time: "$(cat ../benchmark/replica.log | python ../benchmark/get_tx_over_time.py) >> $LOG_FILE
    fi

done

echo "exiting benchmark"
