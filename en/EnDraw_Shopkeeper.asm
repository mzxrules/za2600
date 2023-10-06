;==============================================================================
; mzxrules 2022
;==============================================================================

EnDraw_NpcShopkeeper: SUBROUTINE
    ldy #$F0
    bit enState
    bvs .noDraw
    ldy #GI_RUPEE
    jsr EnItemDraw

    lda #%0110
    sta wNUSIZ1_T

    lda #$20
    sta enX
    ldy #$28
.noDraw
    sty enY
    rts
    LOG_SIZE "EnDraw_NpcShopkeeper", EnDraw_NpcShopkeeper