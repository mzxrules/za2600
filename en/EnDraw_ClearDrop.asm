;==============================================================================
; mzxrules 2022
;==============================================================================

EnDraw_ClearDrop: SUBROUTINE
    lda enState
    bne .execute
.noDraw
    lda #$F0
    sta enSpr+1
    lda #$00
    sta enSpr
    rts

.execute
    and #1
    beq .DrawTypeA
.DrawTypeB
    ldy cdBType
    jmp EnItemDraw
.DrawTypeA
    lda cdAType
    cmp #EN_STAIRS
    beq .EnStairs
    cmp #EN_ITEM
    bne .noDraw
    ldy roomEX
    jmp EnItemDraw
    
.EnStairs:
    lda rFgColor
    sta enColor
    lda #<SprItem31
    sta enSpr
    lda #>SprItem31
    sta enSpr+1
    rts

    LOG_SIZE "EnDraw_ClearDrop", EnDraw_ClearDrop