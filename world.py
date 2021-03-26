#!/usr/bin/env python3
files = [
    'world/w{}.bin',
    'world/w{}co.bin',
    'world/w{}door.bin',
]

outfiles = [
    'world/w{}_w{}.asm',
    'world/w{}_w{}co.asm',
    'world/w{}_w{}do.asm',
]

mdata = []

def Clamp(v, s, l):
    return max(s, min(v,l))

def Interweave_DungData(dung1, dung2):
    result = []
    for i in range(8):
        result += dung1[i*8:(i+1)*8]
        result += dung2[i*8:(i+1)*8]
    return result
    
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
    for j in range(3):
        data = []
        with open(files[j].format(i), "rb") as file:
            data = file.read()
        level.append(data)
    mdata.append(level)    

for i in range(6):
    for j in range(3):
        a = Clamp((i) * 2-1, 0, 9)
        b = Clamp((i) * 2, 0, 9)
        outbin = []
        if i == 0:
            outbin = mdata[0][j]
        else:
            outbin = Interweave_DungData(mdata[a][j],mdata[b][j])
        
        
        with open(outfiles[j].format(a, b), "w") as file:
            file.write(ToAsm(outbin,16))
        
print("WORLD DATA REBUILT")