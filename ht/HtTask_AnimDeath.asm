;==============================================================================
; mzxrules 2024
;==============================================================================

HtTask_AnimDeath: SUBROUTINE
    lda rOSFrameState
    bmi .skip_plStunAnim ; #OS_FRAME_VBLANK

    lda plStun
    bpl .end_plStunAnim
    cmp #-64
    bcs .update_plStun
    lda #-64
    sta plStun
; update player stun timer
.update_plStun
    inc plStun

    and #3
    tax
    lda PlayerStunColors,x
    sta wPlColor
.skip_plStunAnim

    rts
.end_plStunAnim
    lda #MS_PLAY_NONE
    sta SeqFlags

; Init GameOver
    ldx #0

    stx wRoomColorFlags
    stx enType
    stx enType+1
    stx miType
    stx miType+1
    stx roomFlags
    stx mesgId

    ldx #TEXT_MODE_DIALOG
    stx wTextMode

    ldx #$80
    stx plY
    stx mesgDY

    ldx #MS_PLAY_OVER
    stx SeqFlags
    lda plState2
    and #~#PS_HOLD_ITEM
    sta plState2
    lda #-$20 ; input delay timer
    sta enInputDelay

    jmp Halt_TaskNext
