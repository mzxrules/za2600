#!/usr/bin/env python3
from asmgen import *

files = [
    'world/w{}.bin',
    'world/w{}door.bin',
    'world/w{}co.bin',
    'world/w{}lock.bin',
]

outfiles = [
    None,
    None,
    'world/w{}_w{}co.asm',
    'world/w{}_w{}lock.asm',
]


mdata = []

bankworlds = [
    [0, 0, 1, 2],
    [3, 4, 5, 6],
    [7, 8, 9, 9] 
]

def Clamp(v, s, l):
    return max(s, min(v,l))

def Interweave_DungData(dung1, dung2, size=1):
    result = []
    for i in range(8):
        result += dung1[i*8*size:(i+1)*8*size]
        result += dung2[i*8*size:(i+1)*8*size]
    return result
    
def SortDungLockEvent(dung):
    lockRoomA = [0] * 16
    lockRoomB = [0] * 16
    lockMaskA = [0xFF] * 16
    lockMaskB = [0xFF] * 16
    
    for i in range(len(dung)//4):
        lockRoomA[i] = dung[i*4+0]
        lockRoomB[i] = dung[i*4+2]
        lockMaskA[i] = dung[i*4+1]
        lockMaskB[i] = dung[i*4+3]
        
    return lockRoomA + lockRoomB + lockMaskA + lockMaskB
    
def ConvertLockDataRoomIds(dung, lvl):
    for i in range(len(dung)):
        if i % 2 == 1:
            continue
        dung[i] = int(ConvertLocalToWorldRoomId(lvl, dung[i]))
    
def ConvertLocalToWorldRoomId(lvl, id):
    lock_flags_room_shift = [
        0x00,
        0x08,
        0x80,
        0x88
    ]
    if lvl == 0:
        return id
        
    return id//8 * 16 + (id % 8) + lock_flags_room_shift[(lvl + 2)%4]
    
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
    lvlsets = [(levels[0], levels[1]), (levels[2], levels[3])]
    
    for a, b in lvlsets:
        if a == 0:
            world += mdata[a][0]
            doors += mdata[a][1]
        else:
            world += Interweave_DungData(mdata[a][0], mdata[b][0], 3)
            doors += Interweave_DungData(mdata[a][1], mdata[b][1])
    
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
    with open("world/b{}world.asm".format(bankId), "w") as file:
        for i in range(3):
            file.write("; {}\n".format(names[i]))
            file.write(ToAsm(worldstrip[i],16))


for i in range(10):
    level = []
    for j in range(4):
        data = []
        with open(files[j].format(i), "rb") as file:
            data = list(file.read())
        if j == 3:
            ConvertLockDataRoomIds(data, i)
        level.append(data)
    mdata.append(level)    

for i in range(6):    
    a = Clamp((i) * 2-1, 0, 9)
    b = Clamp((i) * 2, 0, 9)
        
    # Room Colors
    if i == 0:
        outbin = mdata[0][2]
    else:
        outbin = Interweave_DungData(mdata[a][2],mdata[b][2])
    with open(outfiles[2].format(a, b), "w") as file:
        file.write(ToAsm(outbin,16))
        

for i in range(3):
    # Dungeon Rooms and Door Flags
    PackRoomAndDoorData(i+1, bankworlds[i])
    lvls = set(bankworlds[i])
        
    events = []
    for j in lvls:
        events += mdata[j][3]
    
    data = SortDungLockEvent(events)
    
    with open("world/b{}lock.asm".format(i+1), "w") as file:
        file.write(ToAsm(data,16))
    
print("WORLD DATA REBUILT")