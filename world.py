#!/usr/bin/env python3
from asmgen import *

files = [
    'world/w{}.bin',
    'world/w{}door.bin',
    'world/w{}co.bin'
]

mdata = []

def PackRoomAndDoorData(bankId, levels):
    def PackStep(room, doors, type):
        roomMask = [0xF1, 0xF1, 0xF3]
        doorMask = [0x07, 0xE0, 0x18]
        # pack    >> -1, >>  4, >>  1
        # extract >>  1, >> -4, >> -1
        doorRshift = [8-1, 8+4, 8+1]
        doors &= doorMask[type]
        doors <<= 8
        doors >>= doorRshift[type]
        room = ((room & 0x0F) << 4) + ((room & 0xF0) >> 4)
        room &= roomMask[type]
        return room | doors
        
    world = []
    doors = []
    lvlsets = [levels[0], levels[1]]
    
    for a in lvlsets:
            world += a[0]
            doors += a[1]
    
    # stripify and reorder world data
    worldstrip = [
        [],
        [],
        []
    ]
    for i in range(256):
        for j in range(3):
            worldstrip[j].append(PackStep(world[i*3+j], doors[i], j))
        
    names = ["PF1L", "PF1R", "PF2"]
    with open("gen/world/b{}world.asm".format(bankId), "w") as file:
        for i in range(3):
            file.write("; {}\n".format(names[i]))
            file.write(ToAsm(worldstrip[i],16))
         
for i in range(3):
    level = []
    for j in range(3):
        with open(files[j].format(i), "rb") as file:
            level.append(list(file.read()))
    mdata.append(level)    

lvldata =[
    (mdata[0], mdata[0]),
    (mdata[1], mdata[2])
]

PackRoomAndDoorData(1, lvldata[0])
PackRoomAndDoorData(2, lvldata[1])

print("WORLD DATA REBUILT")