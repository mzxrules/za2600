;==============================================================================
; mzxrules 2023
;==============================================================================

EnDraw_NpcPath: SUBROUTINE
    lda #MESG_MAX_LENGTH
    sta mesgDY

    lda #$20
    sta enX
    ldy #$28
    sty enY

    lda #COLOR_EN_GRAY_L
    sta wEnColor
    lda #<SprItem31
    sta enSpr
    lda #>SprItem31
    sta enSpr+1

    lda #%0110
    sta wNUSIZ1_T

    rts