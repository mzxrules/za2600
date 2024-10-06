#!/usr/bin/env python3
from asmgen import *
from color_game_table import ROOM_COLOR_TABLE

files = [
    'world/w{}door0.bin',
    'world/w{}door1.bin',
    'world/w{}door2.bin',
    'world/w{}door3.bin',
    'world/w{}.bin',
    'world/w{}co.bin',
    'world/w{}dark.bin',
]

WORLD_COUNT = 3

mdata = []

def GetDoorWallWorld(c):
    dw = [
        (0b00, 0b0),
        (0b00, 0b1),
        (0b01, 0b0),
        (0b01, 0b1),
        (0b10, 0b0),
        (0b10, 0b1),
        (0b11, 0b0),
        (0b11, 0b1),
    ]
    return dw[c & 7]

def GetDoorWallDung(c):
    d = c & 3
    w = 0
    if c >= 3:
        d = 3
    if c == 4:
        w = 0b10
    if c == 5:
        w = 0b11
    return d, w

def GetPackedDoorWallData(worldId, data):
    doors = []
    walls = []

    for value in zip(*data): # n, s, e, w
        door = 0
        wall = 0

        for i, c in enumerate(value):
            if worldId == 0:
                d, w = GetDoorWallWorld(c)
            else:
                d, w = GetDoorWallDung(c)
            door |= d << (i * 2)
            wall |= w << (i * 2)
        doors.append(door)
        walls.append(wall)
    return doors, walls

def PackRoomAndDoorData(worldId, level):
    def PackStep(room, doors, type):
        # Since playfield sprites are 16 bytes long, we store the middle two digits of the PF sprite address
        # We further optimize by swapping the two digits; this lets us use simple AND masks and ORs to
        # construct the final address
        # e.g. spr index 0x18 is addressed to 0xF180. If stored as 0x81 instead, the digits line up
        # 0xF0 00 = full address
        #   X1 8x = 0x81 in A reg, repeated to show what I mean.
        #
        # PF13L and PF1R reserve 5 bits, while PF2 reserve 6 bits, leaving 8 bits for the 1 byte "door" data
        # Chunking of the door byte is done in a way to minimize shifts
        roomMask = [0xF1, 0xF1, 0xF3] # PF1L, PF1R, PF2 final packed layout
        doorMask = [0x07, 0xE0, 0x18] # bits to extract from the "door" byte, mapped to PF1L, PF1R, PF2
        # pack    >> -1, >>  4, >>  1
        # extract >>  1, >> -4, >> -1
        doorRshift = [8-1, 8+4, 8+1]
        doors &= doorMask[type]
        doors <<= 8
        doors >>= doorRshift[type]
        room = ((room & 0x0F) << 4) + ((room & 0xF0) >> 4)
        room &= roomMask[type]
        return room | doors

    roomSpriteIdRaw = level[4]
    doors, walls = GetPackedDoorWallData(worldId, level[0:4])
    # stripify and reorder world data
    roomSpriteIds = [
        [],
        [],
        []
    ]
    for i in range(128):
        for j in range(3):
            roomSpriteIds[j].append(PackStep(roomSpriteIdRaw[i*3+j], doors[i], j))

    names = ["PF1L", "PF1R", "PF2"]
    with open(f"gen/world/b{worldId}world.asm", "w") as file:
        for i in range(3):
            file.write("; {}\n".format(names[i]))
            file.write(ToAsm(roomSpriteIds[i],16))
    with open(f"gen/world/b{worldId}wa.bin", "wb") as file:
        file.write(bytes(walls))


def GetPFColors(co):
    fg = ROOM_COLOR_TABLE[co % 16]
    bg = ROOM_COLOR_TABLE[co // 16]
    return (fg, bg)

def PackRoomColors(mdata):
    colorKey = { 0: GetPFColors(0),
                11: GetPFColors(11)}
    for worldId in range(WORLD_COUNT):
        level = mdata[worldId]
        for co in level[5]:
            if co == 0:
                continue
            if co not in colorKey:
                colorKey[co] = GetPFColors(co)
    coIndex = {}
    for (i, co) in enumerate(colorKey):
        coIndex[co] = i

    fgList = []
    bgList = []
    for fg, bg in colorKey.values():
        fgList.append(fg)
        bgList.append(bg)

    for worldId in range(WORLD_COUNT):
        data = [0] * 128
        level = mdata[worldId]
        for i,co in enumerate(level[5]):
            v = 0
            fg = colorKey[co][0]
            if worldId != 0:
                if fg == "COLOR_PF_WATER" or fg == "COLOR_PF_RED":
                    v = 0x80
            data[i] = v | coIndex[co] | (level[6][i] << 6)

        with open(f"gen/world/b{worldId}co.bin", "wb") as file:
            file.write(bytes(data))

    output = "WorldColorsFg:\n"
    output += ToAsmLabel(fgList, 1)
    output += "WorldColorsBg:\n"
    output += ToAsmLabel(bgList, 1)
    with open(f"gen/world/room_colors.asm", 'w') as file:
        file.write(output)


def ModelEncounterScript(worldId, encounterToRoom):
    encounterScript = ""
    with open(f'world/w{worldId}encounter.txt', 'r') as file:
        encounterScript = file.readlines()

    for line in encounterScript:
        room, encounterStr = line.split('>',2)
        encounterStr = encounterStr.strip()
        if encounterStr == "":
            encounterStr = "EN_NONE"
        encounterToken = tuple([x.strip() for x in encounterStr.split(',')])

        encounterToRoom.setdefault(encounterToken, [])
        encounterToRoom[encounterToken].append((worldId, int(room, 16)))

    return encounterToRoom


def BuildRoomEncounterTables(encounterToRoom):
    roomEN = [
        [0] * 128,
        [0] * 128,
        [0] * 128,
    ]
    encounterTableStr = "EnSysEncounterTable:\n"
    curEN = 0

    for k, rooms in encounterToRoom.items():
        encounterItems = []
        encounterSet = set()
        encounterFlag = "$00"
        for v in k:
            encounterSet.add(v)

        for worldId, room in rooms:
                roomEN[worldId][room] = curEN

        enCount = 0 if "EN_NONE" in k else len(k)

        if len(k) > 1 and len(encounterSet) == 1:
            # Compact encounter
            curEN += 2
            encounterFlag = "$80"
            encounterItems = list(encounterSet)
        else:
            curEN += len(k) + 1
            encounterItems = list(k)

        encounterTableStr += f"    .byte {encounterFlag} | {enCount}, "
        encounterTableStr += ", ".join(encounterItems)
        encounterTableStr += "\n"

    dispSize = f"WORLD ENCOUNTER SIZE = {curEN}"
    encounterTableStr = f'; {dispSize}\n{encounterTableStr}'
    print(dispSize)


    for worldId in range(WORLD_COUNT):
        with open(f"gen/world/b{worldId}en.bin", "wb") as file:
            file.write(bytes(roomEN[worldId]))

    with open(f"gen/EnSysEncounterTable.asm", "w") as file:
        file.write(encounterTableStr)


def GenerateEncounters():
    encounterToRoom = {}
    for worldId in range(WORLD_COUNT):
        ModelEncounterScript(worldId, encounterToRoom)

    BuildRoomEncounterTables(encounterToRoom)


def Main():
    for worldId in range(WORLD_COUNT):
        level = []
        for i, filename in enumerate(files):
            with open(filename.format(worldId), "rb") as file:
                level.append(list(file.read()))
        mdata.append(level)


    PackRoomAndDoorData(0, mdata[0])
    PackRoomAndDoorData(1, mdata[1])
    PackRoomAndDoorData(2, mdata[2])
    PackRoomColors(mdata)
    GenerateEncounters()

Main()

print("WORLD DATA REBUILT")