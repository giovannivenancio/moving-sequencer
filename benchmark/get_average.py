#!/usr/bin/env python

from __future__ import division

import sys

values = [float(value.strip('\n')) for value in sys.stdin]
avg = sum(values)/len(values)
print avg
