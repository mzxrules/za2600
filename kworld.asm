;==============================================================================
; mzxrules 2021
;==============================================================================
KERNEL_WORLD: SUBROUTINE ; rKERNEL_WORLD
    VKERNEL1 WorldSprBank
    lda #SLOT_F0_SPR0
    sta BANK_SLOT

    VKERNEL1 BgColor
    lda #0 ;#COLOR_PF_PATH
    sta COLUBK
    VKERNEL1 FgColor
    lda #0 ;#COLOR_PF_GREEN
    sta COLUPF
    VKERNEL1 EnColor
    lda #COLOR_EN_GREEN
    sta COLUP1
    VKERNEL1 PlColor
    lda #COLOR_PLAYER_00
    sta COLUP0

    VKERNEL1 NUSIZ1_T
    lda #0
    sta NUSIZ1
    VKERNEL1 NUSIZ0_T
    lda #0
    sta NUSIZ0
    VKERNEL1 REFP1_T
    lda #0
    sta REFP1

    VKERNEL1 blInitENABL
    lda #0
    sta ENABL

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
    VKERNEL1 PLH
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
    lda #1          ; 2
    adc #0          ; 2
    ;sta WSYNC
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
    lda rFgColor
    sta COLUBK
    lda #0
    sta PF1
    sta PF2
    sta GRP1
    sta GRP0
    sta ENAM0
    sta ENAM1
    sta PF0
    VKERNEL1 WorldSprBank_DEFAULT
    lda #SLOT_F0_SPR0
    sta wWorldSprBank
    rts

    LOG_SIZE "-KERNEL WORLD-", KERNEL_WORLD