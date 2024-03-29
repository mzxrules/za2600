;==============================================================================
; mzxrules 2022
;==============================================================================

RsInit_BlockDiamondStairs: SUBROUTINE
    lda #$80
    sta blY

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
    lda roomFlags
    ora #RF_NO_ENCLEAR
    sta roomFlags
    lda #BL_PUSH_BLOCK_DIAMOND_TOP
    sta blType
    rts