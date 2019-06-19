import sys

data_file = sys.argv[1]
THRESHOLD = 1000

data = []
with open(data_file, 'r') as f:
    for line in f.readlines():
        data.append(line.strip('\n').split(' '))

for i in range(len(data)):

    if i + 1 >= len(data):
        continue

    current_timestamp, current_tx = data[i]
    next_timestamp, next_tx = data[i+1]
    current_timestamp = int(current_timestamp)
    next_timestamp = int(next_timestamp)
    current_tx = int(current_tx)
    next_tx = int(next_tx)

    if current_tx >= next_tx:
        gap = current_tx - next_tx
    else:
        gap = next_tx - current_tx

    if gap >= THRESHOLD:
        overhead = gap/4
    else:
        overhead = 0

    #print current_tx, next_tx, gap, overhead

    if current_tx >= next_tx:
        data[i][1] = str(current_tx - overhead)
        data[i+1][1] = str(next_tx + overhead)
    else:
        data[i][1] = str(current_tx + overhead)
        data[i+1][1] = str(next_tx - overhead)

for d in data:
    print ' '.join(d)
