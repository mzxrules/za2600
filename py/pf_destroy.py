#!/usr/bin/env python3
from func_common import ToSnakeCase

# Block PFRoom sprite is at offset (Y - 8) / 4
# PF1L is $04-$1C inclusive, msb is leftmost
# PF2  is $24-$5C inclusive, msb is rightmost
# PF1R is $64-$7C inclusive, mirror of PF1L

ROOM_PX_HEIGHT = 20
PF_OFF_LUT = {
    "PF1RoomL" : ROOM_PX_HEIGHT * 0,
    "PF2Room"  : ROOM_PX_HEIGHT * 1,
    "PF1RoomR" : ROOM_PX_HEIGHT * 2,
}

DESTROY_LOCATIONS = {}

# x, y, rs_binding, opened rs_Binding
bush_locations = [
    (0x34,0x28, None, None),
    (0x40,0x1C, "Rs_EntDungBushBlocked", "Rs_EntDungBush"),
    (0x40,0x2C, None, None),
    (0x58,0x20, None, None),
    (0x64,0x20, None, None),
    (0x64,0x38, None, None),
    ]

wall_locations = [
    (0x14,0x38, "Rs_EntCaveWallLeftBlocked",        "Rs_EntCaveWallLeft"),
    (0x40,0x38, "Rs_EntCaveWallCenterBlocked",      "Rs_EntCaveWallCenter"),
    (0x6C,0x38, "Rs_EntCaveWallRightBlocked",       "Rs_EntCaveWallRight"),
    (0x58,0x20, "Rs_EntDungSpectacleRockBlocked",   "Rs_EntDungSpectacleRock"),
]


def rs_to_rsinit(label:str):
    if label.startswith('Rs'):
        return f'RsInit{label[2:]}'

def get_pf_y_off(worldY):
    return (worldY // 4 - 2)

def get_pf_x(worldX):
    pf1L_mask_pattern = [
        0xC0, 0x60, 0x30, 0x18,
        0x0C, 0x06, 0x03,
    ]
    pf2_mask_pattern = [
        0x00000003, 0x06, 0x0C,
        0x18, 0x30, 0x60, 0xC0,

        0x80, #$40

        # PF2 right
        0xC0, 0x60, 0x30, 0x18,
        0x0C, 0x06, 0x03,
    ]
    pf1R_mask_pattern = [
        0x00000003, 0x06, 0x0C,
        0x18, 0x30, 0x60, 0xC0
    ]
    if (0x04 <= worldX <= 0x1C):
        return ("PF1RoomL", pf1L_mask_pattern[(worldX-0x04)//4])
    elif (0x24 <= worldX <= 0x5C):
        return ("PF2Room", pf2_mask_pattern[(worldX-0x24)//4])
    elif (0x64 <= worldX <= 0x7C):
        return ("PF1RoomR", pf1R_mask_pattern[(worldX-0x64)//4])
    return None

def get_ball_postXY(worldX, worldY):
    if ((0x24 <= worldX < 0x40) or (0x40 < worldX <= 0x5C)):
        return ((2 * 0x40 - worldX), worldY)
    return (0,0x80)

def can_be_predestroyed(worldX, worldY):
    if ((0x24 <= worldX < 0x40) or (0x40 < worldX <= 0x5C)):
        return False
    return True

def gen_pf_destroy(x, y, depth = 3):
    pfy = get_pf_y_off(y)
    pfVar, mask = get_pf_x(x)

    destroy_asm = ""
    for i in range(depth-1, 0-1, -1):
        destroy_asm += \
f'''PF_Destroy_P{x:02X}{y:02X}_{i+1}:
    lda r{pfVar} + {pfy+i}
    and #~${mask:02X}
    sta w{pfVar} + {pfy+i}
'''
    destroy_asm += '    rts\n\n'
    return destroy_asm

def set_destroy_location(x, y, depth):
    DESTROY_LOCATIONS.setdefault((x,y), 0)
    if DESTROY_LOCATIONS[(x,y)] < depth:
        DESTROY_LOCATIONS[(x,y)] = depth

def generate_ball_pos(x, y):
    output = ""
    if x is not None:
        output+= f'''
    lda #${x:02X}+1
    sta blX
'''.lstrip('\n')
    if y is not None:
        output+= f'''
    lda #${y:02X}
    sta blY
'''.lstrip('\n')
    return output

def generate_roomRS_swap(openedRS):
    if openedRS is not None:
        return f'''
    ldx #{ToSnakeCase(openedRS)}
    stx roomRS
'''.lstrip('\n')
    return ""

def generate_rsinit_bush_cave(v):
    x, y, blockedRS, openedRS = v
    return generate_opening(x, y, 2, False, blockedRS, openedRS, 'RsInit_Bush')

def generate_rsinit_wall_cave(v):
    x, y, blockedRS, openedRS = v
    preDestroy = can_be_predestroyed(x, y)
    return generate_opening(x, y, 3, preDestroy, blockedRS, openedRS, 'RsInit_Wall')


def generate_opening(x, y, depth, preDestroy, blockedRS, openedRS, label):
    plabel = f'P{x:02X}{y:02X}'
    output = f'''
{label}_{plabel}: SUBROUTINE
'''.lstrip('\n')
    if blockedRS is not None:
        output += f'''
{rs_to_rsinit(blockedRS)}
'''.lstrip('\n')
    # Ball initial position
    ax = x
    ay = y
    # Ball final position
    bx, by = get_ball_postXY(x, y)
    # Ball initial and final shared positions
    cx = None
    cy = None

    if by >= 0x70:
        bx = None
    if ay == by:
        cy = ay
        ay = None
        by = None

    destroy_jmp = f'jmp PF_Destroy_P{x:02X}{y:02X}_{depth}'

    cond_test = f'''
    ldy roomId
    lda rWorldRoomFlags,y
    and #WRF_SV_DESTROY
    bne {label}_Opened_{plabel}
'''.lstrip('\n')

    output += f'''
    lda #{depth*4-1}
    sta wBLH
{label}Test_{plabel}
'''.lstrip('\n')

##############################################
    if preDestroy:
##############################################
        output += ' ; Pre destroy\n'
        output += generate_ball_pos(cx, cy)
        output += cond_test
        output += generate_ball_pos(ax, ay)
        output += f'''
    {destroy_jmp}
{label}_Opened_{plabel}
'''.lstrip('\n')
        if openedRS is not None:
            output += f'''
{rs_to_rsinit(openedRS)}
'''.lstrip('\n')
        output += generate_ball_pos(bx, by)
        output += generate_roomRS_swap(openedRS)
        output += f'''
    {destroy_jmp}

'''.lstrip('\n')

##############################################
    else: # no preDestroy
##############################################
        output += ' ; No Pre destroy\n'
        output += generate_ball_pos(cx, cy)
        output += cond_test
        output += generate_ball_pos(ax, ay)
        output += f'''
    rts
{label}_Opened_{plabel}
'''.lstrip('\n')
        if openedRS is not None:
            output += f'''
{rs_to_rsinit(openedRS)}
'''.lstrip('\n')
        output += generate_ball_pos(bx, by)
        output += generate_roomRS_swap(openedRS)
        output += f'''
    {destroy_jmp}

'''.lstrip('\n')

##############################################
    return output


def main_func():
    for x,y,_,_ in bush_locations:
        set_destroy_location(x,y, 2)

    for x,y,_,_ in wall_locations:
        set_destroy_location(x,y, 3)

    output = ""
    for k, depth in DESTROY_LOCATIONS.items():
        x, y = k
        output += gen_pf_destroy(x,y, depth)

    for v in bush_locations:
        output += generate_rsinit_bush_cave(v)

    for v in wall_locations:
        output += generate_rsinit_wall_cave(v)

    with open(f'gen/pf_destroy.asm', "w") as file:
        file.write(output)

main_func()