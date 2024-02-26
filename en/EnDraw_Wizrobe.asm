;==============================================================================
; mzxrules 2024
;==============================================================================

EnDraw_Wizrobe: SUBROUTINE
    ldy #CI_EN_BLUE
    lda enType,x
    cmp #EN_WIZROBE
    bne .set_color
    ldy #CI_EN_RED
.set_color
    jsr EnDraw_PosAndStunColor

    lda #>SprE28
    sta enSpr+1
    ldy enDir,x
    lda EnWizrobe_SprL,y
    sta enSpr
    jmp EnDraw_Wave

EnWizrobe_SprL:
    .byte #<SprE28, #<SprE29, #<SprE30, #<SprE28