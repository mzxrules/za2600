;==============================================================================
; mzxrules 2024
;==============================================================================
UnmirrorRoomA_Blackout: SUBROUTINE
.loop_blackout
    lda #$FF
    sta wPF1_0A,y
    sta wPF2_0A,y
    sta wPF0_1A,y
    sta wPF1_1A,y
    sta wPF2_1A,y
    dey
    bpl .loop_blackout
    rts

HtTask_TransferA_Color: SUBROUTINE
    ldy #ROOM_PX_HEIGHT-1
    sty wTransferA
.loop
    lda rFgColor
    sta wCOLUPF_A,y
    lda rBgColor
    sta wCOLUBK_A,y
    dey
    bpl .loop
    rts

HtTask_TransferA: SUBROUTINE
    lda #SLOT_RW_F0_ROOMSCROLL
    sta BANK_SLOT_RAM

    ldy rTransferA ; #ROOM_PX_HEIGHT-1 or #0
    beq HtTask_TransferA_Color
    lda #0
    sta wTransferA
    jsr Halt_IncTask

UnmirrorRoomA:
    bit rRoomColorFlags
    bvs UnmirrorRoomA_Blackout ; #RF_WC_ROOM_DARK

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
    sta wPF1_0A,y
    lda rPF2Room,y
    sta wPF2_0A,y
    tax ; rPF2Room

    lda bit_nybble_swap,x
    and #$F0
    sta roomScrollTemp ; PF1 2nd

    lda bit_mirror_nybble_swap,x
; PF0 2nd
    ora #$0F ; Force bits on to make anim easier
    sta wPF0_1A,y

; PF1 2nd continued

    ldx rPF1RoomR,y
    lda bit_mirror_nybble_swap,x
    and #$0F
    ora roomScrollTemp
    sta wPF1_1A,y

    ldx rPF1RoomR,y
    lda bit_nybble_swap,x
    ora #$F0
    sta wPF2_1A,y

    dey
    bpl .loop

; manually write ball to PF
    lda blX
    lsr
    lsr
    tax

    lda blY
    bmi .rts
    lsr
    lsr
    pha ; y >> 2

    clc
    adc bl_unmirrored_offset-1,x
    tay

; Set carry flag to draw 3 px high ball sprite
    lda rBLH
    cmp #8

    lda rPF_SCROLLA,y
    ora bl_unmirrored_bit-1,x
    sta wPF_SCROLLA,y

    lda rPF_SCROLLA+1,y
    ora bl_unmirrored_bit-1,x
    sta wPF_SCROLLA+1,y
    bcc .cont1

    lda rPF_SCROLLA+2,y
    ora bl_unmirrored_bit-1,x
    sta wPF_SCROLLA+2,y
.cont1

    pla ; y >> 2
    inx
    clc
    adc bl_unmirrored_offset-1,x
    tay

; Set carry flag to draw 3 px high ball sprite
    lda rBLH
    cmp #8

    lda rPF_SCROLLA,y
    ora bl_unmirrored_bit-1,x
    sta wPF_SCROLLA,y

    lda rPF_SCROLLA+1,y
    ora bl_unmirrored_bit-1,x
    sta wPF_SCROLLA+1,y
    bcc .cont2

    lda rPF_SCROLLA+2,y
    ora bl_unmirrored_bit-1,x
    sta wPF_SCROLLA+2,y
.cont2

.rts
    rts
