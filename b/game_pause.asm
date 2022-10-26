;==============================================================================
; mzxrules 2022
;==============================================================================

PAUSE_ENTRY: SUBROUTINE
    lda Frame
    sta PFrame
    lda #-20
    sta PDelay
    inc plState2
    lda plState2
    tax ; plState
    and #PS_ACTIVE_ITEM
    tay ; active item
    txa
    cpy #5
    bne .skipReset
    and #$F0
.skipReset
    sta plState2
    lda #0
    sta plItemDir
    jmp PAUSE_FROM_GAME

PAUSE_VERTICAL_SYNC:
    lda #2
    ldx #49
    sta WSYNC
    sta VSYNC
    stx TIM64T ; 41 scanline timer
    inc Frame
    sta WSYNC
    sta WSYNC
    lda #0      ; LoaD Accumulator with 0 so D1=0
    ; disable VDEL for HUD drawing
    sta VDELP0
    sta VDELP1
    ;sta PF0     ; blank the playfield
    ;sta PF1
    ;sta PF2
    ;sta GRP0    ; blanks player0 if VDELP0 was off
    ;sta GRP1    ; blanks player0 if VDELP0 was on, player1 if VDELP1 was off
    ;sta GRP0    ; blanks                           player1 if VDELP1 was on
    sta WSYNC
    sta VSYNC

PAUSE_FROM_GAME:
    ; Check if game should be unpaused
    lda PDelay
    bne .pauseInc
    bit INPT1
    bmi .skip_game_return

.pauseInc
    inc PDelay
    cmp #20
    bne .skip_game_return
    
    lda #SLOT_PL
    sta BANK_SLOT
    jmp MAIN_UNPAUSE

.skip_game_return
    lda #SLOT_AU_A
    sta BANK_SLOT
    lda #SLOT_AU_B
    sta BANK_SLOT
    jsr UpdateAudio
    
    lda #SLOT_EN_D
    sta BANK_SLOT
    jsr EnDraw_Del


PAUSE_KERNEL_MAIN: SUBROUTINE ; 192 scanlines
    sta WSYNC
    lda INTIM
    bne PAUSE_KERNEL_MAIN
    sta VBLANK
    ldy #[192/2]-1
PAUSE_KERNEL_LOOP:
    sta WSYNC
    dey
    sta WSYNC
    bpl PAUSE_KERNEL_LOOP


PAUSE_OVERSCAN: SUBROUTINE ; 30 scanlines
    sta WSYNC
    lda #2
    sta VBLANK
    lda #32
    sta TIM64T ; 27 scanline timer
; reset world kernel vars
    lda #7
    sta wENH
    lda #0
    sta NUSIZ1_T


PAUSE_OVERSCAN_WAIT:
    sta WSYNC
    lda INTIM
    bne PAUSE_OVERSCAN_WAIT

    jmp PAUSE_VERTICAL_SYNC
