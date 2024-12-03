;==============================================================================
; mzxrules 2024
;==============================================================================

; Vertical Blank Routine
HtTask_PlayFlute: SUBROUTINE
    lda rHaltVState
    bpl .rts ; not #HALT_VSTATE_TOP
    lda rHaltFrame
    clc
    adc #$7F
    cmp Frame
    beq .test_spawn_tornado
.rts
    rts

.test_spawn_tornado
    lda #-4
    sta plItemTimer
    lda itemTri
    beq .noTornado
    lda worldId
    bpl .noTornado
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

    ldx #$FF
    txs
    inx ; #0
    stx wHaltType
    jmp MAIN_UNPAUSE
