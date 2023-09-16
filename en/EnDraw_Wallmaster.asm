;==============================================================================
; mzxrules 2022
;==============================================================================

EnDraw_Wallmaster: SUBROUTINE
    lda en0X,x
    sta enX
    lda en0Y,x
    sta enY

    lda #>SprE10
    sta enSpr+1
    lda enWallPhase
    lsr
    clc
    adc #<SprE10-8
    sta enSpr
    lda #COLOR_BLACK
    sta wEnColor
    rts

    LOG_SIZE "EnDraw_Wallmaster", EnDraw_Wallmaster