#!/usr/bin/env python3
import re
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
        elif self.name == "Text":
            return x * 4
        return x

tbl = [
    GameEnum("Entity", "En",
    genEditorBindings=False,
    genPtrTable=True, 
    genConstants=True,
    vals=[
        "EnNone",
        "EnClearDrop",
        "EnDarknut",
        "EnWallmaster",
        "EnOctorok",
        "EnLikeLike",
        "EnBossCucco",
        "EnDarknutMain",
        "EnOctorokMain",
        "EnLikeLikeMain",
        "EnStairs",
        "EnSpectacleOpen",
        "EnItem",
        "EnShopkeeper"
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
        "RsShop",
        "RsGameOver"
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
        "GiRecoverHeart",
        "GiFairy",
        "GiBomb",
        "GiRupee5",
        
        "GiTriforce",
        "GiHeart",
        "GiKey",
        "GiMasterKey",
        
        "GiSword2",
        "GiSword3",
        "GiCandle",
        "GiMeat",
        
        "GiBoots",
        "GiRing",
        "GiPotion",
        "GiRaft",
        # 0x10
        "GiFlute",
        "GiFireMagic",
        "GiBow",
        "GiArrows",
        
        "GiBracelet",
        "GiMap"
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
        "MsNone",
        
        "MsNone",
        "MsDung1",
        "MsGI1",
        "MsOver1",
        "MsIntro1",
        "MsWorld1",
        "MsFinal1",
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
        "SfxArrow"
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
    vals=[
        "TextGameover",
        "TextNeedTriforce",
        "Text2",
        "Text3"
    ]),
]

def ToSnakeCase(str):
    return re.sub(r'(?<!^)(?=[A-Z])', '_', str).upper()

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
