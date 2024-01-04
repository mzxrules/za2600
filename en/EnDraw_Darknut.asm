;==============================================================================
; mzxrules 2022
;==============================================================================

EnDraw_Darknut: SUBROUTINE
    lda #>SprE0
    sta enSpr+1
    lda enDir,x
    and #3
    asl
    asl
    asl
    sta enSpr

    lda enState,x
    lsr
    and #1
    tay
    lda EnDraw_DarknutColor,y
    jmp EnDraw_PosAndStunColor
    LOG_SIZE "EnDraw_Darknut", EnDraw_Darknut

EnDraw_DarknutColor:
    .byte #COLOR_EN_RED, #COLOR_EN_BLUE