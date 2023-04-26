;==============================================================================
; mzxrules 2022
;==============================================================================

EnDraw_Darknut: SUBROUTINE
    lda en0X,x
    sta enX
    lda en0Y,x
    sta enY
    lda #>SprE0
    sta enSpr+1
    lda enStun,x
    asl
    asl
    adc #COLOR_EN_RED
    sta wEnColor
    lda enDir,x
    and #3
    asl
    asl
    asl
    sta enSpr
    rts
    LOG_SIZE "EnDraw_Darknut", EnDraw_Darknut