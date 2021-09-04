#!/usr/bin/env python3
from asmgen import *

files = [
    'world/w{}.bin',
    'world/w{}door.bin',
    'world/w{}co.bin'
]

mdata = []

def PackRoomAndDoorData(bankId, level):
    def PackStep(room, doors, type):
        # Since playfield sprites are 16 bytes long, we store the middle two digits of the PF sprite address
        # We further optimize by swapping the two digits; this lets us use simple AND masks and ORs to
        # construct the final address
        # e.g. spr index 0x18 is addressed to 0xF180. If stored as 0x81 instead, the digits line up
        # 0xF0 00 = full address
        #   X1 8x = 0x81 in A reg, repeated to show what I mean.
        #
        # PF1L and PF1R reserve 5 bits, while PF2 reserve 6 bits, leaving 8 bits for the 1 byte "door" data
        # Chunking of the door byte is done in a way to minimize shifts
        roomMask = [0xF1, 0xF1, 0xF3] # PF1L, PF1R, PF2 final packed layout
        doorMask = [0x07, 0xE0, 0x18] # bits to extract from the "door" byte, mapped to PF1L, PF1R, PF2 
        # pack    >> -1, >>  4, >>  1
        # extract >>  1, >> -4, >> -1
        doorRshift = [8-1, 8+4, 8+1] 
        doors &= doorMask[type]
        doors <<= 8
        doors >>= doorRshift[type]
        room = ((room & 0x0F) << 4) + ((room & 0xF0) >> 4)
        room &= roomMask[type]
        return room | doors
        
    world = level[0]
    doors = level[1]
    
    # stripify and reorder world data
    worldstrip = [
        [],
        [],
        []
    ]
    for i in range(128):
        for j in range(3):
            worldstrip[j].append(PackStep(world[i*3+j], doors[i], j))
        
    names = ["PF1L", "PF1R", "PF2"]
    with open("gen/world/b{}world.asm".format(bankId), "w") as file:
        for i in range(3):
            file.write("; {}\n".format(names[i]))
            file.write(ToAsm(worldstrip[i],16))

for worldId in range(3):
    level = []
    for i in range(3):
        with open(files[i].format(worldId), "rb") as file:
            level.append(list(file.read()))
    mdata.append(level)    


PackRoomAndDoorData(0, mdata[0])
PackRoomAndDoorData(1, mdata[1])
PackRoomAndDoorData(2, mdata[2])

print("WORLD DATA REBUILT")