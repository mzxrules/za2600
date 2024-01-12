;==============================================================================
; mzxrules 2024
;==============================================================================

EnDraw_Goriya: SUBROUTINE
    lda enState,x
    and #1
    tay
    lda EnDraw_GoriyaColor,y
    tay
    jsr EnDraw_PosAndStunColor

    lda #>SprE4
    sta enSpr+1
    ldy enDir,x
    lda Mul8,y
    clc
    adc #<SprE4
    sta enSpr

    jmp EnDraw_SmallMissile

    LOG_SIZE "EnDraw_Goriya", EnDraw_Goriya