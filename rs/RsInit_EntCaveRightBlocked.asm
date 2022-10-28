;==============================================================================
; mzxrules 2022
;==============================================================================

RsInit_EntCaveRightBlocked: SUBROUTINE
    ldy roomId
    lda rRoomFlag,y
    and #RF_SV_DESTROY
    bne .open

    lda #$FF
    sta wPF1RoomR + 12
    sta wPF1RoomR + 13
    sta wPF1RoomR + 14
    lda #$6C+1
    sta blX
    lda #$38
    sta blY
    rts
.open
    lda #$80
    sta blY
    lda #RS_ENT_CAVE_RIGHT
    sta roomRS
    rts