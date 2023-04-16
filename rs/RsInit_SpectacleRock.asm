;==============================================================================
; mzxrules 2022
;==============================================================================

RsInit_SpectacleRock: SUBROUTINE
    ldy #$6
    lda rPF2Room,y
    and #$F9
    sta wPF2Room,y
    sta wPF2Room+1,y
    lda #$58
    sta enX
    lda #$20
    sta enY
    lda rFgColor
    sta wEnColor
    lda #(30*8)
    sta enSpr
    rts
    LOG_SIZE "RsInit_SpectacleRock", RsInit_SpectacleRock