EnMoveDir:
    ldy enDir,x
EnMoveDel:
    lda en0X,x      ; 4
    clc             ; 2
    adc EnMoveDeltaX,y   ; 4
    sta en0X,x      ; 4 (14)

    lda en0Y,x      ; 4
    clc             ; 2
    adc EnMoveDeltaY,y   ; 4
    sta en0Y,x      ; 4 (28)

    rts             ; 6 (34)

EnMoveNextDel:
    ldx enNum
    lda enNX,x
    clc                 ; 2
    adc EnMoveDeltaX,y  ; 4
    sta enNX,x

    lda enNY,x
    clc                 ; 2
    adc EnMoveDeltaY,y  ; 4
    sta enNY,x
    rts                 ; 6

EnMoveDeltaX:
    .byte -1,  1,  0,  0 ; cardinals
    .byte -1, -1,  1,  1 ; diagonals

EnMoveDeltaY:
    .byte  0,  0,  1, -1 ; cardinals
    .byte  1, -1,  1, -1 ; diagonals


nextdir_step_lut:
    .byte 16, 17, 18, 19, 20, 21, 22, 23
    .byte  0,  1,  2,  3,  4,  5,  6,  7
    .byte  8,  9, 10, 11, 12, 13, 14, 15

    INCLUDE "gen/nextdir.asm"
    INCLUDE "gen/roomcollision.asm"