;==============================================================================
; mzxrules 2022
;==============================================================================

RsInit_EntCaveLeftBlocked: SUBROUTINE
    ldy roomId
    lda rRoomFlag,y
    and #RF_SV_DESTROY
    bne .open
    
    lda #$FF
    sta wPF1RoomL + 12
    sta wPF1RoomL + 13
    sta wPF1RoomL + 14
    lda #$15
    sta blX
    lda #$38
    sta blY
    rts
.open 
    lda #$80
    sta blY
    lda #RS_ENT_CAVE_LEFT
    sta roomRS
    rts