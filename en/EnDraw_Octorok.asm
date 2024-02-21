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
    tay
    jsr EnDraw_PosAndStunColor

    lda #>SprE8
    sta enSpr+1
    ldy enDir,x
    lda Mul8,y
    clc
    adc #<SprE8
    sta enSpr
    jmp EnDraw_SmallMissile

    LOG_SIZE "EnDraw_Octorok", EnDraw_Octorok