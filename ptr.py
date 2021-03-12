#!/usr/bin/env python3
tbl = [
    ( "EnemyAI", [
        "DarknutAI"
        #"DarknutRightAI",
        #"DarknutLeftAI",
        #"DarknutDownAI",
        #"DarknutUpAI"
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
    
with open('ptr.asm', "w") as file:
    file.write(out)