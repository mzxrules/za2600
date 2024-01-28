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
    jsr VERTICAL_SYNC

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
    lda #SLOT_F0_PL
    sta BANK_SLOT
    jmp MAIN_UNPAUSE

.runHaltUpdate
    lda #SLOT_F4_AU1
    sta BANK_SLOT
    jsr UpdateAudio

    lda #SLOT_F0_ENDRAW
    sta BANK_SLOT
    jsr EnDraw_Del

    lda #SLOT_F4_PAUSE_DRAW_WORLD
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