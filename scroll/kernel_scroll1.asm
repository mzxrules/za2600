;==============================================================================
; mzxrules 2024
;==============================================================================

KERNEL_SCROLL1: SUBROUTINE  ; 192 scanlines

    lda #%00110000  ; ball size 8, standard playfield
    sta CTRLPF

    lda #SLOT_RW_F0_ROOMSCROLL
    sta BANK_SLOT_RAM

    lda #SLOT_F4_ROOMSCROLL
    sta BANK_SLOT

    sta WSYNC

    ldx roomScrollDY
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

    ldy #79 ; #192
KERNEL_SCROLL1_LOOP1: SUBROUTINE ;-59
; Scanline 0
    sta WSYNC
    lda #$FF
    sta PF0
    lda rCOLUPF_A,x
    sta COLUPF
    lda rCOLUBK_A,x
    sta COLUBK
    lda rPF1_0A,x
    sta PF1
    lda rPF2_0A,x
    sta PF2

    sleep 2

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