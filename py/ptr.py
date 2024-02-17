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
        if self.name == "PlItem":
            return x if x < 8 else (x-8)
        return x

Entity_Table = [
    "EnNone",          "SEG_NA", "SEG_42", "EnDraw_None",
    "EnClearDrop",     "SEG_SH", "SEG_42", "EnDraw_ClearDrop",
    "EnItem",          "SEG_NA", "SEG_42", "EnDraw_None",
    "EnStairs",        "SEG_SH", "SEG_42", "EnDraw_None",
    "En_ItemGet",      "SEG_44", "SEG_42", "EnDraw_ItemGet",
    "En_NpcAppear",    "SEG_48", "SEG_42", "EnDraw_Npc",
    "En_Npc",          "SEG_45", "SEG_42", "EnDraw_Npc",
    "En_NpcMonster",   "SEG_45", "SEG_42", "EnDraw_Npc",
    "En_NpcShop",      "SEG_48", "SEG_42", "EnDraw_NpcShop",
    "En_NpcGame",      "SEG_48", "SEG_42", "EnDraw_NpcGame",
    "En_NpcShop2",     "SEG_48", "SEG_42", "EnDraw_NpcShop",
    "En_NpcShop1",     "SEG_48", "SEG_42", "EnDraw_NpcShop",
    "En_NpcGiveOne",   "SEG_48", "SEG_48", "EnDraw_NpcGiveOne",
    "En_NpcDoorRepair","SEG_48", "SEG_42", "EnDraw_Npc",
    "En_NpcPath",      "SEG_44", "SEG_42", "EnDraw_NpcPath",
    "En_GreatFairy",   "SEG_44", "SEG_46", "EnDraw_GreatFairy",

    "En_Octorok",      "SEG_43", "SEG_42", "EnDraw_Octorok",
    "En_OctorokBlue",  "SEG_43", "SEG_42", "EnDraw_Octorok",
    "En_OctorokMain",  "SEG_43", "SEG_42", "EnDraw_Octorok",

    "En_Leever",       "SEG_NA", "SEG_42", "EnDraw_None",
    "En_LeeverBlue",   "SEG_NA", "SEG_42", "EnDraw_None",
    "En_LeeverMain",   "SEG_NA", "SEG_42", "EnDraw_None",
    "En_Lynel",        "SEG_47", "SEG_42", "EnDraw_Darknut",
    "En_LynelBlue",    "SEG_47", "SEG_42", "EnDraw_Darknut",
    "En_LynelMain",    "SEG_47", "SEG_42", "EnDraw_Darknut",
    "En_Moblin",       "SEG_NA", "SEG_42", "EnDraw_None",
    "En_MoblinBlue",   "SEG_NA", "SEG_42", "EnDraw_None",
    "En_MoblinMain",   "SEG_NA", "SEG_42", "EnDraw_None",
    "En_Peehat",       "SEG_NA", "SEG_42", "EnDraw_None",
    "En_Zora",         "SEG_NA", "SEG_42", "EnDraw_None",
    "En_Tektite",      "SEG_NA", "SEG_42", "EnDraw_None",
    "En_TektiteBlue",  "SEG_NA", "SEG_42", "EnDraw_None",
    "En_TektiteMain",  "SEG_NA", "SEG_42", "EnDraw_None",

    "En_Darknut",      "SEG_43", "SEG_42", "EnDraw_Darknut",
    "En_DarknutBlue",  "SEG_43", "SEG_42", "EnDraw_Darknut",
    "En_DarknutMain",  "SEG_43", "SEG_42", "EnDraw_Darknut",
    "En_LikeLike",     "SEG_43", "SEG_42", "EnDraw_LikeLike",
    "En_LikeLikeMain", "SEG_43", "SEG_42", "EnDraw_LikeLike",
    "En_Rope",         "SEG_43", "SEG_42", "EnDraw_Rope",
    "En_RopeMain",     "SEG_43", "SEG_42", "EnDraw_Rope",
    "En_Wallmaster",   "SEG_44", "SEG_42", "EnDraw_Wallmaster",

    "En_Gibdo",        "SEG_NA", "SEG_42", "EnDraw_None",
    "En_Goriya",       "SEG_47", "SEG_42", "EnDraw_None",
    "En_GoriyaBlue",   "SEG_47", "SEG_42", "EnDraw_None",
    "En_GoriyaMain",   "SEG_47", "SEG_42", "EnDraw_Goriya",
    "En_Keese",        "SEG_45", "SEG_45", "EnDraw_Keese",
    "En_Pols",         "SEG_NA", "SEG_42", "EnDraw_None",
    "En_Stalfos",      "SEG_45", "SEG_42", "EnDraw_Stalfos",
    "En_Vire",         "SEG_NA", "SEG_42", "EnDraw_None",
    "En_VireSplit",    "SEG_NA", "SEG_42", "EnDraw_None",
    "En_Wizrobe",      "SEG_NA", "SEG_42", "EnDraw_None",
    "En_WizrobeBlue",  "SEG_NA", "SEG_42", "EnDraw_None",
    "En_Zol",          "SEG_NA", "SEG_42", "EnDraw_None",
    "En_ZolSplit",     "SEG_NA", "SEG_42", "EnDraw_None",
    "En_Gel",          "SEG_NA", "SEG_42", "EnDraw_None",

    "En_Test",         "SEG_44", "SEG_42", "EnDraw_Darknut",
    #"En_TestMissile",  "SEG_44", "SEG_46", "EnDraw_TestMissile",
    #"En_TestColor",    "SEG_47", "SEG_42", "EnDraw_TestColor",

    "En_BossGhini",    "SEG_NA", "SEG_42", "EnDraw_None",

    "En_BossGohma",    "SEG_44", "SEG_46", "EnDraw_BossGohma",
    "En_BossGlock",    "SEG_44", "SEG_46", "EnDraw_BossGlock",
    "En_BossGlockHead","SEG_44", "SEG_46", "EnDraw_BossGlockHead",
    "En_BossAqua",     "SEG_47", "SEG_46", "EnDraw_BossAqua",
    "En_BossManhandla","SEG_47", "SEG_46", "EnDraw_BossManhandla",
    "En_BossDon",      "SEG_NA", "SEG_42", "EnDraw_None",
    "En_BossDig",      "SEG_NA", "SEG_42", "EnDraw_None",
    "En_BossPatra",    "SEG_NA", "SEG_42", "EnDraw_None",
    "En_BossGanon",    "SEG_NA", "SEG_42", "EnDraw_None",
    #"EnBoss_Cucco",    "SEG_NA", "SEG_42", "EnDraw_None",

    "En_Waterfall",    "SEG_NA", "SEG_46", "EnDraw_Waterfall",
    "En_RollingRock",  "SEG_45", "SEG_46", "EnDraw_RollingRock",
    "En_Appear",       "SEG_45", "SEG_46", "EnDraw_Appear",
]

RoomScript_Table = [
    "Rs_None",                      "RsInit_None",
    "Rs_BlockCenter",               "RsInit_BlockCenter",
    "Rs_BlockLeftStairs",           "RsInit_BlockLeftStairs",
    "Rs_BlockDiamondStairs",        "RsInit_BlockDiamondStairs",
    "Rs_BlockSpiralStairs",         "RsInit_BlockSpiral",
    "Rs_BlockPathStairs",           "RsInit_BlockPathStairs",
    "Rs_BAD_HIDDEN_CAVE",           "RsInit_None",
    "Rs_BAD_CAVE",                  "RsInit_None",
    "Rs_EntCaveWallLeftBlocked",    "RsInit_EntCaveWallLeftBlocked",
    "Rs_EntCaveWallCenterBlocked",  "RsInit_EntCaveWallCenterBlocked",
    "Rs_EntCaveWallRightBlocked",   "RsInit_EntCaveWallRightBlocked",
    "Rs_EntCaveWallLeft",           "RsInit_EntCaveWallLeft",
    "Rs_EntCaveWallCenter",         "RsInit_EntCaveWallCenter",
    "Rs_EntCaveWallRight",          "RsInit_EntCaveWallRight",
    "Rs_EntCaveMid",                "RsInit_None",
    "Rs_EntCaveMidSecretNorth",     "RsInit_None",
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
    "Rs_NpcMonster",                "RsInit_None",
    "Rs_TakeHeartRupee",            "RsInit_None",
    "Rs_RaftSpot",                  "RsInit_None",
    "Rs_ShoreItem",                 "RsInit_None",
    "Rs_Stairs",                    "RsInit_None",
    "Rs_Cave",                      "RsInit_None",
    "Rs_Waterfall",                 "RsInit_Waterfall",
    "Rs_GameOver",                  "RsInit_None",
]

GiValues_Table = [
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
    "GiFlute",

    "GiMeat",
    "GiSword1",
    "GiSword2",
    "GiSword3",

    "GiWand",
    "GiBook",
    "GiRang",
    "GiRaft",

    "GiBoots",
    "GiBracelet",
    "GiRingBlue",
    "GiRingRed",

    "GiBow",
    "GiArrow",
    "GiArrowSilver",
    "GiCandleBlue",

    "GiCandleRed",
    "GiNote",
    "GiPotionBlue",
    "GiPotionRed",

    "GiMap",
    "GiCompass",
# below items are not real items
    "GiBowArrow",
    "GiBowArrowSilver",
    "GiWandBook",
]

tbl = [
    GameEnum("En", "En",
    genEditorBindings=False,
    genPtrTable=True,
    genConstants=True,
    vals=Entity_Table[0::4],
    bankLut=Entity_Table[1::4]),
    GameEnum("EnDraw", "EnDraw",
    genEditorBindings=False,
    genPtrTable=True,
    genConstants=False,
    vals=Entity_Table[3::4],
    bankLut=Entity_Table[2::4]),
    GameEnum("Rs", "Rs",
    genEditorBindings=True,
    genPtrTable=True,
    genConstants=True,
    vals=RoomScript_Table[0::2],
    bankLut=None),
    GameEnum("RsInit", "RsInit",
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
        "BlPushBlockDiamondTop",
        "BlPushBlockLeft",
        "BlPathPushBlock",
        "BlPushBlockWaterfall",
    ],
    bankLut=None
    ),
    GameEnum("ItemId", "Gi",
    genEditorBindings=True,
    genPtrTable=True,
    genConstants=False,
    vals=GiValues_Table[:-3],
    bankLut=None),
    GameEnum("ItemId", "Gi",
    genEditorBindings=True,
    genPtrTable=False,
    genConstants=True,
    vals=GiValues_Table,
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
        "SfxTalk",
        "SfxItemRupee",
    ],
    bankLut=None),
    GameEnum("PlMoveDir", "PlDir",
    genEditorBindings=False,
    genPtrTable=False,
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
        "Cv_GiveHeartPotion",
        "Cv_TakeHeartRupee",
        "Cv_Potion",

        "Cv_DoorRepair",
        "Cv_MoneyGame",

        "Cv_Path1",
        "Cv_Path2",
        "Cv_Path3",
        "Cv_Path4",

        "Cv_MesgHintGrave",
        "Cv_MesgHintLostWoods",
        "Cv_MesgHintLostHills",
        "Cv_MesgHintTreeAtDeadEnd",
    ],
    bankLut=None),
    GameEnum("PlItem", "PlItem",
    genEditorBindings=False,
    genPtrTable=False,
    genConstants=True,
    vals=[
        "PlayerSword",
        "PlayerBomb",
        "PlayerArrow",
        "PlayerCandle",
        "PlayerFlute",
        "PlayerWand",
        "PlayerMeat",
        "PlayerRang",

        "PlayerSwordFx",
        "PlayerFireFx",
        "PlayerFluteFx",
        "PlayerFluteFx2", # Must be AND $FE to PlayerFluteFx
        "PlayerWandFx",
        "PlayerMeatFx",
        "PlayerRangFx",
    ],
    bankLut=None),
    GameEnum("PlUseItem", "PlUseItem",
    genEditorBindings=False,
    genPtrTable=True,
    genConstants=False,
    vals=[
        "PlayerUseSword",
        "PlayerUseBomb",
        "PlayerUseArrow",
        "PlayerUseCandle",
        "PlayerUseFlute",
        "PlayerUseWand",
        "PlayerUseMeat",
        "PlayerUseRang",
    ],
    bankLut=None),
    GameEnum("PlUpdateItem", "PlUpdateItem",
    genEditorBindings=False,
    genPtrTable=True,
    genConstants=False,
    vals=[
        "PlayerUpdateSword",    # Sword
        "PlayerUpdateNone",     # Bomb
        "PlayerUpdateArrow",    # Arrow
        "PlayerUpdateNone",     # Candle
        "PlayerUpdateNone",     # Flute
        "PlayerUpdateWand",     # Wand
        "PlayerUpdateNone",     # Meat
        "PlayerUpdateNone",     # Rang

        "PlayerUpdateSwordFx",  # SwordFx
        "PlayerUpdateFireFx",   # FireFx
        "PlayerUpdateFluteFx",
        "PlayerUpdateFluteFx2",
        "PlayerUpdateWandFx",
        "PlayerUpdateMeatFx",
    ],
    bankLut=None),
    GameEnum("PlDrawItem", "PlDrawItem",
    genEditorBindings=False,
    genPtrTable=True,
    genConstants=False,
    vals=[
        "PlayerDrawSword",  # Sword
        "PlayerDrawBomb",   # Bomb
        "PlayerDrawArrow",  # Arrow
        "PlayerDrawSword",  # Candle
        "PlayerDrawNone",   # Flute
        "PlayerDrawWand",   # Wand
        "PlayerDrawSword",  # Meat
        "PlayerDrawNone",   # Rang

        "PlayerDrawSwordFx",
        "PlayerDrawFireFx",
        "PlayerDrawFluteFx",
        "PlayerDrawFluteFx",
        "PlayerDrawWandFx",
        "PlayerDrawMeatFx",
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
        "PickRang",
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
        "HbPlSword",    # Candle
        "HbPlNone",     # Flute
        "HbPlWand",
        "HbPlSword",    # Meat
        "HbPlSword",    # Rang

        "HbPlSwordFx",  # SwordFx
        "HbPlFireFx",   # FireFx
        "HbPlNone",     # FluteFx
        "HbPlNone",     # FluteFx2
        "HbPlWandFx",   # WandFx
        "HbPlNone",     # MeatFx
        "HbPlRangFx",   # RangFx
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
        if e.genPtrTable is False:
            continue
        out = ""
        l = []
        h = []

        for item in e.vals:
            l.append(f"<({item}-1)")
            h.append(f">({item}-1)")

        out += f"{e.name}L:\n" + ToAsm(l,8) + '\n'
        out += f"{e.name}H:\n" + ToAsm(h,8)

        with open(f'gen/{e.name}_DelLUT.asm', "w") as file:
            file.write(out)

        if e.bankLut is not None:
            out = ""
            out += f"{e.name}_BankLUT:\n"
            test = zip(e.vals, e.bankLut)
            for thing, segment in test:
                out += f"    .byte  {segment} ; {thing}\n"

            with open(f'gen/{e.name}_DelBankLUT.asm', "w") as file:
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
