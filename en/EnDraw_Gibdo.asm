;==============================================================================
; mzxrules 2024
;==============================================================================

EnDraw_Gibdo: SUBROUTINE
    lda #>SprE20
    sta enSpr+1
    ldy enDir,x
    lda .sprites,y
    sta enSpr

    ldy #CI_EN_WHITE
    jmp EnDraw_PosAndStunColor

.sprites
    .byte #<SprE20, #<SprE21, #<SprE20, #<SprE21

    LOG_SIZE "EnDraw_Gibdo", EnDraw_Gibdo
