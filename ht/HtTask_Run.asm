;==============================================================================
; mzxrules 2024
;==============================================================================

HtTask_Run: SUBROUTINE
    ldx rHaltTask
    ldy Halt_TaskMatrix,x

.run_task:
    lda HtTask_BankLUT,y
    sta BANK_SLOT
    lda HtTaskH,y
    pha
    lda HtTaskL,y
    pha
HtTask_None:
    rts