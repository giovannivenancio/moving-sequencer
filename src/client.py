#!/usr/bin/env python

import zmq
import sys
import time

batch_size = int(sys.argv[1])
sequencer = sys.argv[2]
# sequencers = sys.argv[2:]

context = zmq.Context()

socket = context.socket(zmq.PAIR)
socket.connect("tcp://%s" % sequencer)

conns = []
# for seq in sequencers:
#     socket = context.socket(zmq.PAIR)
#     socket.connect("tcp://%s" % seq)
#     conns.append(socket)

overhead = batch_size - 37
payload = "." * overhead

print "[sending requests with %s bytes]" % sys.getsizeof(payload)

while True:
    #for conn in conns:
    #    conn.send(payload)
    socket.send(payload)
