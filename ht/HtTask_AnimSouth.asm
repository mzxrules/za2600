;==============================================================================
; mzxrules 2024
;==============================================================================
HtTask_AnimSouth: SUBROUTINE
    lda rOSFrameState
    bpl .rts ; #OS_FRAME_OVERSCAN

    dec roomScrollDY
    dec roomTimer
    bne .rts
    jmp Halt_TaskNext
.rts
    rts