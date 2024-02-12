;==============================================================================
; mzxrules 2022
;==============================================================================

EnDraw_NpcGiveOne: SUBROUTINE
    ldy #$F0
    bit enState
    bvs .noDraw
    lda #MESG_MAX_LENGTH
    sta mesgDY
    ldy roomEX
    lda NpcGiveOneItems,y
    tay
    jsr EnItemDraw

    lda #$40
    sta enX
    ldy #$28
.noDraw
    sty enY
    rts