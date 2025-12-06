;==============================================================================
; mzxrules 2024
;==============================================================================
HtTask_AnimNorth: SUBROUTINE
    lda rOSFrameState
    bpl .rts ; #OS_FRAME_OVERSCAN

    inc roomScrollDY
    dec roomTimer
    bne .rts
    jmp Halt_TaskNext
.rts
    rts