;==============================================================================
; mzxrules 2023
;==============================================================================
EnDraw_NpcPath: SUBROUTINE
    lda #COLOR_GRAY
    sta wEnColor
    lda #<SprItem31
    sta enSpr
    lda #>SprItem31
    sta enSpr+1

    lda #%0110
    sta wNUSIZ1_T

    lda #$20
    sta enX
    ldy #$28
.noDraw
    sty enY
    rts