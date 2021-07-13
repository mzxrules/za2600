#!/usr/bin/env python3
import re

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

tbl = [
    ( "Entity", [
        "EnNone",
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
        "EnTriforce",
        "EnItem"
    ]),
    ( "RoomScript", [
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
        "RsGameOver"
    ]),
    ( "Ball", [
        "BlNone",
        # Ball movement ids must be 1-4
        "BlR",
        "BlL",
        "BlD",
        "BlU",
        "BlPushBlock",
    ]
    ),
    ( "ItemId", [
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
    ( "MusicSeq", [
        "MsNone",
        "MsDung0",
        "MsGI0",
        "MsOver0",
        "MsIntro0",
        "MsWorld0",
        "MsNone",
        "MsNone",
        
        "MsNone",
        "MsDung1",
        "MsGI1",
        "MsOver1",
        "MsIntro1",
        "MsWorld1",
        "MsNone",
        "MsNone",
    ]),
    ( "Sfx", [
        "SfxStab",
        "SfxBomb",
        "SfxItemPickup",
        "SfxDef",
        "SfxPlHeal",
        "SfxPlDamage",
        "SfxSurf"
    ]),
    ( "PlMoveDir", [
        "PlDirR",
        "PlDirL",
        "PlDirD",
        "PlDirU"
    ]),
    ( "EnMoveDir", [
        "EnDirL",
        "EnDirR",
        "EnDirU",
        "EnDirD"
    ])
]

def ToSnakeCase(str):
    return re.sub(r'(?<!^)(?=[A-Z])', '_', str).upper()

def DumpEditorBindings(name, list, out):
    ShortNames = {
        "RoomScript" : "Rs",
        "ItemId" : "Gi",
    }
    sn = ShortNames[name]
    out[0] += f'set "{sn}Count" to {len(list)}\n'
    for i in range(len(list)):
        out[0] += f'set "${sn}{i}" to "{list[i]}"\n'
        out[0] += f'set "{list[i]}" to {i}\n'
    
def DumpPtrAsm(editorBindings):
    const = []
    constLen = 0
    for name, list in tbl:
        out = ""
        if name == "RoomScript":
            DumpEditorBindings(name, list, editorBindings)
        elif name == "ItemId":
            DumpEditorBindings(name, list, editorBindings)
            
        l = []
        h = []
        
        idx = 0
        if name == "Sfx":
            idx = 0x81
            
        for item in list:
            l.append(f"<({item}-1)")
            h.append(f">({item}-1)")
            if name != "MusicSeq":
                temp = (ToSnakeCase(item), name, idx)
                const.append(temp)
                length = len(temp[0]) 
                if length > constLen:
                    constLen = length
            idx += 1
            
        out += f"{name}L:\n" + ToAsm(l,8) + '\n'
        out += f"{name}H:\n" + ToAsm(h,8)
        
        with open(f'gen/{name}.asm', "w") as file:
            file.write(out)
    out = DumpConst(const, constLen)
    with open("gen/const.asm", "w") as file:
        file.write(out)
    
def DumpConst(const, l):
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

editorBindings = [""]
DumpPtrAsm(editorBindings)
with open(f'gen/editor_bindings.txt', "w") as file:
    file.write(editorBindings[0])   
print("Update Ptr Tables")
