;==============================================================================
; mzxrules 2025
;==============================================================================

HtTask_PauseMenuClose: SUBROUTINE
    lda #[#HUD_MODE_ON | #HUD_MODE_SLIDE]
    sta wHudMode
    lda rOSFrameState
    bmi .continue ; #OS_FRAME_VBLANK
    rts
.continue

    inc RoomPX
    lda RoomPX
    cmp #ROOM_PX_HEIGHT-1
    beq HtTask_PauseEnd
    rts

HtTask_PauseEnd: SUBROUTINE
    lda #[#HUD_MODE_ON | #HUD_MODE_FIXED]
    sta wHudMode
    ldx #$FF
    txs
    inx
    stx wHaltType

    ; Restore Frame, correcting audio timers
    lda rHaltFrame
    tax
    sec
    sbc Frame
    sta Frame

    lda SeqTFrame
    clc
    adc Frame
    sta SeqTFrame

    lda SeqTFrame+1
    clc
    adc Frame
    sta SeqTFrame+1
    stx Frame

; Restore TextMode
    lda rTextMode
    beq .endTextModeRestore
    ora #TEXT_MODE_ACTIVE
    sta wTextMode
.endTextModeRestore
    lda #SLOT_F0_PL
    sta BANK_SLOT
    jmp MAIN_UNPAUSE