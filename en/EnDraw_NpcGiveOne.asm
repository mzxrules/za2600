;==============================================================================
; mzxrules 2022
;==============================================================================

EnDraw_NpcGiveOne: SUBROUTINE

    ldy #$F0
    bit enState
    bvs .noDraw
    ldy roomEX
    lda .NpcGiveOneItems,Y
    tay
    jsr EnItemDraw

    lda #$40
    sta enX
    ldy #$28
.noDraw
    sty enY
    rts

.NpcGiveOneItems:
    .byte GI_SWORD1
    .byte GI_SWORD2
    .byte GI_SWORD3
    .byte GI_NOTE