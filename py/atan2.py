#!/usr/bin/env python3
import math

WIDTH  = 8
HEIGHT = 8

CHECK_PERIOD = 180

computeDX = []
computeDY = []

testSet = set()

def TestIntChange(last, next):
    if int(last) != int(next):
        return "1"
    return "0"

def ExploreAngle():
    out = ""
    for radians in sorted(testSet):
        deg = math.degrees(radians)
        lastPosX = 0.5
        lastPosY = 0.5
        blitX = ""
        blitY = ""
        for i in range(0, CHECK_PERIOD):
            nextPosX = math.cos(radians) * (i+1) + 0.5
            nextPosY = math.sin(radians) * (i+1) + 0.5
            blitX += TestIntChange(lastPosX, nextPosX)
            blitY += TestIntChange(lastPosY, nextPosY)

            lastPosX = nextPosX
            lastPosY = nextPosY

        out += f";{deg:>6.3f}\n;{blitX}\n;{blitY}\n"
    return out

for y in range(WIDTH):
    for x in range(HEIGHT):
        if x == 0 and y == 0:
            # If x == 0, y 1
            radians = math.atan2(1,0)
        else:
            radians = math.atan2(y,x)
        testSet.add(radians)
        dx = math.cos(radians)*256
        dy = math.sin(radians)*256
        i = int(y * HEIGHT + x)
        computeDX.append((x, y, dx, i, radians))
        computeDY.append((x, y, dy, i, radians))


def GenAtan2Table(name, data):
    output = f'{name}:\n'
    for x, y, d, i, radians in data:
        deg = math.degrees(radians)
        trunc = ""
        if d > 255:
            d = 255
            trunc = " TRUNC"
        dStr = f'#{d:.0f}'
        output += f'    .byte {dStr:>4} ; ${i:02X}: y/x = {y:1d}/{x:1d}  {deg:>6.3f}{trunc}\n'
    return output

output = ""
output += GenAtan2Table("Atan2X", computeDX)
output += GenAtan2Table("Atan2Y", computeDY)
output += "; Atan2 Degrees\n"
# output += ExploreAngle()
# for item in sorted(testSet):
#    deg = math.degrees(item)
#    output += f';   {deg:>6.3f}\n'

with open(f'gen/atan2.asm', "w") as file:
    file.write(output)