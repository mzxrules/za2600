#!/usr/bin/env python3
from asmgen import ToAsm, ToAsmD

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

bitcountOut = ToAsm(table)


roomHeight = []
roomHeight8 = []


ROOM_PX_HEIGHT = 20

for i in range(ROOM_PX_HEIGHT):
    c = i + 1
    rh = c*8 // 2 - 1
    roomHeight.append(rh)
    roomHeight8.append(rh+8)

roomHeight = ToAsmD(roomHeight)
roomHeight8 = ToAsmD(roomHeight8)

table = []

with open(f'gen/bitcount.asm', "w") as file:
    file.write(bitcountOut)

with open(f'gen/roomheight8.asm', 'w') as file:
    file.write("; RoomHeight\n")
    file.write(roomHeight)
    file.write("; RoomHeight8\n")
    file.write(roomHeight8)