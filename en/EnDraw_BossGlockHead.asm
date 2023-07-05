;==============================================================================
; mzxrules 2023
;==============================================================================
EnDraw_BossGlockHead: SUBROUTINE

    ldx en1X
    stx enX
    lda en1Y
    sta enY

    lda #COLOR_EN_RED
    sta wEnColor

    lda Frame
    rol
    bcs .altDraw

    lda #>SprE22
    sta enSpr+1
    lda #<SprE22
    sta enSpr
    rts

.altDraw
    lda #>SprE24
    sta enSpr+1
    lda #<SprE24
    sta enSpr
    rts