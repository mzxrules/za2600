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
        if self.name == "Level":
            return 0x80 - 18 + x
        return x

    def YieldPtr(self):
        if self.name == "CaveType":
            for item in self.vals:
                if item != "Cv_EndList":
                    yield item
                else:
                    break
        else:
            for item in self.vals:
                yield item


Entity_Table = [
    "EnNone",          "SEG_NA", "SEG_42", "EnDraw_None",
    "EnItem",          "SEG_53", "SEG_42", "EnDraw_Item",
    "EnStairs",        "SEG_53", "SEG_42", "EnDraw_Stairs",
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
    "En_Leever",       "SEG_52", "SEG_42", "EnDraw_Leever",
    "En_LeeverBlue",   "SEG_52", "SEG_42", "EnDraw_Leever",
    "En_Lynel",        "SEG_52", "SEG_42", "EnDraw_Lynel",
    "En_LynelBlue",    "SEG_52", "SEG_42", "EnDraw_Lynel",
    "En_LynelMain",    "SEG_52", "SEG_42", "EnDraw_Lynel",
    "En_Moblin",       "SEG_52", "SEG_42", "EnDraw_None",
    "En_MoblinBlue",   "SEG_52", "SEG_42", "EnDraw_None",
    "En_MoblinMain",   "SEG_52", "SEG_42", "EnDraw_Moblin",
    "En_Peehat",       "SEG_49", "SEG_42", "EnDraw_Peehat",
    "En_Zora",         "SEG_NA", "SEG_42", "EnDraw_None",
    "En_Tektite",      "SEG_50", "SEG_42", "EnDraw_None",
    "En_TektiteBlue",  "SEG_50", "SEG_42", "EnDraw_None",
    "En_TektiteMain",  "SEG_50", "SEG_42", "EnDraw_Tektite",

    "En_Darknut",      "SEG_43", "SEG_42", "EnDraw_Darknut",
    "En_DarknutBlue",  "SEG_43", "SEG_42", "EnDraw_Darknut",
    "En_DarknutMain",  "SEG_43", "SEG_42", "EnDraw_Darknut",
    "En_LikeLike",     "SEG_43", "SEG_42", "EnDraw_LikeLike",
    "En_LikeLikeMain", "SEG_43", "SEG_42", "EnDraw_LikeLike",
    "En_Rope",         "SEG_43", "SEG_42", "EnDraw_Rope",
    "En_RopeMain",     "SEG_43", "SEG_42", "EnDraw_Rope",
    "En_WallmasterSp", "SEG_44", "SEG_42", "EnDraw_None",
    "En_Wallmaster",   "SEG_44", "SEG_42", "EnDraw_Wallmaster",
    "En_Gibdo",        "SEG_49", "SEG_42", "EnDraw_Gibdo",
    "En_Goriya",       "SEG_47", "SEG_42", "EnDraw_None",
    "En_GoriyaBlue",   "SEG_47", "SEG_42", "EnDraw_None",
    "En_GoriyaMain",   "SEG_47", "SEG_42", "EnDraw_Goriya",
    "En_Keese",        "SEG_45", "SEG_45", "EnDraw_Keese",
    "En_Pols",         "SEG_54", "SEG_42", "EnDraw_Pols",
    "En_Stalfos",      "SEG_45", "SEG_42", "EnDraw_Stalfos",
    "En_Vire",         "SEG_49", "SEG_42", "EnDraw_Vire",
    "En_VireKeese",    "SEG_45", "SEG_46", "EnDraw_Appear",
    "En_Wizrobe",      "SEG_49", "SEG_42", "EnDraw_Wizrobe",
    "En_WizrobeBlue",  "SEG_49", "SEG_42", "EnDraw_Wizrobe",
    "En_Zol",          "SEG_49", "SEG_42", "EnDraw_Zol",
    "En_ZolGel",       "SEG_50", "SEG_46", "EnDraw_Appear",
    "En_Gel",          "SEG_50", "SEG_42", "EnDraw_Gel",

    "En_Test",         "SEG_44", "SEG_42", "EnDraw_Darknut",
    #"En_TestMissile",  "SEG_44", "SEG_46", "EnDraw_TestMissile",
    #"En_TestColor",    "SEG_47", "SEG_42", "EnDraw_TestColor",

    "En_Armos",        "SEG_53", "SEG_53", "EnDraw_Armos",
    "En_BossGhini",    "SEG_NA", "SEG_42", "EnDraw_None",

    "En_BossGohma",    "SEG_44", "SEG_46", "EnDraw_BossGohma",
    "En_BossGohmaBlue","SEG_44", "SEG_46", "EnDraw_BossGohma",
    "En_BossGlock",    "SEG_54", "SEG_46", "EnDraw_BossGlock",
    "En_BossGlockHead","SEG_54", "SEG_46", "EnDraw_BossGlockHead",
    "En_BossAqua",     "SEG_47", "SEG_46", "EnDraw_BossAqua",
    "En_BossManhandla","SEG_47", "SEG_46", "EnDraw_BossManhandla",
    "En_BossDon",      "SEG_50", "SEG_50", "EnDraw_BossDon",
    "En_BossDig",      "SEG_NA", "SEG_42", "EnDraw_None",
    "En_BossPatra",    "SEG_NA", "SEG_42", "EnDraw_None",
    "En_BossGanon",    "SEG_53", "SEG_46", "EnDraw_BossGanon",
    #"EnBoss_Cucco",    "SEG_NA", "SEG_42", "EnDraw_None",

    "En_Waterfall",    "SEG_NA", "SEG_46", "EnDraw_Waterfall",
    "En_RollingRock",  "SEG_45", "SEG_46", "EnDraw_RollingRock",
    "En_Appear",       "SEG_45", "SEG_46", "EnDraw_Appear",
]

HaltTask_Table = [
    "HtTask_RoomScrollStart",   "SEG_55",
    "HtTask_RoomScrollEnd",     "SEG_55",
    "HtTask_TransferA",         "SLOT_F4_ROOMSCROLL",
    "HtTask_TransferB",         "SLOT_F4_ROOMSCROLL",
    "HtTask_LoadRoom",          "SEG_HA",
    "HtTask_AnimEast",          "SEG_55",
    "HtTask_AnimWest",          "SEG_55",
    "HtTask_AnimNorth",         "SEG_55",
    "HtTask_AnimSouth",         "SEG_55",
    "HtTask_PlayFlute",         "SEG_55",
    "HtTask_EnterLoc",          "SEG_55",
    "HtTask_AnimDeath",         "SEG_55",
    "HtTask_IdleGameOver",      "SEG_55",
    "HtTask_WaitVStateBottom",  "SEG_HA",
    "HtTask_None",              "SEG_HA",
]

RoomScript_Table = [
    "Rs_None",                      "RsInit_None",
    "Rs_BlockCenter",               "RsInit_BlockCenter",
    "Rs_BlockLeftStairs",           "RsInit_BlockLeftStairs",
    "Rs_BlockDiamondStairs",        "RsInit_BlockDiamondStairs",
    "Rs_BlockSpiralStairs",         "RsInit_BlockSpiral",
    "Rs_BlockPathStairs",           "RsInit_BlockPathStairs",
    "Rs_MidRightStairs",            "RsInit_None",
    "Rs_MidRightStairsCenterKey",   "RsInit_None",
    "Rs_BAD_HIDDEN_CAVE",           "RsInit_None",
    "Rs_EntCaveWallLeftBlocked",    "RsInit_EntCaveWallLeftBlocked",
    "Rs_EntCaveWallCenterBlocked",  "RsInit_EntCaveWallCenterBlocked",
    "Rs_EntCaveWallRightBlocked",   "RsInit_EntCaveWallRightBlocked",
    "Rs_EntCaveWallBlocked_P2820",  "RsInit_Wall_P2820",
    "Rs_EntCaveWallBlocked_P4820",  "RsInit_Wall_P4820",
    "Rs_EntCaveWallLeft",           "RsInit_EntCaveWallLeft",
    "Rs_EntCaveWallCenter",         "RsInit_EntCaveWallCenter",
    "Rs_EntCaveWallRight",          "RsInit_EntCaveWallRight",
    "Rs_EntCaveWall_P2820",         "RsInit_EntCaveWall_P2820",
    "Rs_EntCaveWall_P4820",         "RsInit_EntCaveWall_P4820",
    "Rs_EntCaveMid",                "RsInit_None",
    "Rs_EntCaveMidSecretNorth",     "RsInit_None",
    "Rs_EntCaveLake",               "RsInit_EntCaveLake",
    "Rs_EntDungStairs",             "RsInit_None",
    "Rs_EntDungBush",               "RsInit_None",
    # RsBush must be grouped
    "Rs_EntDungBushBlocked",        "RsInit_EntDungBushBlocked",
    "Rs_EntCaveBushBlocked_P3428",  "RsInit_Bush_P3428",
    "Rs_EntCaveBushBlocked_P402C",  "RsInit_Bush_P402C",
    "Rs_EntCaveBushBlocked_P5820",  "RsInit_Bush_P5820",
    "Rs_EntCaveBushBlocked_P6420",  "RsInit_Bush_P6420",
    "Rs_EntCaveBushBlocked_P6438",  "RsInit_Bush_P6438",
    "Rs_EntCaveBushBlocked_P6C18",  "RsInit_Bush_P6C18",
    "Rs_ExitDung",                  "RsInit_None",
    "Rs_ExitDung2",                 "RsInit_None",
    "Rs_FairyFountain",             "RsInit_FairyFountain",
    "Rs_Item",                      "RsInit_None",
    "Rs_ItemKey",                   "RsInit_None",
    "Rs_Maze",                      "RsInit_None",
    "Rs_Npc",                       "RsInit_None",
    "Rs_NpcMonster",                "RsInit_None",
    "Rs_TakeHeartRupee",            "RsInit_None",
    "Rs_RaftSpot",                  "RsInit_None",
    "Rs_ShoreItem",                 "RsInit_None",
    "Rs_Shore",                     "RsInit_None",
    "Rs_Stairs",                    "RsInit_None",
    "Rs_Cave",                      "RsInit_None",
    "Rs_Waterfall",                 "RsInit_Waterfall",
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

Level_Table = [
    "Lv_A1", "Lv_B1",
    "Lv_A2", "Lv_B2",
    "Lv_A3", "Lv_B3",
    "Lv_A4", "Lv_B4",
    "Lv_A5", "Lv_B5",
    "Lv_A6", "Lv_B6",
    "Lv_A7", "Lv_B7",
    "Lv_A8", "Lv_B8",
    "Lv_A9", "Lv_B9",
    "Lv_A0", "Lv_B0",
]

Cave_Level_Table = [ "Cv_" + x for x in Level_Table]

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
    GameEnum("HtTask", "HtTask",
    genEditorBindings=False,
    genPtrTable=True,
    genConstants=True,
    vals=HaltTask_Table[0::2],
    bankLut=HaltTask_Table[1::2]),
    GameEnum("Ball", "Bl",
    genEditorBindings=False,
    genPtrTable=True,
    genConstants=True,
    vals=[
        "BlNone",
        # Ball movement ids must be 1-4
        "BlL",
        "BlR",
        "BlU",
        "BlD",
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
        "SfxStab2",
        "SfxBomb",
        "SfxFire",
        "SfxItemPickup",
        "SfxItemPickupKey",
        "SfxPlDef",
        "SfxEnDef",
        "SfxEnDamage",
        "SfxEnKill",
        "SfxBossRoar",
        "SfxPlHeal",
        "SfxPlDamage",
        "SfxArrow",
        "SfxDelay",
        "SfxQuake",
        "SfxWarp",
        "SfxShutterDoor",
        "SfxTalk",
        "SfxItemRupee",
        "SfxEnter",
    ],
    bankLut=None),
    GameEnum("Level", "Lv",
    genEditorBindings=False,
    genPtrTable=False,
    genConstants=True,
    vals=Level_Table,
    bankLut=None),
    GameEnum("PlMoveDir", "PlDir",
    genEditorBindings=False,
    genPtrTable=False,
    genConstants=True,
    vals=[
        "PlDirL",
        "PlDirR",
        "PlDirU",
        "PlDirD",
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

        "Cv_EndList", # Terminator for room script
    ] + Cave_Level_Table,
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
        "PlDraw_Sword",  # Sword
        "PlDraw_Bomb",   # Bomb
        "PlDraw_Arrow",  # Arrow
        "PlDraw_Sword",  # Candle
        "PlDraw_None",   # Flute
        "PlDraw_Wand",   # Wand
        "PlDraw_Sword",  # Meat
        "PlDraw_None",   # Rang

        "PlDraw_SwordFx",
        "PlDraw_FireFx",
        "PlDraw_FluteFx",
        "PlDraw_FluteFx",
        "PlDraw_WandFx",
        "PlDraw_MeatFx",
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
    GameEnum("MiType", "MiType",
    genEditorBindings=False,
    genPtrTable=True,
    genConstants=True,
    vals=[
        "MiNone",       "MiHit",
        # Small Shieldable
        "MiSpawnRock",  "MiRunRock",
        "MiSpawnRang",  "MiRunRang",
        "MiSpawnArrow", "MiRunArrow",
        # Magic Shieldable
        "MiSpawnBall",  "MiRunBall",
        "MiSpawnSword", "MiRunSword",
        "MiSpawnWave",  "MiRunWave",
    ],
    bankLut=None),
]

def GetEditorBindings(sn, list):
    out = f'set "{sn}Count" to {len(list)}\n'
    for i in range(len(list)):
        v = i
        if sn == "Lv":
            v = 0x80 - 18 + i
        out += f'set "${sn}{i}" to "{list[i]}"\n'
        out += f'set "{list[i]}" to {v}\n'
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
    with open("gen/constgen.asm", "w") as file:
        file.write(out)

def DumpPtrAsm():
    for e in tbl:
        if e.genPtrTable is False:
            continue
        out = ""
        l = []
        h = []

        for item in e.YieldPtr():
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
