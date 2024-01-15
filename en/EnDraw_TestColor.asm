;==============================================================================
; mzxrules 2024
;==============================================================================
EnDraw_TestColor: SUBROUTINE
    lda en0X,x
    sta enX
    lda en0Y,x
    sta enY

    lda #>SprItem5
    sta enSpr+1
    lda #<SprItem5
    sta enSpr
    lda enTestColorEnColor
    sta wEnColor
    rts