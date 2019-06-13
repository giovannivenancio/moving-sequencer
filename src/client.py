#!/usr/bin/env python

import zmq
import sys
import time

batch_size = int(sys.argv[1])
#sequencer = sys.argv[2]
sequencers = sys.argv[2:]
print "cli: --> ", sequencers

context = zmq.Context()

#socket = context.socket(zmq.PAIR)
#socket.connect("tcp://%s" % sequencer)

conns = []
for seq in sequencers:
    print "creating connection with %s" % seq
    socket = context.socket(zmq.PAIR)
    socket.connect("tcp://%s" % seq)
    conns.append(socket)

overhead = batch_size - 37
payload = "." * overhead

print "[sending requests with %s bytes]" % sys.getsizeof(payload)

counter = 0
while True:
    for conn in conns:
        try:
            conn.send(payload, zmq.NOBLOCK)
        except:
            pass

    counter += 1
    # if counter % 200000 == 0:
    #     print "client:", counter
