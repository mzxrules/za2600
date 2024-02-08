#!/usr/bin/env python3

def ToAsm(data, n=16):
    result = ""
    cur = 0
    while cur < len(data):
        b = []
        for i in data[cur:cur+n]:
            b.append('${:02X}'.format(int(i)))
        result += "    .byte " + ", ".join(b) + "\n"
        cur += n
    return result

def ToAsm2(data, n=16):
    result = ""
    cur = 0
    while cur < len(data):
        b = []
        for i in data[cur:cur+n]:
            b.append(i)
        result += "    .byte " + ", ".join(b) + "\n"
        cur += n
    return result

def ToAsmD(data, n=16):
    result = ""
    cur = 0
    while cur < len(data):
        b = []
        for i in data[cur:cur+n]:
            temp = f'#{int(i):d}'
            b.append(f'{temp:>4}')
        result += "    .byte " + ", ".join(b) + "\n"
        cur += n
    return result

def ToAsmLabel(data, n=16):
    result = ""
    cur = 0
    while cur < len(data):
        b = data[cur:cur+n]
        result += f"    /* {cur:02X} */ .byte {', '.join(b)}\n"
        cur += n
    return result