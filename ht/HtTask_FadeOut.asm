;==============================================================================
; mzxrules 2026
;==============================================================================

HtTask_FadeOut: SUBROUTINE
    lda rOSFrameState
    bpl .continue ; #OS_FRAME_OVERSCAN
; on OS_FRAME_VBLANK, first frame
    ldx rHaltFrame
    inx
    cpx Frame
    bne .rts

    lda #PS_LOCK_ALL
    ora plState
    sta plState
.rts
    rts
.continue
    lda Frame
    sec
    sbc rHaltFrame
    cmp #16
    beq .task_next
.animate
    lda rFgColor
    jsr HtTask_FadeOut_ReduceColor
    sta wFgColor
    lda rBgColor
    jsr HtTask_FadeOut_ReduceColor
    sta wBgColor
    lda rPlColor
    jsr HtTask_FadeOut_ReduceColor
    sta wPlColor
    rts
.task_next
    lda #HALT_KERNEL_GAMEVIEW_BLACK
    sta wHaltKernelId
    jmp Halt_TaskNext

HtTask_FadeOut_ReduceColor: SUBROUTINE
    tax
    and #$0F
    beq .return
    dex
    txa

.return
    rts