;==============================================================================
; mzxrules 2024
;==============================================================================

RsInit_EntDungBush: SUBROUTINE
    lda #$00
    sta wPF2Room + 12 - 3 - 4
    sta wPF2Room + 13 - 3 - 4

    ldy roomId
    lda rRoomFlag,y
    and #RF_SV_DESTROY
    bne .open

    lda #$40+1
    sta blX
    lda #$1C
    sta blY
    rts
.open
    lda #$80
    sta blY
    lda #RS_ENT_DUNG_BUSH
    sta roomRS
    rts