KERNEL_SCROLL1: SUBROUTINE  ; 192 scanlines

    lda #%00110000  ; ball size 8, standard playfield
    sta CTRLPF

    lda #SLOT_RW_F0_ROOMSCROLL
    sta BANK_SLOT_RAM

    lda #SLOT_F4_ROOMSCROLL
    sta BANK_SLOT

    sta WSYNC

    ldx #19
    lda rCOLUBK_A,x
    sta COLUBK

    lda rCOLUPF_A,x
    sta COLUPF

    lda #$FF
    sta PF0
    sta PF1
    sta PF2

    lda rPlColor
    sta COLUP0

    clc
    lda plSpr+1
    adc #$FE
    sta plSpr+1

    ldx roomScrollDY
    ldy #79 ; #192
KERNEL_SCROLL1_LOOP1: SUBROUTINE ;-59
; Scanline 0
    sta WSYNC
    lda #$FF
    sta PF0
    sleep 14
    ;lda rCOLUPF_A,x
    ;sta COLUPF
    ;lda rCOLUBK_A,x
    ;sta COLUBK
    lda rPF1_0A,x
    sta PF1
    lda rPF2_0A,x
    sta PF2

    sleep 2
;    lda #7          ; 2 player height
;    dcp plDY        ; 5
;    bcs .DrawP0     ; 2/3
;    lda #0          ; 2
;    .byte $2C       ; 4-5 BIT compare hack to skip 2 byte op
;.DrawP0:
;    lda (plSpr),y   ; 5

    ;sta GRP0        ; 3

    lda rPF0_1A,x
    sta PF0
    lda rPF1_1A,x
    sta PF1
    lda rPF2_1A,x
    sta PF2
; Scanline 1

    sta WSYNC
    lda #$FF
    sta PF0
    lda rPF1_0A,x
    sta PF1
    lda rPF2_0A,x
    sta PF2

    lda #0
    sta GRP1
    sleep 13

    lda rPF0_1A,x
    sta PF0
    lda rPF1_1A,x
    sta PF1
    lda rPF2_1A,x
    sta PF2

    tya
    and #3
    bne .PFDec  ; 2/3
    dex
.PFDec
    dey
    bpl KERNEL_SCROLL1_LOOP1
    sta WSYNC
    sty PF0
    sty PF1
    sty PF2
    rts