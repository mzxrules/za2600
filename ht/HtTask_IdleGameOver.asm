;==============================================================================
; mzxrules 2024
;==============================================================================

HtTask_IdleGameOver: SUBROUTINE
    lda #HALT_KERNEL_HUD_WORLD
    sta wHaltKernelId

    lda rHaltVState
    bmi .rts ; #HALT_VSTATE_TOP
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
; Push return address of OVERSCAN_WAIT
    lda #>OVERSCAN_WAIT
    pha
    lda #<OVERSCAN_WAIT-1
    pha
    lda rHaltType
    inx ; #0
    stx wHaltType
    jmp MAIN_RESPAWN
.rts
    rts