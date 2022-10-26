#!/usr/bin/env python3
from asmgen import ToAsm

table = []
for i in range(128):
    work = i
    count = 0
    while work != 0:
        if work & 1 == 1:
            count += 1
        work = work >> 1
        
    
    #print(f'{i:02X} {count}')
    table.append(count)

output = ToAsm(table)
    

with open(f'gen/bitcount.asm', "w") as file:
    file.write(output)