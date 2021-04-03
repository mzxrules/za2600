#!/usr/bin/env python3
files = [
    'world/w{}.bin',
    'world/w{}co.bin',
    'world/w{}door.bin',
    'world/w{}lock.bin',
]

outfiles = [
    'world/w{}_w{}.asm',
    'world/w{}_w{}co.asm',
    'world/w{}_w{}do.asm',
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

def Interweave_DungData(dung1, dung2):
    result = []
    for i in range(8):
        result += dung2[i*8:(i+1)*8]
        result += dung1[i*8:(i+1)*8]
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
    
def ToAsm(data, n):
    result = ""
    for j in range(len(data)//n):
        b = []
        for i in range(n):
            b.append('${:02X}'.format(int(data[j*n+i])))
        result += "    .byte " + ", ".join(b) + "\n"
    return result

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
    for j in range(3):
        outbin = []
        if i == 0:
            outbin = mdata[0][j]
        else:
            outbin = Interweave_DungData(mdata[a][j],mdata[b][j])
        
        with open(outfiles[j].format(a, b), "w") as file:
            file.write(ToAsm(outbin,16))
        
    
        if j == 3:
            outbin = Interweave_DungLockData(mdata[a][j],mdata[b][j],a,b)

for i in range(3):
    lvls = set(bankworlds[i])
    events = []
    for j in lvls:
        events += mdata[j][3]
    
    data = SortDungLockEvent(events)
    
    with open("world/b{}lock.asm".format(i+1), "w") as file:
        file.write(ToAsm(data,16))
    
print("WORLD DATA REBUILT")