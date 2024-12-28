;==============================================================================
; mzxrules 2024
;==============================================================================

PlDraw_Item: SUBROUTINE
    jsr PlDraw_ItemDel

    ldx m0X
    lda Obj_ClampXLUT,x
    sta m0X
    rts

PlDraw_ItemDel: SUBROUTINE
    ldy plItemTimer ; Expected in some draw functions
    beq .drawSecondary
    lda plItem2Time
    ror
    bcs .drawSecondary

    lda plState2
    and #PS_ACTIVE_ITEM
    tax
    lda PlDrawItemH,x
    pha
    lda PlDrawItemL,x
    pha
    rts
.drawSecondary
    lda plItem2Time
    beq PlDraw_None
    lda plState3
    and #PS_ACTIVE_ITEM2
    tax
    lda PlDrawItemH+8,x
    pha
    lda PlDrawItemL+8,x
    pha
    rts

PlDraw_None:
    lda #$80
    sta m0Y
    rts
