;==============================================================================
; mzxrules 2024
;==============================================================================

EnDraw_Goriya: SUBROUTINE
    lda enState,x
    lsr
    and #1
    tay
    lda EnDraw_GoriyaColors,y
    tay
    jsr EnDraw_PosAndStunColor

    lda #>SprE4
    sta enSpr+1
    ldy enDir,x
    lda Mul8,y
    clc
    adc #<SprE4
    sta enSpr

    jmp EnDraw_Rang

    LOG_SIZE "EnDraw_Goriya", EnDraw_Goriya