;==============================================================================
; mzxrules 2024
;==============================================================================

EnDraw_Armos: SUBROUTINE
    lda #<[#SprE30-1]
    sta enSpr
    lda #>[#SprE30-1]
    sta enSpr+1

    lda #8
    sta wENH
    lda enState,x
    and #EN_ARMOS_STATE_DOUBLE
    ora #%10000
    sta wNUSIZ1_T

    lda enState,x
    and #EN_ARMOS_STATE_UNFROZEN
    bne .enemyColor
    lda rFgColor
    jmp EnDraw_PosAndStunColor_NoDynamicColor

.enemyColor
    ldy #CI_EN_RED
    jmp EnDraw_PosAndStunColor
    LOG_SIZE "EnDraw_Armos", EnDraw_Armos