;==============================================================================
; mzxrules 2022
;==============================================================================

EnDraw_Rope: SUBROUTINE
    lda #>SprE18
    sta enSpr+1
    ldy enDir,x
    lda .sprites,y
    sta enSpr

    ldy #CI_EN_YELLOW
    jmp EnDraw_PosAndStunColor

.sprites
    .byte #<SprE18, #<SprE19, #<SprE18, #<SprE19

    LOG_SIZE "EnDraw_Rope", EnDraw_Rope
