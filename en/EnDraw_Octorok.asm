;==============================================================================
; mzxrules 2022
;==============================================================================

EnDraw_Octorok: SUBROUTINE
    lda #COLOR_EN_ROK_BLUE
    sta enColor
    lda #>SprE4
    sta enSpr+1
    ldx enDir
    lda Mul8,x
    clc 
    adc #<SprE4
    sta enSpr
    rts
    
    LOG_SIZE "EnDraw_Octorok", EnDraw_Octorok