;==============================================================================
; mzxrules 2024
;==============================================================================

HtTask_IdleGameOver: SUBROUTINE
    lda #HALT_KERNEL_GAMEVIEW_BLACK
    sta wHaltKernelId

    lda rOSFrameState
    bpl .continue ; #OS_FRAME_OVERSCAN
.rts
    rts
.continue
    lda enInputDelay
    cmp #1
    adc #0
    sta enInputDelay
    bne .rts
    bit INPT4
    bmi .rts
    lda roomId
    and #$7F
    tay
    lda rWorldRoomENCount,y
    sta roomENCount

; Reset the stack
    ldx #$FF
    txs

    lda #SLOT_FC_MAIN
    sta BANK_SLOT
    jsr RESPAWN

    lda #MS_PLAY_NONE
    sta SeqFlags
    ldx #HALT_TYPE_GAME_START
    stx wHaltType
    jmp MAIN_OVERSCAN_WAIT
