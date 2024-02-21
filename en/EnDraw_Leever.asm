;==============================================================================
; mzxrules 2024
;==============================================================================

EnDraw_Leever: SUBROUTINE
    lda enState,x
    rol
    rol
    rol
    and #1
    tay
    lda EnDraw_LeeverColors,y
    tay
    jsr EnDraw_PosAndStunColor

    lda enState,x
    and #3
    asl
    tay
    lda Frame
    and #4
    beq .skipInc
    iny
.skipInc

    lda EnLeever_SprH,y
    sta enSpr+1
    lda EnLeever_SprL,y
    sta enSpr
    rts

EnLeever_SprH:
    .byte #>SprE18, #>SprE19
    .byte #>SprE17, #>SprE17
    .byte #>SprE20, #>SprE21

EnLeever_SprL:
    .byte #<SprE18, #<SprE19
    .byte #<SprE17, #<SprE17
    .byte #<SprE20, #<SprE21

    LOG_SIZE "EnDraw_Leever", EnDraw_Leever