;==============================================================================
; mzxrules 2024
;==============================================================================
HtTask_AnimNorth: SUBROUTINE
    lda rHaltVState
    bpl .rts ; not #HALT_VSTATE_TOP

    inc roomScrollDY
    dec roomTimer
    bne .rts
    jmp Halt_IncTask
.rts
    rts