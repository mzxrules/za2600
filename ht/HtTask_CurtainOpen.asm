;==============================================================================
; mzxrules 2025
;==============================================================================

HtTask_CurtainOpen: SUBROUTINE
    lda rOSFrameState
    bmi .continue ; #OS_FRAME_VBLANK
.rts
    rts

.continue
    lda Halt_Temp0
    inc Halt_Temp0
    and #1
    bne .rts

    lda #HALT_KERNEL_GAMEVIEW_NOPL
    cmp rHaltKernelId
    beq .continue2

    sta wHaltKernelId
    lda #0
    sta RoomPX
    rts

.continue2
    inc RoomPX
    lda RoomPX
    cmp #ROOM_PX_HEIGHT-1
    bne .rts

; Game Start!
    lda #MS_PLAY_RSEQ
    sta SeqFlags

    lda #HALT_KERNEL_GAMEVIEW
    sta wHaltKernelId

    ldx #$FF
    txs
    inx
    stx wHaltType
    jmp MAIN_LOADROOM_RETURN
