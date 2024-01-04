;==============================================================================
; mzxrules 2022
;==============================================================================

EnDraw_Octorok: SUBROUTINE
    lda enState,x
    rol
    rol
    and #1
    tay
    lda EnDraw_OctorokColors,y
    jsr EnDraw_PosAndStunColor

    lda #>SprE4
    sta enSpr+1
    ldy enDir,x
    lda Mul8,y
    clc
    adc #<SprE4
    sta enSpr

    jmp EnDraw_SmallMissile

EnDraw_OctorokColors
    .byte COLOR_EN_RED, COLOR_EN_ROK_BLUE

    LOG_SIZE "EnDraw_Octorok", EnDraw_Octorok