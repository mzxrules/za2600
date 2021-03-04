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
    .byte $FA ; |XXXXX.X.|
    .byte $FF ; |XXXXXXXX|
    .byte $ED ; |XXX.XX.X|
    .byte $C9 ; |XX..X..X|
    .byte $7E ; |.XXXXXX.|
    align 256
PF1Entrance0:
    .byte $00 ; |........|
    .byte $FF ; |XXXXXXXX|
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
    .byte $03 ; |......XX|
PF2Entrance0:
    .byte $00 ; |........| mirrored
    .byte $1F ; |XXXXX...| mirrored
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
    .byte $00 ; |........| mirrored
    .byte $1C ; |..XXX...| mirrored
    .byte $1C ; |..XXX...| mirrored
    .byte $1E ; |.XXXX...| mirrored
    .byte $5E ; |.XXXX.X.| mirrored
    .byte $6E ; |.XXX.XX.| mirrored
    .byte $CE ; |.XXX..XX| mirrored
    .byte $C0 ; |......XX| mirrored
    .byte $F9 ; |X..XXXXX| mirrored
PF1Entrance1:
    .byte $00 ; |........|
    .byte $FF ; |XXXXXXXX|
    .byte $FF ; |XXXXXXXX|
    .byte $C0 ; |XX......|
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
    .byte $C0 ; |XX......|
    .byte $FF ; |XXXXXXXX|
    .byte $FF ; |XXXXXXXX|
PF2Entrance1:
    .byte $00 ; |........| mirrored
    .byte $FF ; |XXXXXXXX| mirrored
    .byte $FF ; |XXXXXXXX| mirrored
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
    .byte $FF ; |XXXXXXXX| mirrored
    .byte $FF ; |XXXXXXXX| mirrored
PF1Entrance2:
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $03 ; |......XX|
    .byte $FF ; |XXXXXXXX|
    .byte $C0 ; |XX......|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $C0 ; |XX......|
    .byte $FF ; |XXXXXXXX|
    .byte $03 ; |......XX|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
PF2Entrance2:
    .byte $00 ; |........| mirrored
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
PF1Entrance3:
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $01 ; |.......X|
    .byte $03 ; |......XX|
    .byte $0E ; |....XXX.|
    .byte $18 ; |...XX...|
    .byte $F0 ; |XXXX....|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $03 ; |......XX|
    .byte $04 ; |.....X..|
    .byte $08 ; |....X...|
    .byte $F0 ; |XXXX....|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
PF2Entrance3:
    .byte $00 ; |........| mirrored
    .byte $F8 ; |...XXXXX| mirrored
    .byte $0E ; |.XXX....| mirrored
    .byte $03 ; |XX......| mirrored
    .byte $01 ; |X.......| mirrored
    .byte $01 ; |X.......| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $01 ; |X.......| mirrored
    .byte $01 ; |X.......| mirrored
    .byte $03 ; |XX......| mirrored
    .byte $3E ; |.XXXXX..| mirrored
    .byte $20 ; |.....X..| mirrored
    .byte $38 ; |...XXX..| mirrored
    .byte $28 ; |...X.X..| mirrored
    .byte $38 ; |...XXX..| mirrored
    .byte $28 ; |...X.X..| mirrored
    .byte $F8 ; |...XXXXX| mirrored
    .byte $F0 ; |....XXXX| mirrored
    .byte $E0 ; |.....XXX| mirrored
PF1Entrance4:
    .byte $00 ; |........|
    .byte $F8 ; |XXXXX...|
    .byte $0E ; |....XXX.|
    .byte $03 ; |......XX|
    .byte $01 ; |.......X|
    .byte $01 ; |.......X|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $01 ; |.......X|
    .byte $01 ; |.......X|
    .byte $03 ; |......XX|
    .byte $3E ; |..XXXXX.|
    .byte $20 ; |..X.....|
    .byte $38 ; |..XXX...|
    .byte $28 ; |..X.X...|
    .byte $38 ; |..XXX...|
    .byte $28 ; |..X.X...|
    .byte $F8 ; |XXXXX...|
    .byte $F0 ; |XXXX....|
    .byte $E0 ; |XXX.....|
PF2Entrance4:
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $01 ; |X.......| mirrored
    .byte $FF ; |XXXXXXXX| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $FF ; |XXXXXXXX| mirrored
    .byte $01 ; |X.......| mirrored
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

