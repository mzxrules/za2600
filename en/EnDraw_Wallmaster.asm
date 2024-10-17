;==============================================================================
; mzxrules 2022
;==============================================================================

EnDraw_Wallmaster: SUBROUTINE
    lda #>SprE9
    sta enSpr+1
    lda enWallPhase,x
    lsr
    clc
    adc #<SprE9-8
    sta enSpr

    ldy #CI_EN_BLACK
    jmp EnDraw_PosAndStunColor

    LOG_SIZE "EnDraw_Wallmaster", EnDraw_Wallmaster