;==============================================================================
; mzxrules 2022
;==============================================================================

RsInit_EntCaveWallLeftBlocked: SUBROUTINE
    ldy roomId
    lda rRoomFlag,y
    and #RF_SV_DESTROY
    bne RsInit_EntCaveWallLeft

    lda rPF1RoomL + 12
    ora #$0C
    sta wPF1RoomL + 12
    lda rPF1RoomL + 13
    ora #$0C
    sta wPF1RoomL + 13
    lda rPF1RoomL + 14
    ora #$0C
    sta wPF1RoomL + 14
    lda #$14+1
    sta blX
    lda #$38
    sta blY
    rts

RsInit_EntCaveWallLeft:
    lda #RS_ENT_CAVE_WALL_LEFT
    sta roomRS
    lda #$80
    sta blY
    lda rPF1RoomL + 12
    and #$F3
    sta wPF1RoomL + 12
    lda rPF1RoomL + 13
    and #$F3
    sta wPF1RoomL + 13
    lda rPF1RoomL + 14
    and #$F3
    sta wPF1RoomL + 14
    rts