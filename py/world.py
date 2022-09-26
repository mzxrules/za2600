#!/usr/bin/env python3
from asmgen import *

files = [
    'world/w{}door0.bin',
    'world/w{}door1.bin',
    'world/w{}door2.bin',
    'world/w{}door3.bin',
    'world/w{}.bin',
]

mdata = []

def GetDoorWallWorld(c):
    dw = [
        (0b00, 0b0),
        (0b00, 0b1),
        (0b01, 0b0),
        (0b01, 0b1),
        (0b10, 0b0),
        (0b10, 0b1),
        (0b11, 0b0),
        (0b11, 0b1),
    ]
    return dw[c & 7]

def GetDoorWallDung(c):
    d = c & 3
    w = 0
    if c >= 3:
        d = 3
    if c == 4:
        w = 0b10
    if c == 5:
        w = 0b11
    return d, w

def GetPackedDoorWallData(bankId, data):
    doors = []
    walls = []
    
    for value in zip(*data): # n, s, e, w
        door = 0
        wall = 0

        for i, c in enumerate(value):
            if bankId == 0:
                d, w = GetDoorWallWorld(c)
            else:
                d, w = GetDoorWallDung(c)
            door |= d << (i * 2)
            wall |= w << (i * 2)
        doors.append(door)
        walls.append(wall)
    return doors, walls

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
        
    world = level[4]
    doors, walls = GetPackedDoorWallData(bankId, level[0:4])
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
    with open(f"gen/world/b{bankId}world.asm", "w") as file:
        for i in range(3):
            file.write("; {}\n".format(names[i]))
            file.write(ToAsm(worldstrip[i],16))
    with open(f"gen/world/b{bankId}wa.bin", "wb") as file:
        file.write(bytes(walls))
def Main():
    for worldId in range(3):
        level = []
        for i, filename in enumerate(files):
            with open(filename.format(worldId), "rb") as file:
                level.append(list(file.read()))
        mdata.append(level)


    PackRoomAndDoorData(0, mdata[0])
    PackRoomAndDoorData(1, mdata[1])
    PackRoomAndDoorData(2, mdata[2])

Main()

print("WORLD DATA REBUILT")