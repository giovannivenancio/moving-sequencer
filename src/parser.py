import os
import time

os.system('./collector.sh &')

performance_metrics = {}

while True:
    with open('metrics.log', 'r') as f_cpu:
        cpu_usage_values = f_cpu.readlines()[-1].replace('\n', '').split(';')[:-1]
        for value in cpu_usage_values:
            ip, cpu_usage = value.split(' ')
            performance_metrics[ip] = float(cpu_usage.strip('%'))

    print min(performance_metrics, key=performance_metrics.get)
    time.sleep(1)
