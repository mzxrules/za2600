;==============================================================================
; mzxrules 2024
;==============================================================================

    INCLUDE "gen/HtTask_Scripts.asm"
    INCLUDE "gen/HtTask_DelBankLUT.asm"
    INCLUDE "gen/HtTask_DelLUT.asm"

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