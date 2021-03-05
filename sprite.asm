    align 256
SprN0:
    .byte $18 ; |...XX...|
    .byte $24 ; |..X..X..|
    .byte $24 ; |..X..X..|
    .byte $24 ; |..X..X..|
    .byte $24 ; |..X..X..|
    .byte $24 ; |..X..X..|
    .byte $18 ; |...XX...|
SprN1:
    .byte $1C ; |...XXX..|
    .byte $08 ; |....X...|
    .byte $08 ; |....X...|
    .byte $08 ; |....X...|
    .byte $08 ; |....X...|
    .byte $18 ; |...XX...|
    .byte $08 ; |....X...|
SprN2:
    .byte $3C ; |..XXXX..|
    .byte $20 ; |..X.....|
    .byte $18 ; |...XX...|
    .byte $04 ; |.....X..|
    .byte $24 ; |..X..X..|
    .byte $24 ; |..X..X..|
    .byte $18 ; |...XX...|
SprN3:
    .byte $18 ; |...XX...|
    .byte $24 ; |..X..X..|
    .byte $04 ; |.....X..|
    .byte $18 ; |...XX...|
    .byte $04 ; |.....X..|
    .byte $24 ; |..X..X..|
    .byte $18 ; |...XX...|
SprN4:
    .byte $08 ; |....X...|
    .byte $08 ; |....X...|
    .byte $08 ; |....X...|
    .byte $3C ; |..XXXX..|
    .byte $28 ; |..X.X...|
    .byte $28 ; |..X.X...|
    .byte $28 ; |..X.X...|
SprN5:
    .byte $18 ; |...XX...|
    .byte $24 ; |..X..X..|
    .byte $04 ; |.....X..|
    .byte $3C ; |..XXXX..|
    .byte $20 ; |..X.....|
    .byte $20 ; |..X.....|
    .byte $3C ; |..XXXX..|
SprN6:
    .byte $18 ; |...XX...|
    .byte $24 ; |..X..X..|
    .byte $24 ; |..X..X..|
    .byte $3C ; |..XXXX..|
    .byte $20 ; |..X.....|
    .byte $24 ; |..X..X..|
    .byte $18 ; |...XX...|
SprN7:
    .byte $10 ; |...X....|
    .byte $10 ; |...X....|
    .byte $08 ; |....X...|
    .byte $04 ; |.....X..|
    .byte $04 ; |.....X..|
    .byte $24 ; |..X..X..|
    .byte $3C ; |..XXXX..|
SprN8:
    .byte $18 ; |...XX...|
    .byte $24 ; |..X..X..|
    .byte $24 ; |..X..X..|
    .byte $18 ; |...XX...|
    .byte $24 ; |..X..X..|
    .byte $24 ; |..X..X..|
    .byte $18 ; |...XX...|
SprN9:
    .byte $04 ; |.....X..|
    .byte $04 ; |.....X..|
    .byte $04 ; |.....X..|
    .byte $1C ; |...XXX..|
    .byte $24 ; |..X..X..|
    .byte $24 ; |..X..X..|
    .byte $18 ; |...XX...|
SprP0:
    .byte $01 ; |.......X|
    .byte $01 ; |.......X|
    .byte $19 ; |...XX..X|
    .byte $3C ; |..XXXX..|
    .byte $3C ; |..XXXX..|
    .byte $18 ; |...XX...|
    .byte $00 ; |........|
    .byte $00 ; |........|
SprP1:
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $18 ; |...XX...|
    .byte $3C ; |..XXXX..|
    .byte $3C ; |..XXXX..|
    .byte $98 ; |X..XX...|
    .byte $80 ; |X.......|
    .byte $80 ; |X.......|
SprP2:
    .byte $70 ; |.XXX....|
    .byte $00 ; |........|
    .byte $18 ; |...XX...|
    .byte $3C ; |..XXXX..|
    .byte $3C ; |..XXXX..|
    .byte $18 ; |...XX...|
    .byte $00 ; |........|
    .byte $00 ; |........|
SprP3:
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $18 ; |...XX...|
    .byte $3C ; |..XXXX..|
    .byte $3C ; |..XXXX..|
    .byte $18 ; |...XX...|
    .byte $00 ; |........|
    .byte $0E ; |....XXX.|
SprE0:
    .byte $3E ; |..XXXXX.|
    .byte $54 ; |.X.X.X..|
    .byte $C0 ; |XX......|
    .byte $EA ; |XXX.X.X.|
    .byte $FF ; |XXXXXXXX|
    .byte $ED ; |XXX.XX.X|
    .byte $C9 ; |XX..X..X|
    .byte $7E ; |.XXXXXX.|
SprE1:
    .byte $00 ; |........|
    .byte $7E ; |.XXXXXX.|
    .byte $D4 ; |XX.X.X..|
    .byte $EA ; |XXX.X.X.|
    .byte $FF ; |XXXXXXXX|
    .byte $ED ; |XXX.XX.X|
    .byte $C9 ; |XX..X..X|
    .byte $7E ; |.XXXXXX.|
SprE2:
    .byte $6A ; |.XX.X.X.|
    .byte $BD ; |X.XXXX.X|
    .byte $FE ; |XXXXXXX.|
    .byte $7F ; |.XXXXXXX|
    .byte $FE ; |XXXXXXX.|
    .byte $7F ; |.XXXXXXX|
    .byte $BD ; |X.XXXX.X|
    .byte $56 ; |.X.X.XX.|
SprE3:
    .byte $FF ; |XXXXXXXX|
    .byte $7F ; |.XXXXXXX|
    .byte $7E ; |.XXXXXX.|
    .byte $32 ; |..XX..X.|
    .byte $32 ; |..XX..X.|
    .byte $3E ; |..XXXXX.|
    .byte $24 ; |..X..X..|
    .byte $1E ; |...XXXX.|
SprE4:
    .byte $24 ; |..X..X..|
    .byte $A5 ; |X.X..X.X|
    .byte $A5 ; |X.X..X.X|
    .byte $5A ; |.X.XX.X.|
    .byte $BD ; |X.XXXX.X|
    .byte $7E ; |.XXXXXX.|
    .byte $BD ; |X.XXXX.X|
    .byte $5A ; |.X.XX.X.|
SprE5:
    .byte $10 ; |...X....|
    .byte $10 ; |...X....|
    .byte $18 ; |...XX...|
    .byte $27 ; |..X..XXX|
    .byte $E4 ; |XXX..X..|
    .byte $18 ; |...XX...|
    .byte $08 ; |....X...|
    .byte $08 ; |....X...|
    align 256
PF1Room0:
    .byte $FF ; |XXXXXXXX|
    .byte $F0 ; |XXXX....|
    .byte $E0 ; |XXX.....|
    .byte $E0 ; |XXX.....|
    .byte $C0 ; |XX......|
    .byte $C0 ; |XX......|
    .byte $C0 ; |XX......|
    .byte $C0 ; |XX......|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $C0 ; |XX......|
    .byte $C0 ; |XX......|
    .byte $C0 ; |XX......|
    .byte $E0 ; |XXX.....|
    .byte $E0 ; |XXX.....|
    .byte $70 ; |.XXX....|
    .byte $38 ; |..XXX...|
    .byte $1E ; |...XXXX.|
PF1Room1:
    .byte $FF ; |XXXXXXXX|
    .byte $FF ; |XXXXXXXX|
    .byte $C0 ; |XX......|
    .byte $C0 ; |XX......|
    .byte $C0 ; |XX......|
    .byte $C0 ; |XX......|
    .byte $C0 ; |XX......|
    .byte $C1 ; |XX.....X|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $C0 ; |XX......|
    .byte $C0 ; |XX......|
    .byte $C1 ; |XX.....X|
    .byte $C0 ; |XX......|
    .byte $C0 ; |XX......|
    .byte $C0 ; |XX......|
    .byte $FF ; |XXXXXXXX|
    .byte $FF ; |XXXXXXXX|
PF1Room2:
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $03 ; |......XX|
    .byte $FF ; |XXXXXXXX|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $FF ; |XXXXXXXX|
    .byte $03 ; |......XX|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
PF1Room3:
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $C0 ; |XX......|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $C0 ; |XX......|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
PF1Room4:
    .byte $7F ; |.XXXXXXX|
    .byte $40 ; |.X......|
    .byte $40 ; |.X......|
    .byte $40 ; |.X......|
    .byte $40 ; |.X......|
    .byte $40 ; |.X......|
    .byte $C0 ; |XX......|
    .byte $C0 ; |XX......|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $03 ; |......XX|
    .byte $03 ; |......XX|
    .byte $0C ; |....XX..|
    .byte $0C ; |....XX..|
    .byte $F0 ; |XXXX....|
    .byte $F0 ; |XXXX....|
    .byte $40 ; |.X......|
    .byte $40 ; |.X......|
    .byte $40 ; |.X......|
    .byte $40 ; |.X......|
    .byte $40 ; |.X......|
    .byte $7F ; |.XXXXXXX|
    align 256
PF2Room0:
    .byte $1F ; |XXXXX...| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $1C ; |..XXX...| mirrored
    .byte $1C ; |..XXX...| mirrored
    .byte $1E ; |.XXXX...| mirrored
    .byte $5E ; |.XXXX.X.| mirrored
    .byte $6E ; |.XXX.XX.| mirrored
    .byte $CE ; |.XXX..XX| mirrored
    .byte $C0 ; |......XX| mirrored
    .byte $F8 ; |...XXXXX| mirrored
PF2Room1:
    .byte $FF ; |XXXXXXXX| mirrored
    .byte $FF ; |XXXXXXXX| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $63 ; |XX...XX.| mirrored
    .byte $73 ; |XX..XXX.| mirrored
    .byte $21 ; |X....X..| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $63 ; |XX...XX.| mirrored
    .byte $73 ; |XX..XXX.| mirrored
    .byte $21 ; |X....X..| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $FF ; |XXXXXXXX| mirrored
    .byte $FF ; |XXXXXXXX| mirrored
PF2Room2:
    .byte $1C ; |..XXX...| mirrored
    .byte $06 ; |.XX.....| mirrored
    .byte $06 ; |.XX.....| mirrored
    .byte $06 ; |.XX.....| mirrored
    .byte $06 ; |.XX.....| mirrored
    .byte $06 ; |.XX.....| mirrored
    .byte $03 ; |XX......| mirrored
    .byte $01 ; |X.......| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $01 ; |X.......| mirrored
    .byte $03 ; |XX......| mirrored
    .byte $06 ; |.XX.....| mirrored
    .byte $06 ; |.XX.....| mirrored
    .byte $06 ; |.XX.....| mirrored
    .byte $06 ; |.XX.....| mirrored
    .byte $06 ; |.XX.....| mirrored
    .byte $1C ; |..XXX...| mirrored
PF2Room3:
    .byte $E0 ; |.....XXX| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $38 ; |...XXX..| mirrored
    .byte $28 ; |...X.X..| mirrored
    .byte $38 ; |...XXX..| mirrored
    .byte $28 ; |...X.X..| mirrored
    .byte $F8 ; |...XXXXX| mirrored
    .byte $F0 ; |....XXXX| mirrored
    .byte $E0 ; |.....XXX| mirrored
PF2Room4:
    .byte $FF ; |XXXXXXXX| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $03 ; |XX......| mirrored
    .byte $03 ; |XX......| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $FF ; |XXXXXXXX| mirrored

