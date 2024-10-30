;==============================================================================
; mzxrules 2024
;==============================================================================
HtTask_AnimSouth: SUBROUTINE
    lda rHaltVState
    bpl .rts ; not #HALT_VSTATE_TOP

    dec roomScrollDY
    dec roomTimer
    bne .rts
    jmp Halt_IncTask
.rts
    rts