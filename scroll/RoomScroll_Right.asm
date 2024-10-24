RoomScroll_Right: SUBROUTINE
    clc

; RoomB
    lda rPF1_0B,y
    ror
    sta wPF1_0B,y

    lda rPF2_0B,y
    rol
    sta wPF2_0B,y

; get carry
    rol
    and #1
    tax
    sec

    lda rPF0_1B,y
    rol
    and .PF0_carry_mask,x
    sta wPF0_1B,y


    lda rPF1_1B,y
    ror
    sta wPF1_1B,y

    lda rPF2_1B,y
    rol
    sta wPF2_1B,y
    and #%10000
    cmp #%10000

; RoomA

    lda rPF1_0A,y
    ror
    sta wPF1_0A,y

    lda rPF2_0A,y
    rol
    sta wPF2_0A,y


; get carry
    rol
    and #1
    tax
    sec

    lda rPF0_1A,y
    rol
    and .PF0_carry_mask,x
    sta wPF0_1A,y

    lda rPF1_1A,y
    ror
    sta wPF1_1A,y

    lda rPF2_1A,y
    rol
    ora #$F0
    sta wPF2_1A,y
    rts

.PF0_carry_mask
    .byte  #$EF,  #$FF