;==============================================================================
; mzxrules 2024
;==============================================================================

EnDraw_Peehat: SUBROUTINE
    ldy #CI_EN_RED
    jsr EnDraw_PosAndStunColor

    ldy #0
    lda enState,x
    and #EN_PEEHAT_ANIM
    bne .set_spr
    iny
.set_spr

    lda #>SprE14
    sta enSpr+1
    lda Mul8,y
    clc
    adc #<SprE14
    sta enSpr
    rts

    LOG_SIZE "EnDraw_Peehat", EnDraw_Peehat