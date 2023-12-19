;==============================================================================
; mzxrules 2023
;==============================================================================
EnDraw_Stalfos: SUBROUTINE
    lda en0X,x
    sta enX
    lda en0Y,x
    sta enY

    lda enState,x
    lsr
    and #1
    tay

    lda #>SprE12
    sta enSpr+1
    lda enStun,x
    asl
    asl
    adc #COLOR_WHITE
    sta wEnColor

    lda #<SprE12
    sta enSpr
    rts
    LOG_SIZE "EnDraw_Stalfos", EnDraw_Stalfos
