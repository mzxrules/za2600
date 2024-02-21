;==============================================================================
; mzxrules 2024
;==============================================================================

EnDraw_Tektite: SUBROUTINE
    lda enState,x
    and #1
    tay
    lda EnDraw_TektiteColors,y
    tay
    jsr EnDraw_PosAndStunColor

    lda #>SprE12
    sta enSpr+1
    lda enState,x
    lsr
    and #1
    tay
    lda Mul8,y
    clc
    adc #<SprE12
    sta enSpr
    rts

    LOG_SIZE "EnDraw_Tektite", EnDraw_Tektite