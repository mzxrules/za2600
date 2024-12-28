;==============================================================================
; mzxrules 2024
;==============================================================================

PlDraw_FluteFx: SUBROUTINE
    lda plItem2Time
    and #3
    tax
    lda plm1Y
    clc
    adc PlayerTornadoAnimOffY-1,x
    sta m0Y
    lda PlayerTornadoAnimWidth-1,x
    sta wNUSIZ0_T
    lda PlayerTornadoAnimHeight-1,x
    sta wM0H
    lda plm1X
    clc
    adc PlayerTornadoAnimOffX-1,x
    sta m0X
    rts

PlayerTornadoAnimOffX:
    .byte 2, -2, 0

PlayerTornadoAnimOffY:
    .byte 2, 4, 0

PlayerTornadoAnimHeight:
    .byte 2, 2, 1

PlayerTornadoAnimWidth:
    .byte $20, $30, $10