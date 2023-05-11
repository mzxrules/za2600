;==============================================================================
; mzxrules 2023
;==============================================================================

RsInit_EntCaveWallCenterBlocked: SUBROUTINE
    ldy roomId
    lda rRoomFlag,y
    and #RF_SV_DESTROY
    bne .open

    lda #$FF
    sta wPF2Room + 12
    sta wPF2Room + 13
    sta wPF2Room + 14
    lda #$41
    sta blX
    lda #$38
    sta blY
    rts
.open
    lda #$80
    sta blY
    lda #RS_ENT_CAVE_WALL_CENTER
    sta roomRS
    rts