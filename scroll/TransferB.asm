;==============================================================================
; mzxrules 2024
;==============================================================================
RoomScrollTask_TransferB: SUBROUTINE
    inc roomScrollTask

UnmirrorRoomB: SUBROUTINE
    lda #SLOT_RW_F0_ROOMSCROLL
    sta BANK_SLOT_RAM
    ldy #19
.loop

; Mirrored
; PF2 left is 0...7
; PF2 right is 7...0
; PF1 Right is 0...7

; Unmirrored
; PF0 2nd is 4...7, so Mirror PF2 bit 0 -> 4, 1 -> 5
; PF1 2nd is 7...0, so Mirror PF2 bit 4 -> 7, 5 -> 6
;                      Mirror PF1 bit 0 -> 3, 1 -> 2
; PF2 2nd is 0...7, so

    lda rPF1RoomL,y
    sta wPF1_0B,y
    lda rPF2Room,y
    sta wPF2_0B,y
    tax ; rPF2Room

    asl
    asl
    asl
    asl
    sta roomScrollTemp ; PF1 2nd

    lda bit_mirror_nybble_swap,x
; PF0 2nd
    ora #$0F ; Force bits on to make anim easier
    sta wPF0_1B,y

; PF1 2nd continued

    ldx rPF1RoomR,y
    lda bit_mirror_nybble_swap,x
    and #$0F
    ora roomScrollTemp
    sta wPF1_1B,y

    lda rPF1RoomR,y
    lsr
    lsr
    lsr
    lsr
    ora #$F0
    sta wPF2_1B,y

    dey
    bpl .loop
    rts
