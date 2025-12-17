;==============================================================================
; mzxrules 2025
;==============================================================================
HtTask_SetGameViewScroll: SUBROUTINE
    lda #HALT_KERNEL_GAMEVIEW_SCROLL
    sta wHaltKernelId
    jmp Halt_TaskNext