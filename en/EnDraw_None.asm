;==============================================================================
; mzxrules 2022
;==============================================================================

EnDraw_None: SUBROUTINE
    lda #>SprItem0
    sta enSpr+1
    lda #<SprItem0
    sta enSpr
    rts
    LOG_SIZE "EnDraw_None", EnDraw_None