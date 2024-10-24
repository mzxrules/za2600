RoomScroll_Left: SUBROUTINE
    clc

; RoomB
    lda rPF2_1B,y
    ror
    sta wPF2_1B,y

    lda rPF1_1B,y
    rol
    sta wPF1_1B,y

    lda rPF0_1B,y
    ror
    sta wPF0_1B,y
    and #%1000
    cmp #%1000

    lda rPF2_0B,y
    ror
    sta wPF2_0B,y

    lda rPF1_0B,y
    rol
    sta wPF1_0B,y

; get carry
    rol
    and #1
    tax
    sec

; RoomA
    lda rPF2_1A,y
    ror
    and .PF2_carry_mask,x
    sta wPF2_1A,y

    lda rPF1_1A,y
    rol
    sta wPF1_1A,y

    lda rPF0_1A,y
    ror
    sta wPF0_1A,y
    and #%1000
    cmp #%1000

    lda rPF2_0A,y
    ror
    sta wPF2_0A,y

    lda rPF1_0A,y
    rol
    sta wPF1_0A,y
    rts

.PF2_carry_mask
    .byte  #$F7,  #$FF