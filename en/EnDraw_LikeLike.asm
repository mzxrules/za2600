;==============================================================================
; mzxrules 2022
;==============================================================================

EnDraw_LikeLike: SUBROUTINE
    ; Draw Routine
    lda #>SprE16
    sta enSpr+1
    lda Frame
    and #8
    clc
    adc #<SprE16
    sta enSpr
    lda enStun
    asl
    asl
    adc #COLOR_EN_RED
    sta wEnColor
    rts

    LOG_SIZE "EnDraw_LikeLike", EnDraw_LikeLike