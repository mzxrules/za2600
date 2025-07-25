;==============================================================================
; mzxrules 2023
;==============================================================================

En_NpcPath: SUBROUTINE
    lda #MESG_PATH
    sta mesgId
    lda #TEXT_MODE_DIALOG
    sta wTextMode

    ldy plY
    cpy #$28
    bne .rts

    ldx #3
    lda plX
    cmp #$60
    beq .pathSelected
    dex
    cmp #$40
    beq .pathSelected
    dex
    cmp #$20
    bne .rts

.pathSelected
    txa
    clc
    adc roomEX
    adc #$100-CV_PATH1
    and #3
    tay
    lda NpcPathRooms,y
    sta worldSR
    lda #MS_PLAY_THEME_L
    jmp RETURN_WORLD

.rts
    rts

NpcPathRooms:
    .byte $79, $1D, $49, $23