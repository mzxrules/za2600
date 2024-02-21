;==============================================================================
; mzxrules 2024
;==============================================================================

EnDraw_Vire: SUBROUTINE
    ldy #CI_EN_BLUE
    jsr EnDraw_PosAndStunColor

    lda #>SprE26
    sta enSpr+1
    lda Frame
    lsr
    and #8
    clc
    adc #<SprE26
    sta enSpr
    rts

    LOG_SIZE "EnDraw_Vire", EnDraw_Vire