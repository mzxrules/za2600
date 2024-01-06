;==============================================================================
; mzxrules 2022
;==============================================================================

RsInit_SpectacleRock: SUBROUTINE
    lda #$20
    sta blY

    ldy roomId
    lda rRoomFlag,y
    and #RF_SV_DESTROY
    bne .open

.closed
    lda #$58+1
    sta blX
    rts

.open
    lda #$28+1
    sta blX

    lda #RS_ENT_DUNG_SPECTACLE_ROCK
    sta roomRS

    lda #$19
    sta wPF2Room + 6
    lda #$39
    sta wPF2Room + 7
    ;sta rPF2Room + 8
    rts
    LOG_SIZE "RsInit_SpectacleRock", RsInit_SpectacleRock