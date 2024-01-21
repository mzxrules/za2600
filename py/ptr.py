#!/usr/bin/env python3
from mesg import *
from dataclasses import dataclass, field
from func_common import ToSnakeCase

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
    bankLut: list = field(default_factory=list)

    def __post_init__(self):
        if self.shortName == None:
            self.shortName = self.name

    def EnumFunc(self, x):
        if self.name == "Sfx":
            return 0x81 + x
        if self.name == "EnBlockedDir":
            return 1 << x
        return x

Entity_Table = [
    "EnNone",          "SEG_NA", "SEG_28", "EnDraw_None",
    "EnClearDrop",     "SEG_SH", "SEG_28", "EnDraw_ClearDrop",
    "EnItem",          "SEG_NA", "SEG_28", "EnDraw_None",
    "EnStairs",        "SEG_SH", "SEG_28", "EnDraw_None",
    "En_ItemGet",      "SEG_35", "SEG_28", "EnDraw_ItemGet",
    "En_NpcShopkeeper","SEG_SH", "SEG_28", "EnDraw_NpcShopkeeper",
    "En_NpcGiveOne",   "SEG_SH", "SEG_28", "EnDraw_NpcGiveOne",
    "En_NpcPath",      "SEG_35", "SEG_28", "EnDraw_NpcPath",
    "En_NpcOldMan",    "SEG_35", "SEG_28", "EnDraw_NpcOldMan",
    "En_GreatFairy",   "SEG_35", "SEG_39", "EnDraw_GreatFairy",

    "En_Octorok",      "SEG_34", "SEG_28", "EnDraw_Octorok",
    "En_OctorokBlue",  "SEG_34", "SEG_28", "EnDraw_Octorok",
    "En_OctorokMain",  "SEG_34", "SEG_28", "EnDraw_Octorok",

    "En_Leever",       "SEG_NA", "SEG_28", "EnDraw_None",
    "En_LeeverBlue",   "SEG_NA", "SEG_28", "EnDraw_None",
    "En_LeeverMain",   "SEG_NA", "SEG_28", "EnDraw_None",
    "En_Lynel",        "SEG_40", "SEG_28", "EnDraw_Darknut",
    "En_LynelBlue",    "SEG_40", "SEG_28", "EnDraw_Darknut",
    "En_LynelMain",    "SEG_40", "SEG_28", "EnDraw_Darknut",
    "En_Moblin",       "SEG_NA", "SEG_28", "EnDraw_None",
    "En_MoblinBlue",   "SEG_NA", "SEG_28", "EnDraw_None",
    "En_MoblinMain",   "SEG_NA", "SEG_28", "EnDraw_None",
    "En_Peehat",       "SEG_NA", "SEG_28", "EnDraw_None",
    "En_Zora",         "SEG_NA", "SEG_28", "EnDraw_None",
    "En_Tektite",      "SEG_NA", "SEG_28", "EnDraw_None",
    "En_TektiteBlue",  "SEG_NA", "SEG_28", "EnDraw_None",
    "En_TektiteMain",  "SEG_NA", "SEG_28", "EnDraw_None",

    "En_Darknut",      "SEG_34", "SEG_28", "EnDraw_Darknut",
    "En_DarknutBlue",  "SEG_34", "SEG_28", "EnDraw_Darknut",
    "En_DarknutMain",  "SEG_34", "SEG_28", "EnDraw_Darknut",
    "En_LikeLike",     "SEG_34", "SEG_28", "EnDraw_LikeLike",
    "En_LikeLikeMain", "SEG_34", "SEG_28", "EnDraw_LikeLike",
    "En_Rope",         "SEG_34", "SEG_28", "EnDraw_Rope",
    "En_RopeMain",     "SEG_34", "SEG_28", "EnDraw_Rope",
    "En_Wallmaster",   "SEG_35", "SEG_28", "EnDraw_Wallmaster",

    "En_Gibdo",        "SEG_NA", "SEG_28", "EnDraw_None",
    "En_Goriya",       "SEG_40", "SEG_28", "EnDraw_None",
    "En_GoriyaBlue",   "SEG_40", "SEG_28", "EnDraw_None",
    "En_GoriyaMain",   "SEG_40", "SEG_40", "EnDraw_Goriya",
    "En_Keese",        "SEG_37", "SEG_37", "EnDraw_Keese",
    "En_Pols",         "SEG_NA", "SEG_28", "EnDraw_None",
    "En_Stalfos",      "SEG_37", "SEG_28", "EnDraw_Stalfos",
    "En_Vire",         "SEG_NA", "SEG_28", "EnDraw_None",
    "En_VireSplit",    "SEG_NA", "SEG_28", "EnDraw_None",
    "En_Wizrobe",      "SEG_NA", "SEG_28", "EnDraw_None",
    "En_WizrobeBlue",  "SEG_NA", "SEG_28", "EnDraw_None",
    "En_Zol",          "SEG_NA", "SEG_28", "EnDraw_None",
    "En_ZolSplit",     "SEG_NA", "SEG_28", "EnDraw_None",

    "En_Test",         "SEG_35", "SEG_28", "EnDraw_Darknut",
    "En_TestMissile",  "SEG_35", "SEG_39", "EnDraw_TestMissile",
    "En_TestColor",    "SEG_40", "SEG_28", "EnDraw_TestColor",

    "En_BossGohma",    "SEG_35", "SEG_39", "EnDraw_BossGohma",
    "En_BossGlock",    "SEG_35", "SEG_39", "EnDraw_BossGlock",
    "En_BossGlockHead","SEG_35", "SEG_39", "EnDraw_BossGlockHead",
    "En_BossAqua",     "SEG_40", "SEG_39", "EnDraw_BossAqua",
    "En_BossManhandla","SEG_40", "SEG_39", "EnDraw_BossManhandla",
    "En_BossDon",      "SEG_NA", "SEG_28", "EnDraw_None",
    "En_BossDig",      "SEG_NA", "SEG_28", "EnDraw_None",
    "En_BossPatra",    "SEG_NA", "SEG_28", "EnDraw_None",
    "En_BossGanon",    "SEG_NA", "SEG_28", "EnDraw_None",
    "EnBoss_Cucco",    "SEG_37", "SEG_28", "EnDraw_None",

    "En_Waterfall",    "SEG_NA", "SEG_39", "EnDraw_Waterfall",
    "En_RollingRock",  "SEG_37", "SEG_39", "EnDraw_RollingRock",
    "En_Appear",       "SEG_37", "SEG_39", "EnDraw_Appear",
]

RoomScript_Table = [
    "Rs_None",                      "RsInit_None",
    "Rs_BlockCentral",              "RsInit_BlockCentral",
    "Rs_BlockDiamondStairs",        "RsInit_BlockDiamondStairs",
    "Rs_BlockPathStairs",           "RsInit_BlockPathStairs",
    "Rs_EntCaveWallLeft",           "RsInit_None",
    "Rs_EntCaveWallLeftBlocked",    "RsInit_EntCaveWallLeftBlocked",
    "Rs_EntCaveWallCenter",         "RsInit_None",
    "Rs_EntCaveWallCenterBlocked",  "RsInit_EntCaveWallCenterBlocked",
    "Rs_EntCaveWallRight",          "RsInit_None",
    "Rs_EntCaveWallRightBlocked",   "RsInit_EntCaveWallRightBlocked",
    "Rs_EntCaveMid",                "RsInit_None",
    "Rs_EntDungMid",                "RsInit_None",
    "Rs_EntDungBush",               "RsInit_None",
    "Rs_EntDungSpectacleRock",      "RsInit_None",
    "Rs_EntDungFlute",              "RsInit_EntDungFlute",
    "Rs_EntDungBushBlocked",        "RsInit_EntDungBush",
    "Rs_EntDungSpectacleRockBlocked","RsInit_SpectacleRock",
    "Rs_ExitDung",                  "RsInit_None",
    "Rs_ExitDung2",                 "RsInit_None",
    "Rs_FairyFountain",             "RsInit_FairyFountain",
    "Rs_Item",                      "RsInit_None",
    "Rs_Maze",                      "RsInit_None",
    "Rs_Npc",                       "RsInit_None",
    "Rs_NpcTriforce",               "RsInit_None",
    "Rs_RaftSpot",                  "RsInit_None",
    "Rs_ShoreItem",                 "RsInit_None",
    "Rs_Stairs",                    "RsInit_None",
    "Rs_Cave",                      "RsInit_None",
    "Rs_Waterfall",                 "RsInit_None",
    "Rs_GameOver",                  "RsInit_None",
]

tbl = [
    GameEnum("Entity", "En",
    genEditorBindings=False,
    genPtrTable=True,
    genConstants=True,
    vals=Entity_Table[0::4],
    bankLut=Entity_Table[1::4]),
    GameEnum("EntityDraw", "EnDraw",
    genEditorBindings=False,
    genPtrTable=True,
    genConstants=False,
    vals=Entity_Table[3::4],
    bankLut=Entity_Table[2::4]),
    GameEnum("RoomScript", "Rs",
    genEditorBindings=True,
    genPtrTable=True,
    genConstants=True,
    vals=RoomScript_Table[0::2],
    bankLut=None),
    GameEnum("RoomScriptInit", "RsInit",
    genEditorBindings=False,
    genPtrTable=True,
    genConstants=False,
    vals=RoomScript_Table[1::2],
    bankLut=None),
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
        "BlPathPushBlock",
    ],
    bankLut=None
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
        "GiCompass",
# below items are not real items
        "GiBowArrow",
        "GiBowArrowSilver",
    ],
    bankLut=None),
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
    ],
    bankLut=None),
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
        "SfxSolve",
        "SfxDelay",
        "SfxQuake",
        "SfxWarp",
        "SfxShutterDoor",
    ],
    bankLut=None),
    GameEnum("PlMoveDir", "PlDir",
    genEditorBindings=False,
    genPtrTable=True,
    genConstants=True,
    vals=[
        "PlDirR",
        "PlDirL",
        "PlDirD",
        "PlDirU"
    ],
    bankLut=None),
    GameEnum("EnMoveDir", "EnDir",
    genEditorBindings=False,
    genPtrTable=False,
    genConstants=True,
    vals=[
        "EnDirL",
        "EnDirR",
        "EnDirU",
        "EnDirD",
        "EnDirLu",
        "EnDirLd",
        "EnDirRu",
        "EnDirRd",
    ],
    bankLut=None),
    GameEnum("EnBlockedDir", "EnBlockedDir",
    genEditorBindings=False,
    genPtrTable=False,
    genConstants=True,
    vals=[
        "EnBlockedDirL",
        "EnBlockedDirR",
        "EnBlockedDirU",
        "EnBlockedDirD"
    ],
    bankLut=None),
    GameEnum("Messages", "Mesg",
    genEditorBindings=True,
    genPtrTable=True,
    genConstants=True,
    vals=mesg_ids,
    bankLut=None),
    GameEnum("CaveType", "Cv",
    genEditorBindings=True,
    genPtrTable=True,
    genConstants=True,
    vals=[
        "Cv_Sword1",
        "Cv_Sword2",
        "Cv_Sword3",
        "Cv_Note",
        "Cv_Rupees100",
        "Cv_Rupees30",
        "Cv_Rupees10",

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
        "Cv_DoorRepair",

        "Cv_MesgHintGrave",
        "Cv_MesgHintLostWoods",
        "Cv_MesgHintLostHills",
    ],
    bankLut=None),
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
    ],
    bankLut=None),
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
    ],
    bankLut=None),

    GameEnum("HbPlAtt", "HbPlAtt",
    genEditorBindings=False,
    genPtrTable=True,
    genConstants=False,
    vals=[
        "HbPlSword",
        "HbPlBomb",
        "HbPlBow",
        "HbPlCandle",
        "HbPlFlute",
        "HbPlWand",
        "HbPlMeat",
        "HbPlPotion",
    ],
    bankLut=None),
]

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

        if e.bankLut is not None:
            out = ""
            out += f"{e.name}_BankLUT:\n"
            test = zip(e.vals, e.bankLut)
            for thing, segment in test:
                out += f"    .byte  {segment} ; {thing}\n"

            with open(f'gen/{e.name}_bank.asm', "w") as file:
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
