;==============================================================================
; mzxrules 2024
;==============================================================================
; Simulate main game loop

; always.asm hook
MAIN_ROOMSCROLL: BHA_BANK_JMP #SLOT_FC_MAIN, ROOMSCROLL_RETURN

KERNEL_MAIN:  ; 192 scanlines
    sta WSYNC
    lda INTIM
    bne KERNEL_MAIN
    sta VBLANK

    ldy #79 ; #192
KERNEL_LOOP_1: SUBROUTINE ;-59
    REPEAT 2

    sta WSYNC
    ldx roomDY
    lda #$FF
    sta PF0
    lda rPF1RoomL,x
    sta PF1
    lda rPF2Room,x
    sta PF2

    sleep 12

    lda rPF1RoomR,x
    sta PF1

    REPEND

    tya
    and #3
    beq .PFDec  ; 2/3
    .byte $2C   ; 4-5
.PFDec
    dec roomDY  ; 5
    dey
    bpl KERNEL_LOOP_1
    sta WSYNC
    iny
    sty PF0
    sty PF1
    sty PF2

    ldy #192 - 160 - 1
KERNEL_LOOP_2
    sta WSYNC
    dey
    bne KERNEL_LOOP_2
    rts

ENTRY:
    CLEAN_START

    lda #RAMSEG_F0 | 0
    sta BANK_SLOT_RAM
    lda #RAMSEG_F4 | 1
    sta BANK_SLOT_RAM
    txa
.zero_ram
    dey
    sta $F200,y
    sta $F300,y
    sta $F600,y
    sta $F700,y
    bne .zero_ram

    lda #SLOT_RW_F8_WX
    sta BANK_SLOT_RAM

    lda #$01
    sta testIndex

    lda #$34
    sta roomId
    sta roomIdNext

    lda #SLOT_F0_ROOM
    sta BANK_SLOT
    jsr LoadRoom

    ;lda #RF_EV_LOAD
    ;sta roomFlags

;TOP_FRAME ;3 37 192 30
VERTICAL_SYNC: ; 3 SCANLINES
    lda #2
    ldx #49
    sta WSYNC
    sta VSYNC
    stx TIM64T ; 41 scanline timer
    inc Frame
    sta WSYNC
    sta WSYNC
    lda #%00110001
    sta CTRLPF
    lda #0      ; LoaD Accumulator with 0 so D1=0
    sta PF0     ; blank the playfield
    sta PF1
    sta PF2
    sta GRP0    ; blanks player0 if VDELP0 was off
    sta GRP1    ; blanks player0 if VDELP0 was on, player1 if VDELP1 was off
    sta GRP0    ; blanks                           player1 if VDELP1 was on
    sta WSYNC
    sta VSYNC

VERTICAL_BLANK: SUBROUTINE
    lda #$D0
    sta COLUPF
    lda #$3C
    sta COLUBK
    lda #ROOM_PX_HEIGHT-1
    sta roomDY

    lda #SLOT_F0_ROOM
    sta BANK_SLOT

    bit INPT4
    bmi .skip
    ;inc testIndex
    ;lda testIndex
    lda Frame
    and #3
    tax

    lda roomIdNext
    clc
    adc TestDummy_RoomMove,x
    and #$7F
    sta roomIdNext
    lda #RF_EV_LOAD
    sta roomFlags
.skip

    jsr RoomUpdate
ROOMSCROLL_RETURN
    jsr KERNEL_MAIN

OVERSCAN: ; 30 scanlines
    sta WSYNC
    lda #2
    sta VBLANK
    lda #32
    sta TIM64T ; 27 scanline timer

OVERSCAN_WAIT:
    sta WSYNC
    lda INTIM
    bne OVERSCAN_WAIT

    jmp VERTICAL_SYNC


TestDummy_RoomMove:
; E, W, N, S
    .byte #$01, #$FF, #$F0, #$10