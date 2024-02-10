;==============================================================================
; mzxrules 2023
;==============================================================================

RsInit_EntCaveWallCenterBlocked: SUBROUTINE
    ldy roomId
    lda rRoomFlag,y
    and #RF_SV_DESTROY
    bne RsInit_EntCaveWallCenter

    lda #$40+1
    sta blX
    lda #$38
    sta blY
    lda rPF2Room + 12
    ora #$80
    sta wPF2Room + 12
    lda rPF2Room + 13
    ora #$80
    sta wPF2Room + 13
    lda rPF2Room + 14
    ora #$80
    sta wPF2Room + 14
    rts
RsInit_EntCaveWallCenter: SUBROUTINE
    lda #RS_ENT_CAVE_WALL_CENTER
    sta roomRS
    lda #$80
    sta blY
    lda rPF2Room + 12
    and #$7F
    sta wPF2Room + 12
    lda rPF2Room + 13
    and #$7F
    sta wPF2Room + 13
    lda rPF2Room + 14
    and #$7F
    sta wPF2Room + 14
    rts