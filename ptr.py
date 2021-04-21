#!/usr/bin/env python3
tbl = [
    ( "EnemyAI", [
        "NoAI",
        "DarknutAI",
        "StairAI",
        "BlockStairAI",
        "SpectacleOpenAI",
        "TriforceAI"
    ])
]
out = ""
for name, list in tbl:
    tL = f"{name}L:\n    .byte "
    tH = f"{name}H:\n    .byte "
    for item in list:
        tL += f"<({item}-1), "
        tH += f">({item}-1), "
        
    out = tL + '\n' + tH
    
with open('gen/ptr.asm', "w") as file:
    file.write(out)
    
print("Update Ptr Tables")