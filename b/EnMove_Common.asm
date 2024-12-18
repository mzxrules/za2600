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


EnMoveDeltaX:
    .byte -1,  1,  0,  0 ; cardinals
    .byte -1, -1,  1,  1 ; diagonals
    .byte -4,  4,  0,  0 ; cardinals 4x

EnMoveDeltaY:
    .byte  0,  0,  1, -1 ; cardinals
    .byte  1, -1,  1, -1 ; diagonals
    .byte  0,  0,  4, -4 ; cardinals 4x

EnMoveBounce:
    .byte EN_DIR_R
    .byte EN_DIR_L
    .byte EN_DIR_D
    .byte EN_DIR_U

EnMoveBounceDiagonal:
    .byte EN_DIR_RD
    .byte EN_DIR_RU
    .byte EN_DIR_LD
    .byte EN_DIR_LU

    INCLUDE "gen/nextdir.asm"
    INCLUDE "gen/roomcollision.asm"