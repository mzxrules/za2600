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

    lda miType,x
    bpl .rts

    lda #1
    sta wM1H
    lda mi0X,x
    sta m1X
    lda mi0Y,x
    sta m1Y
    lda rNUSIZ1_T
    ora %10000
    sta wNUSIZ1_T
.rts
    rts

EnDraw_OctorokColors
    .byte COLOR_EN_RED, COLOR_EN_ROK_BLUE

    LOG_SIZE "EnDraw_Octorok", EnDraw_Octorok