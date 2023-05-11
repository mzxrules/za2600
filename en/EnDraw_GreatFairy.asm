;==============================================================================
; mzxrules 2023
;==============================================================================

EnDraw_GreatFairy: SUBROUTINE

    lda #>SprItem0
    sta enSpr+1

    lda enGFairyDie
    bne .custom

.flicker
    lda #<SprItem0
    sta enSpr
    rts

.custom
    ldy #0
    cmp #EN_GREAT_FAIRY_DIE+6
    bmi .testFlicker
    iny
    cmp #-24
    bmi .testFlicker
    iny

.testFlicker
    and EnDraw_GreatFairy_Flicker,y
    bne .flicker

.solid
    lda #<SprItem0 + #GI_FAIRY*8
    sta enSpr
    lda #COLOR_EN_RED
    sta wEnColor
    rts

EnDraw_GreatFairy_Flicker:
    .byte 0, 1, 3