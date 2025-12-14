;==============================================================================
; mzxrules 2025
;==============================================================================

HtTask_PauseMenuOpen: SUBROUTINE
    lda rOSFrameState
    bmi .vblank ; #OS_FRAME_VBLANK
    lda #SLOT_F0_PAUSE_MENU_MAP
    sta BANK_SLOT
    jmp Pause_PlotMap

.vblank
    lda RoomPX
    beq .task_end
    dec RoomPX
    jmp PAUSE_MAP_MEM_RESET

.task_end
    lda #HALT_KERNEL_PAUSEVIEW
    sta wHaltKernelId

    jmp Halt_TaskNext
