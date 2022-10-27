;==============================================================================
; mzxrules 2022
;==============================================================================

PAUSE_ENTRY: SUBROUTINE
    lda Frame
    sta PFrame
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
    sta PauseState
    lda #20
    sta PAnim
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
    ; Check game pause status
    bit PauseState
    bvs .runPauseMenu
    bpl .pauseAnimScrollDown
    bmi .pauseAnimScrollUp

.pauseAnimScrollDown
    dec PAnim
    bne .runPauseUpdate
    lda PauseState
    ora #$40
    sta PauseState
    jmp .runPauseMenu
    
.pauseAnimScrollUp
    inc PAnim
    lda PAnim
    cmp #20
    bne .runPauseUpdate
    lda #0
    sta PauseState
    lda #SLOT_PL
    sta BANK_SLOT
    jmp MAIN_UNPAUSE

.runPauseMenu
    bit INPT1
    bmi .runPauseUpdate
    lda #$80
    sta PauseState

.runPauseUpdate
    lda #SLOT_AU_A
    sta BANK_SLOT
    lda #SLOT_AU_B
    sta BANK_SLOT
    jsr UpdateAudio
    
    lda #SLOT_EN_D
    sta BANK_SLOT
    jsr EnDraw_Del

    lda #SLOT_DRAW_PAUSE_WORLD
    sta BANK_SLOT
    jsr DRAW_PAUSE_WORLD


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
