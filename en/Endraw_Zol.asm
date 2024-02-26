;==============================================================================
; mzxrules 2024
;==============================================================================

EnDraw_Zol: SUBROUTINE
    ldy #CI_EN_BLACK
    jsr EnDraw_PosAndStunColor

    lda #>SprE22
    sta enSpr+1

    lda Frame
    lsr
    and #8
    clc
    adc #<SprE22
    sta enSpr
    rts