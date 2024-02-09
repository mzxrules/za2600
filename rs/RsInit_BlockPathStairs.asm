;==============================================================================
; mzxrules 2023
;==============================================================================
RsInit_BlockPathStairs: SUBROUTINE
    lda #$80
    sta blY
    lda roomFlags
    ora #RF_NO_ENCLEAR
    sta roomFlags

    ldx #$18
    ldy #$20
    jmp .initPos
    cpx plX
    bne .initPos
    cpy plY
    bne .initPos

    lda #$C0
    sta wPF1RoomL + 6
    sta wPF1RoomL + 7
    rts

.initPos
    lda #BL_PATH_PUSH_BLOCK
    sta blType
    rts