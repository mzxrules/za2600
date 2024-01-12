#!/usr/bin/env python3

# Generates Atari 2600 color tables for megazeux

# NTSC color RGB
ATARI_COLOR_TABLE = {
    "ntsc" : [
        (0,0,0),(64,64,64),(108,108,108),(144,144,144),(176,176,176),(200,200,200),(220,220,220),(236,236,236),
        (68,68,0),(100,100,16),(132,132,36),(160,160,52),(184,184,64),(208,208,80),(232,232,92),(252,252,104),
        (112,40,0),(132,68,20),(152,92,40),(172,120,60),(188,140,76),(204,160,92),(220,180,104),(236,200,120),
        (132,24,0),(152,52,24),(172,80,48),(192,104,72),(208,128,92),(224,148,112),(236,168,128),(252,188,148),
        (136,0,0),(156,32,32),(176,60,60),(192,88,88),(208,112,112),(224,136,136),(236,160,160),(252,180,180),
        (120,0,92),(140,32,116),(160,60,136),(176,88,156),(192,112,176),(208,132,192),(220,156,208),(236,176,224),
        (72,0,120),(96,32,144),(120,60,164),(140,88,184),(160,112,204),(180,132,220),(196,156,236),(212,176,252),
        (20,0,132),(48,32,152),(76,60,172),(104,88,192),(124,112,208),(148,136,224),(168,160,236),(188,180,252),
        (0,0,136),(28,32,156),(56,64,176),(80,92,192),(104,116,208),(124,140,224),(144,164,236),(164,184,252),
        (0,24,124),(28,56,144),(56,84,168),(80,112,188),(104,136,204),(124,156,220),(144,180,236),(164,200,252),
        (0,44,92),(28,76,120),(56,104,144),(80,132,172),(104,156,192),(124,180,212),(144,204,232),(164,224,252),
        (0,60,44),(28,92,72),(56,124,100),(80,156,128),(104,180,148),(124,208,172),(144,228,192),(164,252,212),
        (0,60,0),(32,92,32),(64,124,64),(92,156,92),(116,180,116),(140,208,140),(164,228,164),(184,252,184),
        (20,56,0),(52,92,28),(80,124,56),(108,152,80),(132,180,104),(156,204,124),(180,228,144),(200,252,164),
        (44,48,0),(76,80,28),(104,112,52),(132,140,76),(156,168,100),(180,192,120),(204,212,136),(224,236,156),
        (68,40,0),(100,72,24),(132,104,48),(160,132,68),(184,156,88),(208,180,108),(232,204,124),(252,224,140)
    ],
    "pal" : [
        (0x00,0x00,0x00), (0x1A,0x1A,0x1A), (0x39,0x39,0x39), (0x5B,0x5B,0x5B), (0x7E,0x7E,0x7E), (0xA2,0xA2,0xA2), (0xC7,0xC7,0xC7), (0xED,0xED,0xED),
        (0x00,0x00,0x00), (0x1A,0x1A,0x1A), (0x39,0x39,0x39), (0x5B,0x5B,0x5B), (0x7E,0x7E,0x7E), (0xA2,0xA2,0xA2), (0xC7,0xC7,0xC7), (0xED,0xED,0xED),
        (0x1E,0x00,0x00), (0x3F,0x1C,0x00), (0x63,0x3D,0x00), (0x88,0x60,0x00), (0xAD,0x83,0x00), (0xD2,0xA8,0x06), (0xF9,0xCD,0x26), (0xFE,0xF6,0x4A),
        (0x00,0x21,0x00), (0x00,0x46,0x00), (0x0D,0x6A,0x00), (0x2D,0x90,0x00), (0x4F,0xB5,0x00), (0x71,0xDA,0x06), (0x95,0xFE,0x26), (0xC0,0xFE,0x4D),
        (0x3A,0x00,0x00), (0x62,0x06,0x00), (0x88,0x25,0x00), (0xAD,0x45,0x00), (0xD2,0x67,0x1B), (0xF9,0x8B,0x3B), (0xFE,0xB0,0x5E), (0xFE,0xDB,0x87),
        (0x00,0x25,0x00), (0x00,0x4B,0x00), (0x00,0x72,0x00), (0x0D,0x96,0x00), (0x2C,0xBB,0x1C), (0x4E,0xE1,0x3D), (0x70,0xFE,0x5F), (0x9C,0xFE,0x8A),
        (0x47,0x00,0x00), (0x72,0x00,0x07), (0x97,0x0F,0x25), (0xBD,0x2E,0x45), (0xE3,0x4F,0x68), (0xFE,0x72,0x8B), (0xFE,0x98,0xB2), (0xFE,0xC2,0xDD),
        (0x00,0x21,0x00), (0x00,0x45,0x05), (0x00,0x6C,0x26), (0x00,0x90,0x46), (0x1C,0xB5,0x69), (0x3D,0xDB,0x8C), (0x5F,0xFE,0xB1), (0x88,0xFE,0xDD),
        (0x41,0x00,0x26), (0x6C,0x00,0x4F), (0x92,0x04,0x73), (0xB8,0x22,0x98), (0xDE,0x43,0xBD), (0xFE,0x65,0xE3), (0xFE,0x8A,0xFE), (0xFE,0xB6,0xFE),
        (0x00,0x11,0x2A), (0x00,0x34,0x4F), (0x00,0x59,0x75), (0x04,0x7C,0x9A), (0x22,0xA0,0xBF), (0x43,0xC5,0xE5), (0x65,0xEB,0xFE), (0x8C,0xFE,0xFE),
        (0x2A,0x00,0x65), (0x53,0x00,0x92), (0x78,0x04,0xB9), (0x9C,0x22,0xE0), (0xC2,0x42,0xFE), (0xE8,0x65,0xFE), (0xFE,0x8A,0xFE), (0xFE,0xB6,0xFE),
        (0x00,0x00,0x6B), (0x00,0x1F,0x94), (0x00,0x40,0xBC), (0x1D,0x62,0xE2), (0x3D,0x85,0xFE), (0x5F,0xA9,0xFE), (0x84,0xD1,0xFE), (0xAB,0xF9,0xFE),
        (0x08,0x00,0x8E), (0x2D,0x00,0xBC), (0x4E,0x10,0xE4), (0x71,0x2F,0xFE), (0x95,0x50,0xFE), (0xBB,0x75,0xFE), (0xE3,0x9B,0xFE), (0xFE,0xC2,0xFE),
        (0x00,0x00,0x90), (0x06,0x08,0xBD), (0x24,0x25,0xE4), (0x44,0x45,0xFE), (0x66,0x67,0xFE), (0x8B,0x8D,0xFE), (0xB2,0xB3,0xFE), (0xDA,0xDB,0xFE),
        (0x00,0x00,0x00), (0x1A,0x1A,0x1A), (0x39,0x39,0x39), (0x5B,0x5B,0x5B), (0x7E,0x7E,0x7E), (0xA2,0xA2,0xA2), (0xC7,0xC7,0xC7), (0xED,0xED,0xED),
        (0x00,0x00,0x00), (0x1A,0x1A,0x1A), (0x39,0x39,0x39), (0x5B,0x5B,0x5B), (0x7E,0x7E,0x7E), (0xA2,0xA2,0xA2), (0xC7,0xC7,0xC7), (0xED,0xED,0xED),
    ]
}

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
    "COLOR_PF_GREEN",
    "COLOR_PF_TEAL_L", #
    #"COLOR_PF_CHOCOLATE",

    #"COLOR_PF_RED",
    "COLOR_PF_PATH",
    #"COLOR_PF_SACRED",
    #"COLOR_PF_WHITE"
]

ROOM_COLOR_TABLE = [
    "COLOR_PF_BLACK",
    "COLOR_PF_GRAY_D",
    "COLOR_PF_GRAY_L",
    "COLOR_PF_BLUE_D",

    "COLOR_PF_BLUE_L",
    "COLOR_PF_WATER",
    "COLOR_PF_TEAL_D",
    "COLOR_PF_PURPLE_D",

    "COLOR_PF_PURPLE",
    "COLOR_PF_GREEN",
    "COLOR_PF_TEAL_L",
    "COLOR_PF_CHOCOLATE",

    "COLOR_PF_RED",
    "COLOR_PF_PATH",
    "COLOR_PF_SACRED",
    "COLOR_PF_WHITE"
]

GAME_COLOR_TABLE = {
    "COLOR_UNDEF":          (0x00,0x00),
    "COLOR_PLAYER_00":      (0xC6,0x58),
    "COLOR_PLAYER_01":      (0x0E,0x0E),
    "COLOR_PLAYER_02":      (0x46,0x66),

    "COLOR_EN_RED":         (0x42,0x64),
    "COLOR_EN_RED_L":       (0x4A,0x6A),
    "COLOR_EN_GREEN":       (0xDA,0x5C),
    "COLOR_EN_BLUE":        (0x74,0xB4),
    "COLOR_EN_BLUE_L":      (0x7C,0xBC),
    "COLOR_EN_YELLOW":      (0x24,0x24),
    "COLOR_EN_YELLOW_L":    (0x2A,0x2A),

    "COLOR_EN_ROK_BLUE":    (0x72,0xC4),
    "COLOR_EN_LIGHT_BLUE":  (0x88,0xD8), # Item
    "COLOR_EN_TRIFORCE":    (0x2A,0x2A),
    "COLOR_EN_BROWN":       (0xF0,0x22),

    "COLOR_PF_BLACK":       (0x00,0x00),
    "COLOR_PF_GRAY_D":      (0x02,0x06),
    "COLOR_PF_GRAY_L":      (0x06,0x0C),
    "COLOR_PF_WHITE":       (0x0E,0x0E),

    "COLOR_PF_PATH":        (0x3C,0x4C),
    "COLOR_PF_GREEN":       (0xD0,0x52),
    "COLOR_PF_RED":         (0x42,0x64),
    "COLOR_PF_CHOCOLATE":   (0xF0,0x22),
    "COLOR_PF_WATER":       (0xAE,0x9E),

    "COLOR_PF_BLUE_D":      (0x90,0xC0),
    "COLOR_PF_BLUE_L":      (0x86,0xD6), # World
    "COLOR_PF_PURPLE_D":    (0x60,0xA2),
    "COLOR_PF_PURPLE":      (0x64,0xA6),
    "COLOR_PF_TEAL_D":      (0xB0,0x72),
    "COLOR_PF_TEAL_L":      (0xB2,0x74),
    "COLOR_PF_SACRED":      (0x1E,0x2E), # No good PAL equivalent

    "COLOR_MINIMAP":        (0x84,0x08), # Different colors
    "COLOR_HEALTH":         (0x46,0x64)
}

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

def luminocity_delta_test(key):
    i = 0 if key == "ntsc" else 1
    for k, v in GAME_COLOR_TABLE.items():
        if k in ROOM_COLOR_TABLE:
            continue
        if k == "COLOR_UNDEF":
            continue
        lumDelta = []

        color = ATARI_COLOR_TABLE[key][(v[i])//2]
        lum = luminocity_a(color)
        for bgColorKey in ROOM_COLOR_TABLE:
            if bgColorKey not in ROOM_BGCOLOR_TABLE:
                lumDelta.append("---")
                continue
            vBg = GAME_COLOR_TABLE[bgColorKey]
            bgColor = ATARI_COLOR_TABLE[key][(vBg[i])//2]
            #bgLum = luminocity_a(bgColor)
            #lumDelta.append(f'{abs(bgLum - lum):>3.0f}')

            colorDist = color_distance(color, bgColor)
            lumDelta.append(f'{colorDist:>7.0f}')

        print(f"{k:<20} " + ", ".join(lumDelta))



def luminocity_test():
    for k, (ntsc, pal) in GAME_COLOR_TABLE.items():
        nc = ATARI_COLOR_TABLE["ntsc"][ntsc//2]
        nl = luminocity_a(nc)
        pc = ATARI_COLOR_TABLE["pal"][pal//2]
        pl = luminocity_a(pc)
        k += ":"
        print(f"{k:<20} {nl:>3.0f}, {pl:>3.0f}")

# luminocity_test()
# luminocity_delta_test("ntsc")
# quit()

output = ""
output += gen_color_lookups()
output += color_to_mzx("ntsc")
output += color_to_mzx("pal")
# output += gen_mzx_atari_color_ids()
with open(f'gen/editor_color.txt', "w") as file:
    file.write(output)
