;==============================================================================
; mzxrules 2021
;==============================================================================
KERNEL_WORLD: SUBROUTINE ; rKERNEL
    VKERNEL1 WorldSprBank
    lda #SLOT_SPR_A
    sta BANK_SLOT

    VKERNEL1 BgColor
    lda #COLOR_PATH
    sta COLUBK
    VKERNEL1 FgColor
    lda #COLOR_GREEN_ROCK
    sta COLUPF
    lda enColor
    sta COLUP1

    lda NUSIZ1_T
    sta NUSIZ1
    lda NUSIZ0_T
    sta NUSIZ0

    lda #0
    tax

    sta WSYNC       ; 3
    sta CXCLR       ; 3
KERNEL_LOOP: SUBROUTINE ; 76 cycles per scanline
    sta ENAM0       ; 3
    stx GRP1        ; 3

    ldx roomDY      ; 3
    lda rPF1RoomL,x ; 4
    sta PF1         ; 3
    lda rPF2Room,x  ; 4
    sta PF2         ; 3

; Player            ;    CYCLE 15
    lda #7          ; 2 player height
    dcp plDY        ; 5
    bcs .DrawP0     ; 2/3
    lda #0          ; 2
    .byte $2C       ; 4-5 BIT compare hack to skip 2 byte op
.DrawP0:
    lda (plSpr),y   ; 5

    sta GRP0        ; 3
; PF1R first line
    lda rPF1RoomR,x ; 4
    sta PF1         ; 3

; Ball
    VKERNEL1 BLH
    lda #7          ; 2 ball height
    dcp blDY        ; 5
    lda #1          ; 2
    adc #0          ; 2
    sta ENABL       ; 3

; Enemy Missile     ;    CYCLE 15
    VKERNEL1 M1H
    lda #7          ; 3 enM height
    dcp m1DY        ; 5
    ;sta WSYNC
    lda #1          ; 2
    adc #0          ; 2
    sta ENAM1       ; 3

    lda rPF1RoomL,x ; 4
    sta PF1         ; 3
    lda rPF1RoomR,x ; 4
    pha             ; 3

; Enemy             ;    CYCLE 15
    VKERNEL1 ENH
    lda #7          ; 2     enemy height
    dcp enDY        ; 5
    bcs .DrawE0     ; 2/3
    lda #0          ; 2
    .byte $2C       ; 4-5   BIT compare hack to skip 2 byte op
.DrawE0:
    lda (enSpr),y   ; 5
    tax             ; 2

    pla             ; 4
    sta PF1         ; 3
; Playfield
    tya             ; 2
    and #3          ; 2
    beq .PFDec      ; 2/3
    .byte $2C       ; 4-5
.PFDec
    dec roomDY      ; 5

; Player Missile    ;    CYCLE 15
    VKERNEL1 M0H
    lda #7          ; 2 plM height
    dcp m0DY        ; 5
    lda #1          ; 2
    adc #0          ; 2

    dey             ; 2
    sta WSYNC       ; 3
    bpl KERNEL_LOOP ; 3/2
    rts

    LOG_SIZE "-KERNEL WORLD-", KERNEL_WORLD