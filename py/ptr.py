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

tbl = [
    GameEnum("Entity", "En",
    genEditorBindings=False,
    genPtrTable=True, 
    genConstants=True,
    vals=[
        "EnNone",
        "EnClearDrop",
        "EnItem",
        "EnStairs",
        "En_Darknut",
        "En_Wallmaster",
        "En_Octorok",
        "En_LikeLike",
        "EnBoss_Cucco",
        "En_DarknutMain",
        "En_OctorokMain",
        "En_LikeLikeMain",
        "EnShopkeeper",
        "En_OldMan"
    ]),
    GameEnum("EntityDraw", "EnDraw",
    genEditorBindings=False,
    genPtrTable=True, 
    genConstants=False,
    vals=[
        "EnDraw_None",
        "EnDraw_ClearDrop",
        "EnDraw_None",# "EnDrawItem",
        "EnDraw_None",# "EnDrawStairs",
        "EnDraw_Darknut",
        "EnDraw_Wallmaster",
        "EnDraw_Octorok",
        "EnDraw_LikeLike",
        "EnDraw_None",# "EnDrawBossCucco",
        "EnDraw_Darknut",
        "EnDraw_Octorok",
        "EnDraw_LikeLike",
        "EnDraw_Shopkeeper",
        "EnDraw_OldMan"
    ]),
    GameEnum("RoomScript", "Rs",
    genEditorBindings=True,
    genPtrTable=True, 
    genConstants=True,
    vals=[
        "RsNone",
        "RsCentralBlock",
        "RsWorldMidEnt",
        "RsDungMidEnt",
        "RsStairs",
        "RsDiamondBlockStairs",
        "RsItem",
        "RsRaftSpot",
        "RsNeedTriforce",
        "RsDungExit",
        "RsFairyFountain",
        "RsText",
        "RsOldMan",
        "RsCave",
        "RsLeftCaveEnt",
        "RsRightCaveEnt",
        "RsMaze",
        "RsShoreItem",
        "RsGameOver"
    ]),
    GameEnum("RoomScriptInit", "RsInit",
    genEditorBindings=False,
    genPtrTable=True, 
    genConstants=False,
    vals=[
        "RsInit_None",
        "RsInit_CentralBlock",
        "RsInit_None",
        "RsInit_None",
        "RsInit_None",
        "RsInit_None", #"RsDiamondBlockStairs",
        "RsInit_None",
        "RsInit_None",
        "RsInit_None",
        "RsInit_None",
        "RsInit_None",
        "RsInit_None",
        "RsInit_None",
        "RsInit_None",
        "RsInit_None",
        "RsInit_None",
        "RsInit_None",
        "RsInit_None",
        "RsInit_None"
    ]),
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

        "GiKey",
        "GiMasterKey",
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
        
        "GiArrows",
        "GiArrowsSilver",
        "GiCandleBlue",
        "GiCandleRed",

        "GiMeat",
        "GiNote",
        "GiPotionBlue",
        "GiPotionRed",

        "GiMap",
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
        "SfxDef",
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
    GameEnum("Text", "Text",
    genEditorBindings=True,
    genPtrTable=True, 
    genConstants=True,
    vals=mesg_ids),    
    GameEnum("PlItem", "PlItem",
    genEditorBindings=False,
    genPtrTable=True, 
    genConstants=True,
    vals=[
        "PlayerSword",
        "PlayerArrow",
        "PlayerBomb",
        "PlayerFire"
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
