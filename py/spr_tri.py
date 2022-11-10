#!/usr/bin/env python3

from asmgen import ToAsm

sprite_tri_32_grid = [
    0b00000000, 0b00000001, 0b11000000, 0b00000000,
    0b00000000, 0b00000010, 0b10100000, 0b00000000,
    0b00000000, 0b00000100, 0b10010000, 0b00000000,
    0b00000000, 0b00001000, 0b10001000, 0b00000000,
    0b00000000, 0b00010000, 0b10000100, 0b00000000,
    0b00000000, 0b00100000, 0b10000010, 0b00000000,
    0b00000000, 0b01000000, 0b10000001, 0b00000000,
    0b00000000, 0b11111111, 0b11111111, 0b10000000,

    0b00000001, 0b11000000, 0b10000001, 0b11000000,
    0b00000010, 0b10100000, 0b10000010, 0b10100000,
    0b00000100, 0b10010000, 0b10000100, 0b10010000,
    0b00001000, 0b10001000, 0b10001000, 0b10001000,
    0b00010000, 0b10000100, 0b10010000, 0b10000100,
    0b00100000, 0b10000010, 0b10100000, 0b10000010,
    0b01000000, 0b10000001, 0b11000000, 0b10000001,
    0b11111111, 0b11111111, 0b11111111, 0b11111111,
]

# strips = [
#    sprite_tri_32_grid[0::4],
#    sprite_tri_32_grid[1::4],
#    sprite_tri_32_grid[2::4],
#    sprite_tri_32_grid[3::4],
#]

sprite_tri_sheet = [
    0b00000000,
    0b00000000,
    0b00000000,
    0b00000000,
    0b00000000,
    0b00000000,
    0b00000000,
    0b00000000,

# Empty BOTTOM LEFT
    0b00000001,
    0b00000010,
    0b00000100,
    0b00001000,
    0b00010000,
    0b00100000,
    0b01000000,
    0b11111111,

# Empty TOP MID
    0b10000000,
    0b01000000,
    0b00100000,
    0b00010000,
    0b00001000,
    0b00000100,
    0b00000010,
    0b00000001,

# Empty BOTTOM MID
    0b00000000,
    0b00000000,
    0b00000000,
    0b00000000,
    0b00000000,
    0b00000000,
    0b00000000,
    0b11111111,


# Fill BOTTOM LEFT
    0b00000001,
    0b00000011,
    0b00000111,
    0b00001111,
    0b00011111,
    0b00111111,
    0b01111111,
    0b11111111,

# Fill TOP MID
    0b10000000,
    0b11000000,
    0b11100000,
    0b11110000,
    0b11111000,
    0b11111100,
    0b11111110,
    0b11111111,

# Fill BOTTOM MID 1
    0b11111111,
    0b11111110,
    0b11111100,
    0b11111000,
    0b11110000,
    0b11100000,
    0b11000000,
    0b11111111,

# Fill BOTTOM MID 2
    0b00000001,
    0b00000011,
    0b00000111,
    0b00001111,
    0b00011111,
    0b00111111,
    0b01111111,
    0b11111111,

# Fill BOTTOM MID 3
    0b11111111,
    0b11111111,
    0b11111111,
    0b11111111,
    0b11111111,
    0b11111111,
    0b11111111,
    0b11111111,
]

TRI_EMPTY           = 0
TRI_EMPTY_BOT_LEFT  = 1
TRI_EMPTY_TOP_MID   = 2
TRI_EMPTY_BOT_MID   = 3
TRI_FILL_BOT_LEFT   = 4
TRI_FILL_TOP_MID    = 5
TRI_FILL_BOT_MID_1  = 6
TRI_FILL_BOT_MID_2  = 7
TRI_FILL_BOT_MID_3  = 8

def build_strip(spr_list):
    strip = []
    for spr in spr_list:
        strip += sprite_tri_sheet[spr*8:(spr+1)*8]
    return strip

strips = []
strips.append(build_strip([TRI_EMPTY, TRI_EMPTY_BOT_LEFT]))
strips.append(build_strip([TRI_EMPTY, TRI_FILL_BOT_LEFT]))

strips.append(build_strip([TRI_EMPTY_TOP_MID, TRI_EMPTY_BOT_MID]))
strips.append(build_strip([TRI_EMPTY_TOP_MID, TRI_FILL_BOT_MID_1]))
strips.append(build_strip([TRI_EMPTY_TOP_MID, TRI_FILL_BOT_MID_2]))
strips.append(build_strip([TRI_EMPTY_TOP_MID, TRI_FILL_BOT_MID_3]))

strips.append(build_strip([TRI_FILL_TOP_MID, TRI_EMPTY_BOT_MID]))
strips.append(build_strip([TRI_FILL_TOP_MID, TRI_FILL_BOT_MID_1]))
strips.append(build_strip([TRI_FILL_TOP_MID, TRI_FILL_BOT_MID_2]))
strips.append(build_strip([TRI_FILL_TOP_MID, TRI_FILL_BOT_MID_3]))


output = ""

for i, strip in enumerate(strips):
    strip.reverse()
    output += f"tri_{i}:\n"
    output += ToAsm(strip)

with open("gen/spr_tri.asm", "w") as file:
    file.write(output)