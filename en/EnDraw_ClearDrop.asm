;==============================================================================
; mzxrules 2022
;==============================================================================

EnDraw_ItemDrop: SUBROUTINE
    lda en0X,x
    sta enX
    lda en0Y,x
    sta enY
    ldy cdItemType,x
    jmp EnDraw_Item

EnDraw_Stairs: SUBROUTINE
    lda en0X,x
    sta enX
    lda en0Y,x
    sta enY
    lda rFgColor
    sta wEnColor
    lda #<SprItem31
    sta enSpr
    lda #>SprItem31
    sta enSpr+1
    rts

    LOG_SIZE "EnDraw_ClearDrop", EnDraw_ClearDrop