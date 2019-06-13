#!/usr/bin/env python

import sys
import time
from multiprocessing import Process, Queue
from signal import signal, SIGTERM
from utils import *

class Sequencer():
    """
    Sequencer class used on moving sequencers.
    """

    def __init__(self, pid, buffer, replicas):
        self._pid = pid
        self._buffer = buffer
        self.replicas = replicas
        self.queue = Queue()

        self._fd_seq_ucast_port = '8000'      # Unicast port between FD and Sequencer
        self._client_seq_ucast_port = '8002'  # Unicast port between Client and Sequencer

        # FD <-> Sequencer
        self._fd_seq_ucast_conn = create_conn('pair', 'server', None, self._fd_seq_ucast_port)

    def _broadcast(self, pid, client_seq_ucast_port, buffer, replicas, counter, queue):
        """Creates a process with the sequencer role.
        Receives packets and broadcasts it to replicas."""

        def exit_handler(*args):
            # update sequencer counter
            queue.put(counter)

            # close remaining connections
            for conn in replica_conn:
                conn.close()
            client_conn.close()

            sys.exit(0)

        signal(SIGTERM, exit_handler)

        print "%s creating connections" % pid

        # Client <-> Sequencer
        client_conn = create_conn('pair', 'server', None, client_seq_ucast_port)

        # Sequencer <-> Replicas
        replica_conn = [create_conn('pair', 'client', repl.split(':')[0], repl.split(':')[1]) for repl in replicas]

        print "waiting to send"

        while True:
            d = ''

            for i in range(buffer):
                d += client_conn.recv()
                counter += 1

            for conn in replica_conn:
                conn.send(d)

        # while True:
        #     d = client_conn.recv()
        #     counter += 1
        #
        #     for conn in replica_conn:
        #         conn.send(d)

    def mainloop(self):
        """Node waits to receive the sequencer token from failure detector.

        Once it receives, create a 'broadcast process' which is used
        to receive packets and atomic broadcasts it to receivers.

        If another message is received from the failure detector, it means that
        the sequencer needs to release the token, terminate the broadcast process
        and sent the global updated counter to the FD."""

        while True:
            print "Node %s is waiting..." % self._pid
            request = self._fd_seq_ucast_conn.recv()
            self._fd_seq_ucast_conn.send("ACK")

            request = request.split(',')
            token = request[0]
            counter = int(request[1])

            # node has the sequencer role
            if token == self._pid:
                print "Node %s has the sequencer role." % self._pid

                #initialize broacasting process
                p_bcast = Process(
                    target=self._broadcast,
                    args=(
                        self._pid,
                        self._client_seq_ucast_port,
                        self._buffer,
                        self.replicas,
                        counter,
                        self.queue))
                p_bcast.start()

                # receive a request to give up on sequencer role
                self._fd_seq_ucast_conn.recv()
                print "FD has revoked node %s." % self._pid

                # kill broadcast process
                p_bcast.terminate()

                # update sequencer counter and send it to FD
                new_counter = self.queue.get()
                print "Updating counter: ", new_counter
                self._fd_seq_ucast_conn.send(str(new_counter))

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print "Usage: python %s <pid> <replica address 1> <replica address 2> ... <replica address N>" % sys.argv[0]
        exit(1)

    pid = sys.argv[1]
    buffer = int(sys.argv[2])

    seq = Sequencer(pid, buffer, sys.argv[3:])
    seq.mainloop()
