#!/usr/bin/env python3
from color_atari_table import ATARI_COLOR_TABLE
from color_game_table import GAME_COLOR_TABLE, ROOM_COLOR_TABLE

ROOM_BGCOLOR_TABLE = [
    "COLOR_PF_BLACK",
    "COLOR_PF_GRAY_D",
    #"COLOR_PF_GRAY_L",
    "COLOR_PF_BLUE_D",

    "COLOR_PF_BLUE_L",
    #"COLOR_PF_WATER",
    "COLOR_PF_TEAL_D", #
    "COLOR_PF_PURPLE_D", #

    "COLOR_PF_PURPLE",
    #"COLOR_PF_GREEN",
    "COLOR_PF_TEAL_L", #
    #"COLOR_PF_CHOCOLATE",

    #"COLOR_PF_RED",
    "COLOR_PF_PATH",
    #"COLOR_PF_SACRED",
    #"COLOR_PF_WHITE"
]

def gen_color_lookups():
    output = ""
    # gen named color definitions
    output += '. "Named Colors"\n'
    output += f'set "COLOR_LEN" to {len(GAME_COLOR_TABLE)}\n'
    for i, kv in enumerate(GAME_COLOR_TABLE.items()):
        k, v = kv
        output += f'set "$color{i}" to "{k}"\n'
        output += f'set "{k}_0" to "(0x{v[0]:02X})"\n'
        output += f'set "{k}_1" to "(0x{v[1]:02X})"\n'
    output += '. "Room Color Table"\n'
    for i, v in enumerate(ROOM_COLOR_TABLE):
        output += f'set "$color_room_{i}" to "{v}"\n'
    return output

def gen_mzx_atari_color_ids():
    output = ""
    for i in range(128):
        output += f'set "zcol{i*2}" to {i}\n'
        output += f'set "zcol{i*2+1}" to {i}\n'
    return output

def print_color(name, c):
    v = round(c * 63 / 255)
    return f'set "{name}" to {v}\n'

def color_to_mzx(key):
    data = ATARI_COLOR_TABLE[key]
    reg = 1 if key == "pal" else 0

    output = ""
    for i, v in enumerate(data):
        n = f"zcol{i}"
        r, g, b = v
        output += print_color(f"{n}r{reg}", r)
        output += print_color(f"{n}g{reg}", g)
        output += print_color(f"{n}b{reg}", b)
    return output

def luminocity_a(rgb):
    r, g, b = rgb
    return 0.2126 * r + 0.7152 * g + 0.0722 * b

def color_distance(rgb1, rgb2):
    rmean = (rgb1[0] + rgb2[0]) / 2
    r = rgb1[0] - rgb2[0]
    g = rgb1[1] - rgb2[1]
    b = rgb1[2] - rgb2[2]
    return  (((512+rmean)*r*r)/256) + 4*g*g + (((767-rmean)*b*b)/256) ** 0.5

def color_test(palette):
    output = f"==========\n{palette} TEST\n==========\n"
    color_player = []
    color_en = []
    color_pf = []
    for k in GAME_COLOR_TABLE:
        if k.startswith("COLOR_PLAYER_"):
            color_player.append(k)

        elif k.startswith("COLOR_EN_"):
            color_en.append(k)

        elif k.startswith("COLOR_PF_"):
            color_pf.append(k)

    output += "PF vs Player\n"
    mtx = get_color_dist_matrix(palette, color_pf, color_player)
    output += print_color_dist_matrix(color_pf, color_player, mtx)

    mtx = get_luminocity_a_matrix(palette, color_pf, color_player)
    output += print_color_dist_matrix(color_pf, color_player, mtx)

    output += "En vs PF\n"
    mtx = get_color_dist_matrix(palette, color_en, color_pf)
    output += print_color_dist_matrix(color_en, color_pf, mtx)
    mtx = get_luminocity_a_matrix(palette, color_en, color_pf)
    output += print_color_dist_matrix(color_en, color_pf, mtx)

    output += "En vs Player\n"
    mtx = get_color_dist_matrix(palette, color_en, color_player)
    output += print_color_dist_matrix(color_en, color_player, mtx)
    mtx = get_luminocity_a_matrix(palette, color_en, color_player)
    output += print_color_dist_matrix(color_en, color_player, mtx)
    return output



def luminocity_delta_test(key):
    for k, v in GAME_COLOR_TABLE.items():
        if k in ROOM_COLOR_TABLE:
            continue
        if k == "COLOR_UNDEF":
            continue
        lumDelta = []

        color = ATARI_COLOR_TABLE[key][(v[0])//2]
        lum = luminocity_a(color)
        for bgColorKey in ROOM_COLOR_TABLE:
            #if bgColorKey not in ROOM_BGCOLOR_TABLE:
            #    lumDelta.append("  ---  ")
            #    continue
            vBg = GAME_COLOR_TABLE[bgColorKey]
            bgColor = ATARI_COLOR_TABLE[key][(vBg[0])//2]
            #bgLum = luminocity_a(bgColor)
            #lumDelta.append(f'{abs(bgLum - lum):>3.0f}')

            colorDist = color_distance(color, bgColor)
            if colorDist < 14000:
                lumDelta.append(f'{colorDist:>7.0f}')
            else:
                lumDelta.append("  ---  ")

        print(f"{k:<20} " + ", ".join(lumDelta))

def print_color_dist_matrix(rowList, columnList, mtx):
    output = ""
    maxRowStrLen = len(max(rowList, key=len))-8
    maxColStrLen = len(max(columnList, key=len))-8
    maxColStrLen = max(maxColStrLen, 7)

    columnRow = "".rjust(maxRowStrLen)
    columnFmt = f"{{:>{maxColStrLen}}}"
    columnRow += "".join([columnFmt.format(x[9:]) for x in columnList])
    output += columnRow + '\n'

    things = zip(rowList, mtx)
    for colorName, list in things:
        rowStr = f"{colorName[9:]}".ljust(maxRowStrLen)
        for item in list:
            cellStr = f"{item:7.0f}".rjust(maxColStrLen, " ") if item >= 0 else "---".rjust(maxColStrLen, " ")
            rowStr+= cellStr
        output += rowStr +'\n'

    return output

def get_color_dist_matrix(palette, rowList, columnList, threshold = 14000):
    i = 0 if palette == "ntsc" else 1
    colorDistMtx = []
    for name1 in rowList:
        colorDistList = []
        colorId1 = GAME_COLOR_TABLE[name1]
        color1 = ATARI_COLOR_TABLE[palette][(colorId1[i])//2]
        for name2 in columnList:
            colorId2 = GAME_COLOR_TABLE[name2]
            color2 = ATARI_COLOR_TABLE[palette][(colorId2[i])//2]
            colorDist = color_distance(color1, color2)
            colorDist = colorDist if colorDist < threshold else -1
            colorDistList.append(colorDist)
        colorDistMtx.append(colorDistList)
    return colorDistMtx


def get_luminocity_a_matrix(palette, rowList, columnList):
    i = 0 if palette == "ntsc" else 1
    resultMtx = []
    for name1 in rowList:
        resultList = []
        colorId1 = GAME_COLOR_TABLE[name1]
        color1 = ATARI_COLOR_TABLE[palette][(colorId1[i])//2]
        for name2 in columnList:
            colorId2 = GAME_COLOR_TABLE[name2]
            color2 = ATARI_COLOR_TABLE[palette][(colorId2[i])//2]

            lumDelta = abs(luminocity_a(color1) - luminocity_a(color2))

            resultList.append(lumDelta)
        resultMtx.append(resultList)
    return resultMtx

def luminocity_test():
    for k, (ntsc, pal) in GAME_COLOR_TABLE.items():
        nc = ATARI_COLOR_TABLE["ntsc"][ntsc//2]
        nl = luminocity_a(nc)
        pc = ATARI_COLOR_TABLE["pal"][pal//2]
        pl = luminocity_a(pc)
        k += ":"
        print(f"{k:<20} {nl:>3.0f}, {pl:>3.0f}")

# luminocity_test()

output = ''
output += color_test("ntsc")
output += '\n\n'
output += color_test("pal")
with open(f'gen/color_stats.txt', "w") as file:
    file.write(output)

#quit()

output = ""
output += gen_color_lookups()
output += color_to_mzx("ntsc")
output += color_to_mzx("pal")
# output += gen_mzx_atari_color_ids()
with open(f'gen/editor_color.txt', "w") as file:
    file.write(output)
