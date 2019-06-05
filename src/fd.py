#!/usr/bin/env python

import sys
import time
import zmq
from utils import *

class FailureDetector():
    """
    Failure Detector (FD) class used to:
    (i) Detect node failures;
    (ii) Monitor sequencers resource usage;
    (iii) Choose which node has the sequencer role.
    """

    def __init__(self, sequencers):
        self._sequencers = {}
        self._counter = 0

        self._cpu_threshold = 30

        pid = 0
        for seq in sequencers:
            ip, port = seq.split(':')
            self.update_sequencers(str(pid), ip, port, 'add')
            pid += 1

    def update_sequencers(self, pid, ip, port, action):
        """Add or remove a sequencer from the sequencers list."""

        if action == 'add':
            print "connecting on ", pid, ip, port
            self._sequencers[pid] = create_conn('pair', 'client', ip, port)
        elif action == 'remove':
            del self._sequencers[pid]

    def choose_sequencer(self):
        """Based on resource usage or failure detection, choose
        a new node to receive the sequencer role."""

        pass

    def update_token(self, pid, counter):
        """Upon choosing a new sequencer node, send the token."""

        print pid, self._sequencers[pid]
        self._sequencers[pid].send('%s,%s' % (pid, str(counter)))
        self._sequencers[pid].recv()

    def revoke(self, pid):
        """Release a node from the sequencer role."""

        self._sequencers[pid].send('revoke')
        updated_counter = self._sequencers[pid].recv()
        return updated_counter

    def get_metrics(self):
        """Collect metrics from the sequencer pool."""

        pass

    def mainloop(self):
        """Periodically monitors the sequencer pool.
        If a node is faulty or has exceeded CPU usage, choose another node.
        """

        while True:
            # pid = choose sequencer
            pid = "0"
            print "sending token to %s" % pid
            self.update_token(pid, self._counter)
            time.sleep(100000000)
            #self._counter = self.revoke(pid)
            #time.sleep(3)

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print "Usage: python %s ip_sec1:port1 ip_sec2:port2 ..." % sys.argv[0]
        exit(1)

    sequencers = sys.argv[1:]
    print sequencers
    fd = FailureDetector(sequencers)
    fd.mainloop()
