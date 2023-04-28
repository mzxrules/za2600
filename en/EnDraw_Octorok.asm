;==============================================================================
; mzxrules 2022
;==============================================================================

EnDraw_Octorok: SUBROUTINE
    lda en0X,x
    sta enX
    lda en0Y,x
    sta enY

    lda #>SprE4
    sta enSpr+1

    lda enState,x
    rol
    rol
    and #1
    tay
    lda enStun,x
    asl
    asl
    adc EnDraw_OctorokColors,y
    sta wEnColor

    ldy enDir,x
    lda Mul8,y
    clc
    adc #<SprE4
    sta enSpr
    rts

EnDraw_OctorokColors
    .byte COLOR_EN_ROK_BLUE, COLOR_EN_RED

    LOG_SIZE "EnDraw_Octorok", EnDraw_Octorok