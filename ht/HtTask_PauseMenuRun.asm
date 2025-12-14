;==============================================================================
; mzxrules 2025
;==============================================================================

HtTask_PauseMenuRun: SUBROUTINE
    lda rOSFrameState
    bmi .vblank ; #OS_FRAME_VBLANK
    rts
.vblank
    jsr PAUSE_ANIMATE_BLINK
    jmp Pause_Menu_Input
