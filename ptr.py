#!/usr/bin/env python3
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
    ( "EnemyAI", [
        "NoAI",
        "DarknutAI",
        "StairAI",
        "BlockStairAI",
        "SpectacleOpenAI",
        "TriforceAI",
        "ItemAI"
    ]),
    ( "RoomScript", [
        "RsNone",
        "RsWorldMidEnt",
        "RsDungMidEnt",
        "RsStairs",
        "RsItem",
        "RsRaftSpot",
        "RsNeedTriforce",
        "RsDungExit",
        "RsFairyFountain",
        "RsText"
    ]),
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
        "GiFlute",
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
        "SfxItemPickup"
    ])
]

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
    out = ""
    for name, list in tbl:
        if name == "RoomScript":
            DumpEditorBindings(name, list, editorBindings)
        elif name == "ItemId":
            DumpEditorBindings(name, list, editorBindings)
            
        l = []
        h = []
        for item in list:
            l.append(f"<({item}-1)")
            h.append(f">({item}-1)")
            
        out = f"{name}L:\n" + ToAsm(l,8) + '\n'
        out += f"{name}H:\n" + ToAsm(h,8)
        
        with open(f'gen/{name}.asm', "w") as file:
            file.write(out)

editorBindings = [""]
DumpPtrAsm(editorBindings)
with open(f'gen/editor_bindings.txt', "w") as file:
    file.write(editorBindings[0])   
print("Update Ptr Tables")
