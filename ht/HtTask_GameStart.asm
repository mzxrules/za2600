;==============================================================================
; mzxrules 2025
;==============================================================================

HtTask_GameStart: SUBROUTINE
    lda #HALT_KERNEL_GAMEVIEW_BLACK
    sta wHaltKernelId
    lda #[#HUD_MODE_FIXED | #HUD_MODE_ON]
    sta wHudMode
    lda #ROOM_PX_HEIGHT-1
    sta RoomPX
    lda #$FF
    sta Halt_Temp0
    jmp Halt_TaskNext