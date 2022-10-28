;==============================================================================
; mzxrules 2022
;==============================================================================

RsInit_BlockDiamondStairs: SUBROUTINE
    lda #$80
    sta blY
    lda #RF_NO_ENCLEAR
    ora roomFlags
    sta roomFlags

    ldx #$40
    ldy #$2C
    cpx plX
    bne .initPos
    cpy plY
    bne .initPos

    lda #0
    sta wPF2Room + 13
    sta wPF2Room + 14
    rts

.initPos
    lda #BL_DIAMOND_PUSH_BLOCK
    sta blType
    rts