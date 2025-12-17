;==============================================================================
; mzxrules 2024
;==============================================================================

HtTask_RoomScrollEnd: SUBROUTINE
    lda rOSFrameState
    bmi .continue ; #OS_FRAME_VBLANK
    rts
.continue
    ldx #HALT_KERNEL_GAMEVIEW
    stx wHaltKernelId
    jsr Halt_UpdateGameViewKernel
    lda #%00110001
    sta CTRLPF
    lda roomIdNext
    sta roomId

    lda #-18
    sta roomTimer

    ldx #$FF
    txs
    inx ; #0
    stx wHaltType
    jmp MAIN_LOADROOM_RETURN