;==============================================================================
; mzxrules 2024
;==============================================================================

HtTask_RoomScrollEnd: SUBROUTINE
    lda rHaltVState
    bmi .continue
    rts
.continue
    lda #HALT_KERNEL_HUD_WORLD
    sta wHaltKernelId
    jsr Halt_SetKernelWorld
    lda #%00110001
    sta CTRLPF
    lda #ROOM_PX_HEIGHT-1
    sta roomDY
    lda roomIdNext
    sta roomId

    lda #-18
    sta roomTimer

    ldx #$FF
    txs
    inx ; #0
    stx wHaltType
    jmp MAIN_ROOMSCROLL