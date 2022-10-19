;==============================================================================
; mzxrules 2022
;==============================================================================

EnDraw_Darknut: SUBROUTINE
    lda #>SprE0
    sta enSpr+1
    lda enStun
    asl
    asl
    adc #COLOR_EN_RED
    sta enColor
    ldx enDir
    ldy Mul8,x
    sty enSpr
    rts
    LOG_SIZE "EnDraw_Darknut", EnDraw_Darknut