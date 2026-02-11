;==============================================================================
; mzxrules 2024
;==============================================================================

LoadRoom_Subworld: SUBROUTINE
    lda worldId
    bpl .subworld_stairwell
    jmp LoadRoom_Cave

.subworld_stairwell
    ldy #$0F ; Rs_StairwellItem room
    lda roomIdNext
    cmp #SW_STAIRWELL
    bcc .subworld_stairwell_room
    ldy #$7F ; Rs_Stairwell room
.subworld_stairwell_room
    jmp LoadRoom_Stairwell

LoadRoom_Cave: SUBROUTINE
    ; Don't overwrite room vars
    lda #1
    sta wRoomColorFlags
    lda #RS_CAVE
    sta roomRS
    lda #$F3
    sta roomDoors
    lda #MS_PLAY_NONE
    sta SeqFlags

    lda #$FF
    ldy #1
.loadRoomSprite1
    sta wPF2Room + ROOM_PX_HEIGHT-2,y
    sta wPF1RoomL + ROOM_PX_HEIGHT-2,y
    sta wPF1RoomR + ROOM_PX_HEIGHT-2,y
    dey
    bpl .loadRoomSprite1

    lda #0
    ldy #ROOM_PX_HEIGHT-2 -1
.loadRoomSprite2
    sta wPF2Room,y
    dey
    bpl .loadRoomSprite2

    lda #$C0
    ldy #ROOM_PX_HEIGHT-2 -1
.loadRoomSprite3
    sta wPF1RoomL,y
    sta wPF1RoomR,y
    dey
    bpl .loadRoomSprite3
.rts
    rts