;==============================================================================
; mzxrules 2022
;==============================================================================

EnDraw_OldMan: SUBROUTINE
    ; Draw Routine
    lda #COLOR_EN_RED
    sta wEnColor
    lda #<SprS0
    sta enSpr
    lda #>SprS0
    sta enSpr+1
    rts

    LOG_SIZE "EnDraw_OldMan", EnDraw_OldMan