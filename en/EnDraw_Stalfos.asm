;==============================================================================
; mzxrules 2023
;==============================================================================
EnDraw_Stalfos: SUBROUTINE
    lda #>SprE11
    sta enSpr+1
    lda #<SprE11
    sta enSpr

    lda #COLOR_EN_WHITE
    jmp EnDraw_PosAndStunColor
    LOG_SIZE "EnDraw_Stalfos", EnDraw_Stalfos
