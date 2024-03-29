#!/usr/bin/env python

from __future__ import division

import zmq
import sys
import time
from timeit import default_timer as timer
from signal import signal, SIGTERM

id = sys.argv[1]
log_file = sys.argv[2]
time_interval = int(sys.argv[3])
port = sys.argv[4]
buffer = int(sys.argv[5])

def exit_handler(*args):
    if counter:
        with open(log_file, 'a') as f:
            f.write(str(counter/time_interval) + ' ' + str(latency*1000/counter) + '\n')
    sys.exit(0)

signal(SIGTERM, exit_handler)

context = zmq.Context()
socket = context.socket(zmq.PAIR)
socket.bind("tcp://192.168.100.4:%s" % port)

counter = 0
latency = 0

print "listening on port", port

if id == "1":
    socket.recv()
    counter += 1
    while True:
        start = timer()
        socket.recv()
        end = timer()
        latency += (end - start) #sec
        counter += buffer
else:
    while True:
        socket.recv()
