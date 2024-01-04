;==============================================================================
; mzxrules 2022
;==============================================================================

EnDraw_LikeLike: SUBROUTINE
    lda #>SprE16
    sta enSpr+1
    lda Frame
    and #8
    clc
    adc #<SprE16
    sta enSpr

    lda #COLOR_EN_RED
    jmp EnDraw_PosAndStunColor

    LOG_SIZE "EnDraw_LikeLike", EnDraw_LikeLike