;==============================================================================
; mzxrules 2022
;==============================================================================

EnDraw_LikeLike: SUBROUTINE
    lda en0X,x
    sta enX
    lda en0Y,x
    sta enY

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