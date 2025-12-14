;==============================================================================
; mzxrules 2025
;==============================================================================

HtTask_PauseMenuStart: SUBROUTINE
    lda #[#HUD_MODE_ON | #HUD_MODE_SLIDE]
    sta wHudMode

    lda rTextMode
    and #~#TEXT_MODE_ACTIVE
    sta wTextMode

    lda #ROOM_PX_HEIGHT-1
    sta RoomPX
    jmp Halt_TaskNext