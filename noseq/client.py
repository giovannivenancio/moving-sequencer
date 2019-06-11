#!/usr/bin/env python

import zmq
import sys
import time

batch_size = int(sys.argv[1])
buffer = int(sys.argv[2])
replicas = sys.argv[3:]

context = zmq.Context()

socket = context.socket(zmq.PAIR)

conns = []
for repl in replicas:
    socket = context.socket(zmq.PAIR)
    socket.connect("tcp://%s" % repl)
    conns.append(socket)

overhead = batch_size - 37
payload = "." * overhead

print "[sending requests with %s bytes]" % sys.getsizeof(payload)

while True:
    payload2 = ''
    for i in range(buffer):
        payload2 += payload

    for conn in conns:
        conn.send(payload2)

# while True:
#     for conn in conns:
#         conn.send(payload)
