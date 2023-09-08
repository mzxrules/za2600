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
    lda cdBX
    sta enX
    lda cdBY
    sta enY

    ldy cdBType
    jmp EnItemDraw
.DrawTypeA
    lda cdAX
    sta enX
    lda cdAY
    sta enY

    lda cdAType
    cmp #EN_STAIRS
    beq .EnStairs
    cmp #EN_ITEM
    bne .noDraw
    ldy roomEX
    jmp EnItemDraw

.EnStairs:
    lda rFgColor
    sta wEnColor
    lda #<SprItem31
    sta enSpr
    lda #>SprItem31
    sta enSpr+1
    rts

    LOG_SIZE "EnDraw_ClearDrop", EnDraw_ClearDrop