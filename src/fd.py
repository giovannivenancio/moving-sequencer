#!/usr/bin/env python

import sys
import time
import zmq
import threading
import os
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
        self._seq_addr = {}
        self._counter = 0

        self._cpu_threshold = 95

        perf_thread = threading.Thread(target=self.performance_monitoring)
        perf_thread.start()

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
            self._seq_addr[pid] = ip
        elif action == 'remove':
            del self._sequencers[pid]
            del self._seq_addr[pid]
            del performance_metrics[ip]

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

    def ping(self, ip):
        """Test if node server is up and running."""

        return not os.system("ping -q -c 1 -W 2 %s > /dev/null 2>&1" % ip)

    def performance_monitoring(self):
        """Collect metrics from the sequencer pool."""

        global performance_metrics

        while True:
            performance_metrics = {}
            with open('metrics.log', 'r') as f_cpu:
                cpu_usage_values = f_cpu.readlines()[-1].replace('\n', '').split(';')[:-1]
                for value in cpu_usage_values:
                    if value:
                        ip, cpu_usage = value.split(' ')
                        performance_metrics[ip] = float(cpu_usage.strip('%'))
            time.sleep(1)

    def mainloop(self):
        """Periodically monitors the sequencer pool.
        If a node is faulty or has exceeded CPU usage, choose another node.
        """

        # initialize sequencer role with pid 0
        pid = "0"
        print "sending token to %s" % pid
        self.update_token(pid, self._counter)

        # monitors sequencer node
        while True:
            print performance_metrics

            faulty = False
            node_ip = self._seq_addr[pid]

            # node has crashed
            if not self.ping(node_ip):
                print "removing %s from metrics and sequencer list" % node_ip
                self.update_sequencers(str(pid), node_ip, None, 'remove')
                faulty = True

            if faulty or performance_metrics[node_ip] > self._cpu_threshold:
                print "releasing node %s" % pid

                # release node from sequencer role
                if faulty:
                    self._counter = 0
                else:
                    self._counter = self.revoke(pid)

                # choose another node
                pid = self._seq_addr.keys()[self._seq_addr.values().index(min(performance_metrics, key=performance_metrics.get))]
                print "sending token to %s" % pid
                self.update_token(pid, self._counter)

            time.sleep(1)

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print "Usage: python %s ip_sec1:port1 ip_sec2:port2 ..." % sys.argv[0]
        exit(1)

    os.system('sudo ./collector.sh &')
    time.sleep(10)

    sequencers = sys.argv[1:]
    fd = FailureDetector(sequencers)
    fd.mainloop()
