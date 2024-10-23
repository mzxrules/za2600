;==============================================================================
; mzxrules 2024
;==============================================================================
RoomUpdate: SUBROUTINE
    bit roomFlags
    bmi .continue
    rts
.continue
    lda #0
    sta roomFlags

    ; TODO: Flags
    ; TODO: Subworld
    lda #SLOT_FC_HALT_RSCR
    sta BANK_SLOT
    jmp ROOMSCROLL_HALT_START


LoadRoom: SUBROUTINE
    lda #SLOT_F4_PF
    sta BANK_SLOT

    lda roomIdNext
    sta roomId
    and #1
    tax
    lda roomIdNext
    eor .bit_byte,x
    and #$10
    ora #$0F
    tax

; load room
    ldy #15
.load_room_loop
    lda PF1_L,x
    sta wPF1RoomL+2,y

    lda PF2_M,x
    sta wPF2Room+2,y

    lda PF1_R,x
    sta wPF1RoomR+2,y
    dex
    dey
    bpl .load_room_loop
    rts

.bit_byte
    .byte #$00, #$10