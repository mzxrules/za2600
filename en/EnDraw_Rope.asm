;==============================================================================
; mzxrules 2022
;==============================================================================

EnDraw_Rope: SUBROUTINE
    lda en0X,x
    sta enX
    lda en0Y,x
    sta enY
    lda #>SprE20
    sta enSpr+1
    lda enStun,x
    asl
    asl
    adc #COLOR_EN_TRIFORCE
    sta wEnColor
    ldy enDir,x
    lda .sprites,y
    sta enSpr
    rts
.sprites
    .byte #<SprE20, #<SprE21, #<SprE20, #<SprE21

    LOG_SIZE "EnDraw_Rope", EnDraw_Rope
