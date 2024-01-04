;==============================================================================
; mzxrules 2023
;==============================================================================

EnDraw_TestMissile: SUBROUTINE
    lda enTestMissileResult
    sta wEnColor
    lda #<SprE30
    sta enSpr
    lda #>SprE30
    sta enSpr+1

    lda #$7C
    sta enX
    lda #$40
    sta enY

    clc
    lda mi0X,x
    adc #3+1
    sta m1X
    clc
    lda mi0Y,x
    adc #3
    sta m1Y

; 2x2 Missile
    lda #1
    sta wM1H
    lda rNUSIZ1_T
    and %11001111
    ora %00010000
    sta wNUSIZ1_T

    rts