#!/usr/bin/env python3
import re
from mesg import *
from dataclasses import dataclass, field

def ToAsm(data, n=16):
    result = ""
    cur = 0
    while cur < len(data):
        b = []
        for i in data[cur:cur+n]:
            b.append(i)
        result += "    .byte " + ", ".join(b) + "\n"
        cur += n
    return result

@dataclass
class GameEnum:
    name: str
    shortName: str
    genEditorBindings: bool
    genPtrTable: bool
    genConstants: bool
    vals: list = field(default_factory=list)

    def __post_init__(self):
        if self.shortName == None:
            shortName = name

    def EnumFunc(self, x):
        if self.name == "Sfx":
            return 0x81 + x
        return x

Entity_Table = [
    "EnNone",          "EnDraw_None",
    "EnClearDrop",     "EnDraw_ClearDrop",
    "EnItem",          "EnDraw_None",
    "EnStairs",        "EnDraw_None",
    "EnShopkeeper",    "EnDraw_Shopkeeper",
    "EnNpcGiveOne",    "EnDraw_NpcGiveOne",
    "En_ItemGet",      "EnDraw_ItemGet",
    "En_OldMan",       "EnDraw_OldMan",

    "En_Darknut",      "EnDraw_Darknut",
    "En_DarknutMain",  "EnDraw_Darknut",
    "En_LikeLike",     "EnDraw_LikeLike",
    "En_LikeLikeMain", "EnDraw_LikeLike",
    "En_Octorok",      "EnDraw_Octorok",
    "En_OctorokMain",  "EnDraw_Octorok",
    "En_Rope",         "EnDraw_Rope",
    "En_RopeMain",     "EnDraw_Rope",
    "En_Wallmaster",   "EnDraw_Wallmaster",

    "EnBoss_Cucco",    "EnDraw_None"
]

RoomScript_Table = [
    "Rs_None",                "RsInit_None",
    "Rs_BlockCentral",        "RsInit_BlockCentral",
    "Rs_BlockDiamondStairs",  "RsInit_BlockDiamondStairs",
    "Rs_EntCaveLeft",         "RsInit_None",
    "Rs_EntCaveLeftBlocked",  "RsInit_EntCaveLeftBlocked",
    "Rs_EntCaveRight",        "RsInit_None",
    "Rs_EntCaveRightBlocked", "RsInit_EntCaveRightBlocked",
    "Rs_EntCaveMid",          "RsInit_None",
    "Rs_EntDungMid",          "RsInit_None",
    "Rs_ExitDung",            "RsInit_None",
    "Rs_ExitDung2",           "RsInit_None",
    "Rs_FairyFountain",       "RsInit_None",
    "Rs_Item",                "RsInit_None",
    "Rs_Maze",                "RsInit_None",
    "Rs_Npc",                 "RsInit_None",
    "Rs_NpcTriforce",         "RsInit_None",
    "Rs_RaftSpot",            "RsInit_None",
    "Rs_ShoreItem",           "RsInit_None",
    "Rs_Stairs",              "RsInit_None",
    "Rs_Cave",                "RsInit_None",
    "Rs_GameOver",            "RsInit_None",
]

tbl = [
    GameEnum("Entity", "En",
    genEditorBindings=False,
    genPtrTable=True,
    genConstants=True,
    vals=Entity_Table[0::2]),
    GameEnum("EntityDraw", "EnDraw",
    genEditorBindings=False,
    genPtrTable=True,
    genConstants=False,
    vals=Entity_Table[1::2]),
    GameEnum("RoomScript", "Rs",
    genEditorBindings=True,
    genPtrTable=True,
    genConstants=True,
    vals=RoomScript_Table[0::2]),
    GameEnum("RoomScriptInit", "RsInit",
    genEditorBindings=False,
    genPtrTable=True,
    genConstants=False,
    vals=RoomScript_Table[1::2]),
    GameEnum("Ball", "Bl",
    genEditorBindings=False,
    genPtrTable=True,
    genConstants=True,
    vals=[
        "BlNone",
        # Ball movement ids must be 1-4
        "BlR",
        "BlL",
        "BlD",
        "BlU",
        "BlPushBlock",
        "BlDiamondPushBlock",
    ]
    ),
    GameEnum("ItemId", "Gi",
    genEditorBindings=True,
    genPtrTable=True,
    genConstants=True,
    vals=[
        "GiNone",
        "GiRecoverHeart",
        "GiFairy",
        "GiBomb",

        "GiRupee",
        "GiRupee5",
        "GiTriforce",
        "GiHeart",
# above items have hardcoded ordering, and flash blue
        "GiKey",
        "GiMasterKey",

        "GiShield",
        "GiSword1",
        "GiSword2",
        "GiSword3",

        "GiBow",
        "GiRaft",
        "GiBoots",
        "GiFlute",

        "GiFireMagic",
        "GiBracelet",
        "GiRingBlue",
        "GiRingRed",

        "GiArrow",
        "GiArrowSilver",
        "GiCandleBlue",
        "GiCandleRed",

        "GiMeat",
        "GiNote",
        "GiPotionBlue",
        "GiPotionRed",

        "GiMap",
# below items are not real items
        "GiBowArrow",
        "GiBowArrowSilver",
    ]),
    GameEnum("MusicSeq", "Ms",
    genEditorBindings=False,
    genPtrTable=True,
    genConstants=False,
    vals=[
        "MsNone",
        "MsDung0",
        "MsGI0",
        "MsOver0",
        "MsIntro0",
        "MsWorld0",
        "MsFinal0",
        "MsTri0",
        # 0x08
        "MsNone",
        "MsNone",
        "MsNone",
        "MsNone",
        "MsNone",
        "MsNone",
        "MsNone",
        "MsNone",

        # 0x10
        "MsNone",
        "MsDung1",
        "MsGI1",
        "MsOver1",
        "MsIntro1",
        "MsWorld1",
        "MsFinal1",
        "MsTri1",
        # 0x18
        "MsNone",
        "MsNone",
        "MsNone",
        "MsNone",
        "MsNone",
        "MsNone",
        "MsNone",
        "MsNone",
    ]),
    GameEnum("Sfx", "Sfx",
    genEditorBindings=False,
    genPtrTable=True,
    genConstants=True,
    vals=[
        "SfxStab",
        "SfxBomb",
        "SfxItemPickup",
        "SfxItemPickupKey",
        "SfxDef",
        "SfxEnDamage",
        "SfxPlHeal",
        "SfxPlDamage",
        "SfxSurf",
        "SfxArrow",
        "SfxSolve"
    ]),
    GameEnum("PlMoveDir", "PlDir",
    genEditorBindings=False,
    genPtrTable=True,
    genConstants=True,
    vals=[
        "PlDirR",
        "PlDirL",
        "PlDirD",
        "PlDirU"
    ]),
    GameEnum("EnMoveDir", "EnDir",
    genEditorBindings=False,
    genPtrTable=True,
    genConstants=True,
    vals=[
        "EnDirL",
        "EnDirR",
        "EnDirU",
        "EnDirD"
    ]),
    GameEnum("Messages", "Mesg",
    genEditorBindings=True,
    genPtrTable=True,
    genConstants=True,
    vals=mesg_ids),
    GameEnum("CaveType", "Cv",
    genEditorBindings=True,
    genPtrTable=True,
    genConstants=True,
    vals=[
        "Cv_Sword1",
        "Cv_Sword2",
        "Cv_Sword3",
        "Cv_Note",

        "Cv_Shop1",
        "Cv_Shop2",
        "Cv_Shop3",
        "Cv_Shop4",
        "Cv_Potion",

        "Cv_Path1",
        "Cv_Path2",
        "Cv_Path3",
        "Cv_Path4",

        "Cv_MoneyGame",
        "Cv_GiveHeartPotion",
        "Cv_TakeHeartRupee",
        "Cv_Rupees",
        "Cv_DoorRepair",
    ]),
    GameEnum("PlItem", "PlItem",
    genEditorBindings=False,
    genPtrTable=True,
    genConstants=True,
    vals=[
        "PlayerSword",
        "PlayerBomb",
        "PlayerArrow",
        "PlayerFire",
        "PlayerFlute",
        "PlayerWand",
        "PlayerMeat",
        "PlayerPotion",
    ]),
    GameEnum("PlItemPick", "PlItemPick",
    genEditorBindings=False,
    genPtrTable=True,
    genConstants=False,
    vals=[
        "PickSword",
        "PickBomb",
        "PickBow",
        "PickCandle",
        "PickFlute",
        "PickWand",
        "PickMeat",
        "PickPotion",
    ]),
]

def ToSnakeCase(s):
    cust = s.replace('_', '')
    return re.sub(r'(?<!^)(?=[A-Z])', '_', cust).upper()

def GetEditorBindings(sn, list):
    out = f'set "{sn}Count" to {len(list)}\n'
    for i in range(len(list)):
        out += f'set "${sn}{i}" to "{list[i]}"\n'
        out += f'set "{list[i]}" to {i}\n'
    return out

def DumpEditorBindings():
    editorBindings = ""
    for e in tbl:
        if e.genEditorBindings:
            editorBindings += GetEditorBindings(e.shortName, e.vals)

    with open(f'gen/editor_bindings.txt', "w") as file:
        file.write(editorBindings)

def DumpConstants():
    const = []
    constLen = 0
    for e in tbl:
        idx = 0
        for item in e.vals:
            if e.genConstants:
                temp = (ToSnakeCase(item), e.name, e.EnumFunc(idx))
                const.append(temp)
                length = len(temp[0])
                if length > constLen:
                    constLen = length
            idx += 1

    out = GetConstants(const, constLen)
    with open("gen/const.asm", "w") as file:
        file.write(out)

def DumpPtrAsm():
    for e in tbl:
        out = ""
        l = []
        h = []

        for item in e.vals:
            l.append(f"<({item}-1)")
            h.append(f">({item}-1)")

        out += f"{e.name}L:\n" + ToAsm(l,8) + '\n'
        out += f"{e.name}H:\n" + ToAsm(h,8)

        with open(f'gen/{e.name}.asm', "w") as file:
            file.write(out)

def GetConstants(const, l):
    lastName = None
    out = ""
    for sym, name, i in const:
        if name != lastName:
            if lastName != None:
                out += "\n"
            out += f"; {name} constants\n"
            lastName = name
        out += f"{sym:<{l}} = ${i:02X}\n"
    return out

DumpPtrAsm()
DumpConstants()
DumpEditorBindings()
print("Update Ptr Tables")
