import sys
import ast

dat_file = sys.argv[1]

with open(dat_file, 'r') as f:
    data = ast.literal_eval(f.read())

for i, j in data.items():
    print i, j
