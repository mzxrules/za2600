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
    .byte $36 ; |..XX.XX.|
    .byte $24 ; |..X..X..|
    .byte $19 ; |...XX..X|
    .byte $99 ; |X..XX..X|
    .byte $F9 ; |XXXXX..X|
    .byte $FD ; |XXXXXX.X|
    .byte $68 ; |.XX.X...|
    .byte $3C ; |..XXXX..|
SprP1:
    .byte $6C ; |.XX.XX..|
    .byte $24 ; |..X..X..|
    .byte $99 ; |X..XX..X|
    .byte $99 ; |X..XX..X|
    .byte $9B ; |X..XX.XX|
    .byte $BE ; |X.XXXXX.|
    .byte $16 ; |...X.XX.|
    .byte $3C ; |..XXXX..|
SprP2:
    .byte $66 ; |.XX..XX.|
    .byte $24 ; |..X..X..|
    .byte $D8 ; |XX.XX...|
    .byte $D9 ; |XX.XX..X|
    .byte $DB ; |XX.XX.XX|
    .byte $BE ; |X.XXXXX.|
    .byte $16 ; |...X.XX.|
    .byte $3C ; |..XXXX..|
SprP3:
    .byte $66 ; |.XX..XX.|
    .byte $24 ; |..X..X..|
    .byte $1B ; |...XX.XX|
    .byte $9B ; |X..XX.XX|
    .byte $DB ; |XX.XX.XX|
    .byte $7D ; |.XXXXX.X|
    .byte $7C ; |.XXXXX..|
    .byte $3C ; |..XXXX..|
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
SprE6:
    .byte $E6 ; |XXX..XX.|
    .byte $7C ; |.XXXXX..|
    .byte $BD ; |X.XXXX.X|
    .byte $BD ; |X.XXXX.X|
    .byte $7D ; |.XXXXX.X|
    .byte $6B ; |.XX.X.XX|
    .byte $3D ; |..XXXX.X|
    .byte $28 ; |..X.X...|
SprE7:
    .byte $67 ; |.XX..XXX|
    .byte $3E ; |..XXXXX.|
    .byte $BD ; |X.XXXX.X|
    .byte $BD ; |X.XXXX.X|
    .byte $BE ; |X.XXXXX.|
    .byte $D6 ; |XX.X.XX.|
    .byte $BC ; |X.XXXX..|
    .byte $14 ; |...X.X..|
SprE8:
    .byte $67 ; |.XX..XXX|
    .byte $7E ; |.XXXXXX.|
    .byte $ED ; |XXX.XX.X|
    .byte $ED ; |XXX.XX.X|
    .byte $EE ; |XXX.XXX.|
    .byte $16 ; |...X.XX.|
    .byte $3C ; |..XXXX..|
    .byte $14 ; |...X.X..|
SprE9:
    .byte $3A ; |..XXX.X.|
    .byte $7D ; |.XXXXX.X|
    .byte $BE ; |X.XXXXX.|
    .byte $BD ; |X.XXXX.X|
    .byte $5B ; |.X.XX.XX|
    .byte $7C ; |.XXXXX..|
    .byte $3C ; |..XXXX..|
    .byte $28 ; |..X.X...|
SprE10:
    .byte $00 ; |........|
    .byte $08 ; |....X...|
    .byte $18 ; |...XX...|
    .byte $18 ; |...XX...|
    .byte $18 ; |...XX...|
    .byte $18 ; |...XX...|
    .byte $18 ; |...XX...|
    .byte $18 ; |...XX...|
SprE11:
    .byte $18 ; |...XX...|
    .byte $18 ; |...XX...|
    .byte $18 ; |...XX...|
    .byte $18 ; |...XX...|
    .byte $18 ; |...XX...|
    .byte $18 ; |...XX...|
    .byte $10 ; |...X....|
    .byte $00 ; |........|
SprE12:
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $FE ; |XXXXXXX.|
    .byte $FC ; |XXXXXX..|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
SprE13:
    .byte $7E ; |.XXXXXX.|
    .byte $00 ; |........|
    .byte $18 ; |...XX...|
    .byte $3C ; |..XXXX..|
    .byte $3C ; |..XXXX..|
    .byte $18 ; |...XX...|
    .byte $00 ; |........|
    .byte $00 ; |........|
SprE14:
    .byte $36 ; |..XX.XX.|
    .byte $24 ; |..X..X..|
    .byte $18 ; |...XX...|
    .byte $99 ; |X..XX..X|
    .byte $F9 ; |XXXXX..X|
    .byte $FD ; |XXXXXX.X|
    .byte $69 ; |.XX.X..X|
    .byte $3C ; |..XXXX..|
SprE15:
    .byte $6C ; |.XX.XX..|
    .byte $24 ; |..X..X..|
    .byte $19 ; |...XX..X|
    .byte $99 ; |X..XX..X|
    .byte $9B ; |X..XX.XX|
    .byte $BE ; |X.XXXXX.|
    .byte $96 ; |X..X.XX.|
    .byte $3C ; |..XXXX..|
SprE16:
    .byte $66 ; |.XX..XX.|
    .byte $24 ; |..X..X..|
    .byte $18 ; |...XX...|
    .byte $9B ; |X..XX.XX|
    .byte $DB ; |XX.XX.XX|
    .byte $7D ; |.XXXXX.X|
    .byte $68 ; |.XX.X...|
    .byte $3C ; |..XXXX..|
SprE17:
    .byte $66 ; |.XX..XX.|
    .byte $24 ; |..X..X..|
    .byte $18 ; |...XX...|
    .byte $D9 ; |XX.XX..X|
    .byte $DB ; |XX.XX.XX|
    .byte $BE ; |X.XXXXX.|
    .byte $3E ; |..XXXXX.|
    .byte $3C ; |..XXXX..|
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
    .byte $1F ; |...XXXXX|
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
    .byte $00 ; |........|
    .byte $FF ; |XXXXXXXX|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $FF ; |XXXXXXXX|
    .byte $00 ; |........|
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
PF1Room5:
    .byte $FF ; |XXXXXXXX|
    .byte $FF ; |XXXXXXXX|
    .byte $C0 ; |XX......|
    .byte $C0 ; |XX......|
    .byte $C0 ; |XX......|
    .byte $C0 ; |XX......|
    .byte $C0 ; |XX......|
    .byte $C0 ; |XX......|
    .byte $CC ; |XX..XX..|
    .byte $CC ; |XX..XX..|
    .byte $C3 ; |XX....XX|
    .byte $C3 ; |XX....XX|
    .byte $C0 ; |XX......|
    .byte $C0 ; |XX......|
    .byte $C0 ; |XX......|
    .byte $C0 ; |XX......|
    .byte $C0 ; |XX......|
    .byte $C0 ; |XX......|
    .byte $F0 ; |XXXX....|
    .byte $F0 ; |XXXX....|
    .byte $FF ; |XXXXXXXX|
    .byte $FF ; |XXXXXXXX|
PF1Room6:
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $0E ; |....XXX.|
    .byte $08 ; |....X...|
    .byte $0A ; |....X.X.|
    .byte $09 ; |....X..X|
    .byte $0A ; |....X.X.|
    .byte $00 ; |........|
    .byte $0A ; |....X.X.|
    .byte $09 ; |....X..X|
    .byte $0A ; |....X.X.|
    .byte $08 ; |....X...|
    .byte $0E ; |....XXX.|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
PF1Room7:
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $10 ; |...X....|
    .byte $10 ; |...X....|
    .byte $10 ; |...X....|
    .byte $08 ; |....X...|
    .byte $38 ; |..XXX...|
PF1Room8:
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $38 ; |..XXX...|
    .byte $28 ; |..X.X...|
    .byte $38 ; |..XXX...|
    .byte $28 ; |..X.X...|
    .byte $38 ; |..XXX...|
PF1Room9:
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $38 ; |..XXX...|
    .byte $08 ; |....X...|
    .byte $38 ; |..XXX...|
    .byte $28 ; |..X.X...|
    .byte $38 ; |..XXX...|
PF1Room10:
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $28 ; |..X.X...|
    .byte $28 ; |..X.X...|
    .byte $38 ; |..XXX...|
    .byte $28 ; |..X.X...|
    .byte $38 ; |..XXX...|
PF1Room11:
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $00 ; |........|
    .byte $30 ; |..XX....|
    .byte $28 ; |..X.X...|
    .byte $30 ; |..XX....|
    .byte $28 ; |..X.X...|
    .byte $30 ; |..XX....|
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
    .byte $1C ; |..XXX...| mirrored
    .byte $1C ; |..XXX...| mirrored
    .byte $1E ; |.XXXX...| mirrored
    .byte $5E ; |.XXXX.X.| mirrored
    .byte $6E ; |.XXX.XX.| mirrored
    .byte $CE ; |.XXX..XX| mirrored
    .byte $C0 ; |......XX| mirrored
    .byte $F8 ; |...XXXXX| mirrored
    .byte $00 ; |........| mirrored
    .byte $FF ; |XXXXXXXX| mirrored
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
    .byte $1E ; |.XXXX...| mirrored
    .byte $02 ; |.X......| mirrored
    .byte $02 ; |.X......| mirrored
    .byte $02 ; |.X......| mirrored
    .byte $02 ; |.X......| mirrored
    .byte $02 ; |.X......| mirrored
    .byte $02 ; |.X......| mirrored
    .byte $03 ; |XX......| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $03 ; |XX......| mirrored
    .byte $02 ; |.X......| mirrored
    .byte $02 ; |.X......| mirrored
    .byte $02 ; |.X......| mirrored
    .byte $02 ; |.X......| mirrored
    .byte $02 ; |.X......| mirrored
    .byte $02 ; |.X......| mirrored
    .byte $1E ; |.XXXX...| mirrored
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
PF2Room5:
    .byte $FF ; |XXXXXXXX| mirrored
    .byte $FF ; |XXXXXXXX| mirrored
    .byte $03 ; |XX......| mirrored
    .byte $03 ; |XX......| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $03 ; |XX......| mirrored
    .byte $03 ; |XX......| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $0C ; |..XX....| mirrored
    .byte $0C ; |..XX....| mirrored
    .byte $3C ; |..XXXX..| mirrored
    .byte $3C ; |..XXXX..| mirrored
    .byte $CC ; |..XX..XX| mirrored
    .byte $0C ; |..XX....| mirrored
    .byte $F0 ; |....XXXX| mirrored
    .byte $F0 ; |....XXXX| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $FF ; |XXXXXXXX| mirrored
    .byte $FF ; |XXXXXXXX| mirrored
PF2Room6:
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $07 ; |XXX.....| mirrored
    .byte $04 ; |..X.....| mirrored
    .byte $05 ; |X.X.....| mirrored
    .byte $04 ; |..X.....| mirrored
    .byte $05 ; |X.X.....| mirrored
    .byte $00 ; |........| mirrored
    .byte $05 ; |X.X.....| mirrored
    .byte $04 ; |..X.....| mirrored
    .byte $05 ; |X.X.....| mirrored
    .byte $04 ; |..X.....| mirrored
    .byte $07 ; |XXX.....| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
PF2Room7:
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
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
PF2Room8:
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
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
PF2Room9:
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
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
PF2Room10:
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
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
PF2Room11:
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
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored
    .byte $00 ; |........| mirrored

