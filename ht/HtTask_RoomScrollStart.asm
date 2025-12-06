;==============================================================================
; mzxrules 2024
;==============================================================================

ROOMSCROLL_TIMER_EW = 64+1

HtTask_RoomScrollStart: SUBROUTINE
    lda #HALT_KERNEL_HUD_WORLD_NOPL
    sta wHaltKernelId

    ldy rHaltType
    ldx .roomDY,y
    stx roomScrollDY
    lda .timer,y
    sta roomTimer

    jmp Halt_TaskNext

.timer
    .byte -1
    .byte #ROOMSCROLL_TIMER_EW, #ROOMSCROLL_TIMER_EW, #ROOM_PX_HEIGHT, #ROOM_PX_HEIGHT

.roomDY
    .byte #ROOM_PX_HEIGHT-1
    .byte #ROOM_PX_HEIGHT-1, #ROOM_PX_HEIGHT-1, #ROOM_PX_HEIGHT-1, #ROOM_PX_HEIGHT*2-1

