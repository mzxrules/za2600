;==============================================================================
; mzxrules 2025
;==============================================================================

EnDraw_Item: SUBROUTINE ; y == ItemId to draw
    lda #>SprItem0
    sta enSpr+1
    lda GiItemSpr,y
    sta enSpr

    lda GiItemColors,y
    tax
    lda Frame
    and #$10
    beq .setItemColor
    cpy #GI_POWER
    bne .test_two
    ldx #COLOR_EN_RED
    bne .setItemColor ; jmp
.test_two
    cpy #GI_TRIFORCE+1
    bpl .setItemColor
    ldx #COLOR_EN_LIGHT_BLUE
.setItemColor
    stx wEnColor
    rts