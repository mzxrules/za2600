;==============================================================================
; mzxrules 2024
;==============================================================================

EnDraw_Pols: SUBROUTINE
    lda #>SprE12
    sta enSpr+1
    lda #<SprE12
    sta enSpr

    ldy #CI_EN_YELLOW
    jmp EnDraw_PosAndStunColor