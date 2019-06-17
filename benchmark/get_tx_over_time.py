#!/usr/bin/env python

from __future__ import division

import sys

tx_aggregate = {}

for value in sys.stdin:
    timestamp, throughput = value.strip('\n').split(' ')
    timestamp = float(timestamp)
    throughput = int(throughput)

    if int(timestamp) == 0:
        continue

    tx_aggregate[int(timestamp)] = throughput

for i in range(1, tx_aggregate.keys()[-1]+1):
    # in case of failure throughput goes to zero
    if i not in tx_aggregate.keys():
        tx_aggregate[i] = 0

tx_over_time = {}
last_non_zero_aggregate = 0

for k in tx_aggregate:
    if k == 1:
        tx_over_time[k] = tx_aggregate[k]
    else:
        if tx_aggregate[k] == 0:
            tx_over_time[k] = 0
        elif tx_aggregate[k] != 0 and tx_aggregate[k-1] == 0:
            tx_over_time[k] = tx_aggregate[k] - last_non_zero_aggregate
        else:
            tx_over_time[k] = tx_aggregate[k] - tx_aggregate[k-1]

    if tx_aggregate[k] != 0:
        last_non_zero_aggregate = tx_aggregate[k]

print tx_over_time
