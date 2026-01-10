;==============================================================================
; mzxrules 2025
;==============================================================================

EnItemDraw: SUBROUTINE ; y == itemDraw
    lda #>SprItem0
    sta enSpr+1
    lda GiItemColors,y
    tax
    cpy #GI_TRIFORCE+1
    bpl .skipItemColor
    lda Frame
    and #$10
    beq .skipItemColor
    ldx #COLOR_EN_LIGHT_BLUE
.skipItemColor
    stx wEnColor
    lda GiItemSpr,y
    clc
    adc #<SprItem0
    sta enSpr
    rts