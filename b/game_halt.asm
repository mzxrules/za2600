;==============================================================================
; mzxrules 2023
;==============================================================================
HALT_FLUTE_ENTRY: SUBROUTINE
    ldx #$FF
    txs
    lda Frame
    sta PFrame

    lda #19
    sta PAnim
    jmp HALT_FROM_FLUTE

HALT_VERTICAL_SYNC:
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

HALT_FROM_FLUTE:
    clc
    lda PFrame
    adc #$7F
    cmp Frame
    bne .runHaltUpdate

.spawnTornado
    ldx #-8
    lda itemTri
    beq .noTornado
    lda worldId
    bne .noTornado
    lda roomId
    bmi .noTornado

    lda plY
    sta m0Y
    ldx #-85
.noTornado
    stx plItemTimer
    lda #0
    sta m0X
    lda #SLOT_PL
    sta BANK_SLOT
    jmp MAIN_UNPAUSE

.runHaltUpdate
    lda #SLOT_AU_B
    sta BANK_SLOT
    jsr UpdateAudio

    lda #SLOT_EN_D
    sta BANK_SLOT
    jsr EnDraw_Del

    lda #SLOT_DRAW_PAUSE_WORLD
    sta BANK_SLOT

    jsr DRAW_PAUSE_WORLD

HALT_OVERSCAN: SUBROUTINE ; 30 scanlines
    sta WSYNC
    lda #2
    sta VBLANK
    lda #32
    sta TIM64T ; 27 scanline timer
; reset world kernel vars
    lda #7
    sta wENH
    lda #0
    sta wNUSIZ1_T
    sta wREFP1_T

HALT_OVERSCAN_WAIT:
    sta WSYNC
    lda INTIM
    bne HALT_OVERSCAN_WAIT
    jmp HALT_VERTICAL_SYNC