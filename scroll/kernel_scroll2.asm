;==============================================================================
; mzxrules 2024
;==============================================================================

; Rewrite attempt of KERNEL_SCROLL1, to try and add player sprite positioning.

KERNEL_SCROLL2: SUBROUTINE  ; 192 scanlines

    lda #%00110000  ; ball size 8, standard playfield
    sta CTRLPF

    lda #SLOT_RW_F0_ROOMSCROLL
    sta BANK_SLOT_RAM

    lda #SLOT_F4_ROOMSCROLL
    sta BANK_SLOT

    sta WSYNC

    ;lda rBgColor
    ;sta COLUBK

    ;lda rFgColor
    ;sta COLUPF

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
    stx roomDY

    ldy #19 ; #192
KERNEL_SCROLL2_LOOP1: SUBROUTINE ;-59
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

    lda rPF0_1A,x
    sta PF0
    lda rPF1_1A,x
    sta PF1
    lda rPF2_1A,x
    sta PF2


; Scanline 2
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

    lda rPF0_1A,x
    sta PF0
    lda rPF1_1A,x
    sta PF1
    lda rPF2_1A,x
    sta PF2
; Scanline 3

    sta WSYNC
    lda #$FF
    sta PF0
    lda rPF1_0A,x
    sta PF1
    lda rPF2_0A,x
    sta PF2

    lda rPF0_1A,x
    sta PF0
    lda rPF1_1A,x
    sta PF1
    lda rPF2_1A,x
    sta PF2



; Scanline 4
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

    lda rPF0_1A,x
    sta PF0
    lda rPF1_1A,x
    sta PF1
    lda rPF2_1A,x
    sta PF2
; Scanline 5

    sta WSYNC
    lda #$FF
    sta PF0
    lda rPF1_0A,x
    sta PF1
    lda rPF2_0A,x
    sta PF2

    lda rPF0_1A,x
    sta PF0
    lda rPF1_1A,x
    sta PF1
    lda rPF2_1A,x
    sta PF2



; Scanline 6
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

    lda rPF0_1A,x
    sta PF0
    lda rPF1_1A,x
    sta PF1
    lda rPF2_1A,x
    sta PF2
; Scanline 7

    sta WSYNC
    lda #$FF
    sta PF0
    lda rPF1_0A,x
    sta PF1
    lda rPF2_0A,x
    sta PF2

    lda rPF0_1A,x
    sta PF0
    lda rPF1_1A,x
    sta PF1
    lda rPF2_1A,x
    sta PF2

    dex
    dey
    bmi .end
    jmp KERNEL_SCROLL2_LOOP1
.end

    sta WSYNC
    sty PF0
    sty PF1
    sty PF2
    sta WSYNC
    iny
    sty PF0
    sty PF1
    sty PF2
    sty COLUBK
    sty COLUPF
    sta WSYNC
    sta WSYNC
    sta WSYNC
    rts