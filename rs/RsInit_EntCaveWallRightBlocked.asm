;==============================================================================
; mzxrules 2022
;==============================================================================

RsInit_EntCaveWallRightBlocked: SUBROUTINE
    ldy roomId
    lda rRoomFlag,y
    and #RF_SV_DESTROY
    bne RsInit_EntCaveWallRight

    lda #$6C+1
    sta blX
    lda #$38
    sta blY
    lda rPF1RoomR + 12
    ora #$0C
    sta wPF1RoomR + 12
    lda rPF1RoomR + 13
    ora #$0C
    sta wPF1RoomR + 13
    lda rPF1RoomR + 14
    ora #$0C
    sta wPF1RoomR + 14
    rts
RsInit_EntCaveWallRight: SUBROUTINE
    lda #RS_ENT_CAVE_WALL_RIGHT
    sta roomRS
    lda #$80
    sta blY
    lda rPF1RoomR + 12
    and #$F3
    sta wPF1RoomR + 12
    lda rPF1RoomR + 13
    and #$F3
    sta wPF1RoomR + 13
    lda rPF1RoomR + 14
    and #$F3
    sta wPF1RoomR + 14
    rts