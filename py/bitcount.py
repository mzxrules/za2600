#!/usr/bin/env python3
from asmgen import ToAsm, ToAsmD

EN_DIR_L = 0
EN_DIR_R = 1
EN_DIR_U = 2
EN_DIR_D = 3

ROOM_PX_HEIGHT = 20

HITBOX_INFO = [
# width, height, x shift displacement
    (0, 0, 0),
# sword/arrow
    (8, 2, 0),
    (8, 2, 0),
    (2, 8, 0),
    (2, 8, 0),
# sword retract
    (4, 2, 0),
    (4, 2, 0),
    (2, 4, 0),
    (2, 4, 0),

    (4, 4, 0),
    (8, 8, 0),
]

HITBOX_INFO2 = [
# player shield hb
    (1, 8,  8,  0),
    (1, 8, -1,  0),
    (8, 1,  0, -1),
    (8, 1,  0,  8),
# player hitbox (missiles)
    (6, 6, 1, 1),
]

HITBOX_INFO_MISSILE = [
    (2, 2)
]

def get_hitbox_info():
    aa_ox = []
    aa_oy = []
    aa_w_PLUS_bb_w = []
    aa_h_PLUS_bb_h = []
    for aa_w, aa_h, xshift in HITBOX_INFO:
        bb_w = 8
        bb_h = 8

        aa_ox.append(aa_w-1+xshift-1)
        aa_oy.append(aa_h-1)
        aa_w_PLUS_bb_w.append(aa_w + bb_w -1)
        aa_h_PLUS_bb_h.append(aa_h + bb_h -1)

    with open(f'gen/hitbox_info.asm', "w") as file:
        file.write("hitbox_aa_ox:\n")
        file.write(ToAsm(aa_ox))
        file.write("hitbox_aa_oy:\n")
        file.write(ToAsm(aa_oy))
        file.write("hitbox_aa_w_plus_bb_w:\n")
        file.write(ToAsm(aa_w_PLUS_bb_w))
        file.write("hitbox_aa_h_plus_bb_h:\n")
        file.write(ToAsm(aa_h_PLUS_bb_h))

def get_hitbox_info2():
    aa_ox = []
    aa_oy = []
    aa_w_PLUS_bb_w = []
    aa_h_PLUS_bb_h = []

    for bb_w, bb_h in HITBOX_INFO_MISSILE:
        for aa_w, aa_h, xshift, yshift in HITBOX_INFO2:

            aa_ox.append(aa_w-1+xshift)
            aa_oy.append(aa_h-1+yshift)
            aa_w_PLUS_bb_w.append(aa_w + bb_w -1)
            aa_h_PLUS_bb_h.append(aa_h + bb_h -1)

    with open(f'gen/hitbox_info2.asm', "w") as file:
        file.write("hitbox2_aa_ox:\n")
        file.write(ToAsm(aa_ox))
        file.write("hitbox2_aa_oy:\n")
        file.write(ToAsm(aa_oy))
        file.write("hitbox2_aa_w_plus_bb_w:\n")
        file.write(ToAsm(aa_w_PLUS_bb_w))
        file.write("hitbox2_aa_h_plus_bb_h:\n")
        file.write(ToAsm(aa_h_PLUS_bb_h))

def get_room_px_check():
    bitmask_pattern = [
        # PF1 left
        0xC0, 0x60, 0x30, 0x18,
        0x0C, 0x06, 0x03,

        0x01, # $20

        # PF2 left

              0x03, 0x06, 0x0C,
        0x18, 0x30, 0x60, 0xC0,

        0x80, #$40

        # PF2 right
        0xC0, 0x60, 0x30, 0x18,
        0x0C, 0x06, 0x03,

        0x01, #$60
        # PF1 right
              0x03, 0x06, 0x0C,
        0x18, 0x30, 0x60, 0xC0
    ]
    offset_pattern = [0] * 7 + [ROOM_PX_HEIGHT] * 17 + [ROOM_PX_HEIGHT * 2] * 7
    with open(f'gen/roomcollision.asm', "w") as file:
        file.write("room_col8_mask:\n")
        file.write(ToAsm(bitmask_pattern))
        file.write("room_col8_off:\n")
        file.write(ToAsm(offset_pattern))

def get_randdir_lut():
    # Generates a 24 byte LUT that functions as such:
    # xxx11 = First pick of 4 EN_DIR direction
    # xx1xx = Permutation pattern
    # 11xxx = index into permutation pattern
    lut = [0] * 24
    dir = [EN_DIR_L, EN_DIR_R, EN_DIR_U, EN_DIR_D]
    select = [
        [EN_DIR_R, EN_DIR_U, EN_DIR_D],
        [EN_DIR_L, EN_DIR_U, EN_DIR_D],
        [EN_DIR_L, EN_DIR_R, EN_DIR_D],
        [EN_DIR_L, EN_DIR_R, EN_DIR_U],
        ]
    permutations = [
    [0, 1, 2],
    #[1, 2, 0],
    #[2, 0, 1],

    [0, 2, 1],
    #[1, 0, 2],
    #[2, 1, 0]
    ]

    for j in range(0,2):
        perm = permutations[j]
        for i in range(0,4):
            possibleNext = select[i]
            for k in range(0,3):

                index = (k * 8) + (j * 4) + i

                lut[index] = possibleNext[perm[k]]
    with open(f'gen/nextdir.asm', "w") as file:
        file.write("nextdir_lut:\n")
        file.write(ToAsm(lut,4))


def get_bitcount():
    table = []
    for i in range(128):
        work = i
        count = 0
        while work != 0:
            if work & 1 == 1:
                count += 1
            work = work >> 1


        #print(f'{i:02X} {count}')
        table.append(count)
    return ToAsm(table)

def get_roomheight():
    roomHeight = []
    roomHeight8 = []

    ROOM_PX_HEIGHT = 20

    for i in range(ROOM_PX_HEIGHT):
        c = i + 1
        rh = c*8 // 2 - 1
        roomHeight.append(rh)
        roomHeight8.append(rh+8)

    return (ToAsmD(roomHeight), ToAsmD(roomHeight8))

bitcountOut = get_bitcount()
roomHeight, roomHeight8 = get_roomheight()

get_hitbox_info()
get_hitbox_info2()
get_room_px_check()
get_randdir_lut()

with open(f'gen/bitcount.asm', "w") as file:
    file.write(bitcountOut)

with open(f'gen/roomheight8.asm', 'w') as file:
    file.write("; RoomHeight\n")
    file.write(roomHeight)
    file.write("; RoomHeight8\n")
    file.write(roomHeight8)