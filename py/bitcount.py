#!/usr/bin/env python3
from asmgen import ToAsm, ToAsmD
from dataclasses import dataclass, field
from typing import List, Tuple

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

@dataclass
class MapSpr:
    roomIdx: int
    checkVar: str
    x: int
    y: int
    isRoom : bool = False
    write: List[Tuple[int,int]] = field(default_factory=list) #memId, val

    def IsSingleWrite(self):
        return len(self.write) == 1

    def __str__(self):
        return f"ISROOM: {self.isRoom} ROOM {self.roomIdx}"

def get_pause_map_codegen():
    def init_room_spr(i, var, x, y):
        var = "PMapRoomVisit"
        spr = MapSpr(i, var, x, y, True)

        orBits = [0]*6

        for b in [*range(x, x-3, -1)]:
            orBits[5-(b//8)] |= 1 << (b%8)

        for j in range(6):
            if orBits[j] != 0:
                spr.write.append((j, orBits[j]))
        return spr

    def init_path_spr(i, var, x, y):
        memId = 5-(x // 8)
        val = 1 << (x % 8)
        spr = MapSpr(i, var, x, y, False)
        spr.write.append((memId, val))
        return spr


    mem_write = [[[] for i in range(6)] for j in range(5)]

    # model data
    for i in range(8):
        ri = 47 - 4 - i * 5
        room_spr = init_room_spr(i, "PMapRoomVisit", ri-1, 1)
        point_spr = [
            init_path_spr(i, "PMapRoomN", ri-2, 4),
            init_path_spr(i, "PMapRoomS", ri-2, 0),
            init_path_spr(i, "PMapRoomE", ri-4, 2),
            init_path_spr(i, "PMapRoomW", ri-0, 2),
            ]

        for spr in point_spr:
            for memId, _ in spr.write:
                mem_write[spr.y][memId].append(spr)
        do_append = True
        for memId, _ in room_spr.write:
            if do_append:
                mem_write[1][memId].append(room_spr)
                mem_write[2][memId].append(room_spr)
                do_append = False
            else:
                mem_write[1][memId].insert(0, room_spr)
                mem_write[2][memId].insert(0, room_spr)

    def gen_set_test(checkVar, val, label):
        return f'''
{label}: SUBROUTINE
    rol {checkVar}
    bcc .end
    ora #${val:02X}
.end'''
    def gen_set_test2(val):
        return f'''
    bcc .end2
    ora #${val:02X}
.end2'''
    def gen_writeback(memId, y):
        if y == 1:
            return f'''
    sta wMAP_{memId}+1,y
    sta wMAP_{memId}+3,y
'''
        else:
            return f'''
    sta wMAP_{memId}+{y},y
'''
    def gen_line(mem_write, y):
        src = ""
        curMemId = -1
        openBlock = False
        for elements in mem_write[y]:
            curMemId += 1
            if len(elements) < 1:
                continue
            src += '''
; -------
    lda #0'''
            for spr in elements:
                for memId, val in spr.write:
                    # src += f'; {spr.roomIdx}: {memId}, {openBlock}\n'
                    if memId < curMemId:
                        openBlock = True
                    elif memId == curMemId:
                        if openBlock:
                            src += gen_set_test2(val)
                            openBlock = False
                        else:
                            src += gen_set_test(spr.checkVar, val, f"{spr.checkVar}{spr.roomIdx}_{y}")
            src += gen_writeback(curMemId, y)
        return src
    gensource = gen_line(mem_write, 1)
    gensource += '''
    rol PMapRoomVisit
'''
    gensource += gen_line(mem_write, 2)
    gensource += gen_line(mem_write, 0)
    gensource += gen_line(mem_write, 4)
    gensource += '''
    rts'''
    with open(f'gen/pause_map.asm', "w") as file:
        file.write(gensource)

def get_pause_map_codegen_old():
    mem_dirty = [[False]*6 for i in range(5)]
    def gen_map_image_enable_room(memId, val):
        source = ""
        if mem_dirty[1][memId]:
            source += f'''
    lda rMAP_{memId}+1,y
    ora #${val:02X}'''
        else:
            mem_dirty[1][memId] = True
            mem_dirty[2][memId] = True
            mem_dirty[3][memId] = True
            source += f'''
    lda #${val:02X}'''
        source += f'''
    sta wMAP_{memId}+1,y
    sta wMAP_{memId}+2,y
    sta wMAP_{memId}+3,y
'''
        return source
    def gen_map_image_set_pix(x, y):
        source = ""
        memId = 5-(x // 8)
        val = 1 << (x % 8)

        if mem_dirty[y][memId]:
            source += f'''
    lda rMAP_{memId}+{y},y
    ora #${val:02X}'''
        else:
            mem_dirty[y][memId] = True
            source += f'''
    lda #${val:02X}'''

        return source + f'''
    sta wMAP_{memId}+{y},y
'''

    def gen_map_draw_room(i, bitNo):
        plotroom = "Pause_MapPlotRoom"
        source = f'''
{plotroom}{i}: SUBROUTINE
    rol PMapRoomVisit
    bcc .end
'''
        orBits = [0]*6
        for b in bitNo:
            orBits[5-(b//8)] |= 1 << (b%8)

        for j in range(6):
            if orBits[j] != 0:
                source += gen_map_image_enable_room(j, orBits[j])

        source += f".end"
        return source

    def gen_map_draw_path(i, label, var, x, y):
        source = f'''
{label}{i}: SUBROUTINE
    rol {var}
    bcc .end
'''
        source += gen_map_image_set_pix(x, y)
        source += ".end"
        return source

    gensource = ""


    # Plot Room
    for i in range(8):
        ri = 47 - 4 - i * 5
        bitNo = [*range(ri, ri-5, -1)]
        gensource += gen_map_draw_room(i, bitNo[1:4])
    # Plot Paths

    for i in range(8):
        ri = 47 -4 - i * 5
        bitNo = [*range(ri, ri-5, -1)]
        gensource += gen_map_draw_path(i, "Pause_MapPlotN", "PMapRoomN", bitNo[2], 4)
        gensource += gen_map_draw_path(i, "Pause_MapPlotS", "PMapRoomS", bitNo[2], 0)
        gensource += gen_map_draw_path(i, "Pause_MapPlotE", "PMapRoomE", bitNo[4], 2)
        gensource += gen_map_draw_path(i, "Pause_MapPlotW", "PMapRoomW", bitNo[0], 2)

    gensource += '''
    rts'''

    with open(f'gen/pause_map2.asm', "w") as file:
        file.write(gensource)


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
        file.write(ToAsm(lut,8))

def get_seek_lut():
    # Generates a next direction priority table that seeks out the target
    # 1xx Left/Right closest (1 Left, 0 Right)
    # x1x Up/Down closest    (1 Down, 0 Up)
    # xx1 Horizontal/Vertical axis closest (1 Y-Axis, 0 X-Axis)
    # Directions will be selected using the following priority system:
    # Closest Direction, Farthest Axis
    # Closest Direction, Closest Axis
    # Farthest Direction, Closest Axis
    # Farthest Direction, Farthest Axis

    xAxis = [EN_DIR_R, EN_DIR_L]
    yAxis = [EN_DIR_U, EN_DIR_D]
    map  = [xAxis, yAxis]
    CLOSE = 0
    FAR = 1
    pattern = [
        (CLOSE, FAR),
        (CLOSE, CLOSE),
        (FAR, CLOSE),
        (FAR, FAR) ]


    seek = []

    for i in range(8):
        axisClose = i & 1
        xAxisClose = 1 if (i & 4) > 0 else 0
        yAxisClose = 1 if (i & 2) > 0 else 0

        for dir, ax in pattern:
            a = axisClose if ax == CLOSE else 1 - axisClose
            b = xAxisClose if a == 0 else yAxisClose
            c = b if dir == CLOSE else 1 - b
            seek.append(map[a][c])
    with open(f'gen/seekdir.asm', "w") as file:
        file.write("seekdir_lut:\n")
        file.write(ToAsm(seek,4))

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

get_seek_lut()
get_hitbox_info()
get_hitbox_info2()
get_room_px_check()
get_randdir_lut()
get_pause_map_codegen()

with open(f'gen/bitcount.asm', "w") as file:
    file.write(bitcountOut)

with open(f'gen/roomheight8.asm', 'w') as file:
    file.write("; RoomHeight\n")
    file.write(roomHeight)
    file.write("; RoomHeight8\n")
    file.write(roomHeight8)