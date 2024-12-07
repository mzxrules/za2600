;==============================================================================
; mzxrules 2023
;==============================================================================
RsInit_EntCaveLake: SUBROUTINE
    ldy roomId
    lda rWorldRoomFlags,y
    and #WRF_SV_DESTROY
    beq .rts
    ldy #7

.loop
    lda .LEVEL_7_PF2,y
    sta wPF2Room+7,y
    dey
    bpl .loop
    lda #RS_ENT_CAVE_MID
    sta roomRS
.rts
    rts


.LEVEL_7_PF2:
    .byte $68 ; |...X.XX.| mirrored
    .byte $74 ; |..X.XXX.| mirrored
    .byte $7E ; |.XXXXXX.| mirrored
    .byte $EE ; |.XXX.XXX| mirrored
    .byte $C6 ; |.XX...XX| mirrored
    .byte $92 ; |.X..X..X| mirrored
    .byte $C6 ; |.XX...XX| mirrored
    .byte $FC ; |..XXXXXX| mirrored
