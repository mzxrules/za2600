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
        "TriforceAI"
    ]),
    ( "RoomScript", [
        "RSNone",
        "RSMiddleEnt",
        "RSRaftSpot",
        "RSNeedTriforce",
        "RSSouthExit"
    ]),
    ( "MusicSeq", [
        "MSNone",
        "MSDung0",
        "MSNone",
        "MSNone",
        
        "MSNone",
        "MSDung1",
        "MSNone",
        "MSNone"
    ])
]
out = ""
for name, list in tbl:
    tL = f"{name}L:\n"
    tH = f"{name}H:\n"
    
    l = []
    h = []
    for item in list:
        l.append(f"<({item}-1)")
        h.append(f">({item}-1)")
        
    out = tL + ToAsm(l,8) + '\n' + tH + ToAsm(h,8)
    
    with open(f'gen/{name}.asm', "w") as file:
        file.write(out)
    
print("Update Ptr Tables")

#!/usr/bin/env python3
