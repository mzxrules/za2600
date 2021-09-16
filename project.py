#!/usr/bin/env python3
import math

WIDTH  = 8
HEIGHT = 8

computeDX = []
computeDY = []

for x in range(WIDTH):
    for y in range(HEIGHT):
        if x == 0 and y == 0:
            # If x == 0, y 1
            computeDX.append((x, y, 0, 0))
            computeDY.append((x, y, 256, 0))
            continue
        radians = math.atan2(y,x)
        dx = math.cos(radians)*256
        dy = math.sin(radians)*256
        i = int(x * HEIGHT + y)
        computeDX.append((x, y, dy, i))
        computeDY.append((x, y, dx, i))


def GenAtan2Table(name, data):    
    output = f'{name}:\n'
    for x, y, d, i in data:
        trunc = ""
        if d > 255:
            d = 255
            trunc = " TRUNC"
        dStr = f'#{d:.0f}'
        output += f'    .byte {dStr:>4};    {i:2x} y/x {y:2d}, {x:2d}{trunc}\n'
    return output

output = ""
output += GenAtan2Table("Atan2X", computeDX)
output += GenAtan2Table("Atan2Y", computeDY)

with open(f'gen/atan2.asm', "w") as file:
    file.write(output)