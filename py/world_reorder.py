#!/usr/bin/env python3

files = [
    "world/w0door",
    "world/w1door",
    "world/w2door"
]

NSEW = [0, 1, 2, 3]

def reorder(data, size=1):
    result = []
    empty = bytes([0] * (8*size))
    for i in range(8):
        l = data[i*(8*size):(i+1)*(8*size)]
        result += l + empty
    return bytes(result)

def split_doors(data, path):
    result = [[],[],[],[]]
    for d in data:
        for i in range(4):
            result[i].append(d >> (i*2) & 3)

    for cardinal, l in zip(NSEW,result):
        with open(f"{path}{cardinal}.bin", "wb") as file:
            file.write(bytes(l))


for file_path in files:
    data = None
    with open(f'{file_path}.bin', "rb") as file:
        data = file.read()
    split_doors(data, file_path)
