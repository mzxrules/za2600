#!/usr/bin/env python3

files = [
    "w1_t.bin",
    "w1co_t.bin",
    "w1door_t.bin"
]

def reorder(data, size=1):
    result = []
    empty = bytes([0] * (8*size))
    for i in range(8):
        l = data[i*(8*size):(i+1)*(8*size)]
        result += l + empty
    return bytes(result)
    
dat = []
for i in range(3):
    with open(files[i], "rb") as file:
        dat.append(file.read())
    
with open("w1.bin", "wb") as file:
    file.write(reorder(dat[0], 3))
    
with open("w1co.bin", "wb") as file:
    file.write(reorder(dat[1]))
    
with open("w1door.bin", "wb") as file:
    file.write(reorder(dat[2]))