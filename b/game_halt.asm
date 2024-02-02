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
    lda #-4
    sta plItemTimer
    lda itemTri
    beq .noTornado
    lda worldId
    bne .noTornado
    lda roomId
    bmi .noTornado

; update next dest if tornado was set
    ldx #-1
    lda plState3
    and #PS_ACTIVE_ITEM2
    tay
    cpy #PLAYER_FLUTE_FX
    bne .loop
    lda plItem2Dir
    and #7
    tax
.loop
    inx
    cpx #8
    bne .skipRollover
    ldx #0
.skipRollover
    lda Bit8,x
    and itemTri
    beq .loop
; x = next destination index

; If the timer is 0, spawn the tornado and set destination
    lda plItem2Time
    beq .spawn_tornado
; If timer is not zero, but a tornado is active, just update destination
    cpy #PLAYER_FLUTE_FX
    beq .update_dest
    bne .noTornado

.spawn_tornado
    lda #-85
    sta plItem2Time
    lda #0
    sta plm1X
    lda plY
    sta plm1Y
    lda #PLAYER_FLUTE_FX
    sta plState3

.update_dest
    stx plItem2Dir

.noTornado
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