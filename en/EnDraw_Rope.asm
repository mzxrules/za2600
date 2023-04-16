;==============================================================================
; mzxrules 2022
;==============================================================================

EnDraw_Rope: SUBROUTINE
    lda #>SprE20
    sta enSpr+1
    lda enStun
    asl
    asl
    adc #COLOR_EN_TRIFORCE
    sta wEnColor
    ldx enDir
    ldy .sprites,x
    sty enSpr
    rts
.sprites
    .byte #<SprE20, #<SprE21, #<SprE20, #<SprE21

    LOG_SIZE "EnDraw_Rope", EnDraw_Rope
