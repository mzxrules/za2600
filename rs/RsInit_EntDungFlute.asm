;==============================================================================
; mzxrules 2023
;==============================================================================
RsInit_EntDungFlute: SUBROUTINE
    ldy roomId
    lda rRoomFlag,y
    and #RF_SV_DESTROY
    beq .rts
    ldy #7

.loop
    lda .LEVEL_7_PF2,y
    sta wPF2Room+7,y
    lda #$C0
    sta wPF1RoomL+7,y
    sta wPF1RoomR+7,y
    dey
    bpl .loop
    lda #RS_ENT_DUNG_MID
    sta roomRS
.rts
    rts


.LEVEL_7_PF2:
    .byte $68 ; |...X.XX.| mirrored
    .byte $74 ; |..X.XXX.| mirrored
    .byte $7E ; |.XXXXXX.| mirrored
    .byte $F6 ; |.XX.XXXX| mirrored
    .byte $E2 ; |.X...XXX| mirrored
    .byte $49 ; |X..X..X.| mirrored
    .byte $E2 ; |.X...XXX| mirrored
    .byte $FC ; |..XXXXXX| mirrored
