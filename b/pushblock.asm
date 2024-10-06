;==============================================================================
; mzxrules 2022
;==============================================================================
BlSystem:
    ldx blType
BallDel:
    lda BallH,x
    pha
    lda BallL,x
    pha
BlNone:
    rts

UpdateRoomPush: SUBROUTINE ; CRITICAL, execute in 1 scanline
    lda roomPush        ; 3
    bmi .move_action
    eor plDir
    and #3
    bne .dont_push

    bit CXP0FB
    bmi .push
    bvs .push

.dont_push
    lda plDir
    and #3
    sta roomPush
    bpl .end_updateRoomPush ; jmp

.push
    lda roomPush
    cmp #$78
    bpl .end_updateRoomPush
    clc
    adc #4
    sta roomPush
    bpl .end_updateRoomPush ; jmp

.move_action
    inc roomPush
.end_updateRoomPush

    sta WSYNC
    jmp MAIN_VERTICAL_SYNC


BlR: SUBROUTINE
    inc blX
    rts
BlL:
    dec blX
    rts
BlU:
    inc blY
    rts
BlD:
    dec blY
    rts

BlPathPushBlock: SUBROUTINE
    ldx roomENCount
    bne .rts

    lda rPF1RoomL + 6
    and #~$0C
    sta wPF1RoomL + 6
    sta wPF1RoomL + 7

    ldx #$14
    stx blX
    ldx #$20
    stx blY
    lda #BL_PUSH_BLOCK
    sta blType
.rts
    rts

BlPushBlockLeft: SUBROUTINE
    ldx roomENCount
    bne .rts

    ldy #1
.loop
    lda rPF1RoomL+9,y
    and #$FC
    sta wPF1RoomL+9,y
    dey
    bpl .loop

    ldx #$1C
    stx blX
    ldx #$2C
    stx blY
    lda #BL_PUSH_BLOCK
    sta blType
.rts
    rts

BlPushBlockDiamondTop: SUBROUTINE
    ldx roomENCount
    bne .rts
    lda #0
    sta wPF2Room + 13
    sta wPF2Room + 14

    ldx #$40
    stx blX
    lda #$3C
    sta blY
    lda #BL_PUSH_BLOCK
    sta blType
    rts

BlPushBlock: ; SUBROUTINE
    ldx roomENCount
    bne .rts

    lda roomPush
    bmi .sliding

    bit CXP0FB
    bvc .rts ; is not pushing block

    cmp #[12 << 2]
    bcc .rts ; has not pushed long enough

    and #3
    sta blDir
    lda #-16 -1 ; Will decrement 1
    sta roomPush
    lda #SEQ_SOLVE_DUR
    sta SeqSolveCur
.rts
    rts
.sliding
    lda roomPush
    cmp #$FF
    beq BlPushEnd
    and #1
    bne .rts
    ldx blDir
    inx
    jmp BallDel

BlPushBlockWaterfall: SUBROUTINE
    lda roomPush
    bmi .sliding

    bit CXP0FB
    bvc .rts ; is not pushing block

    cmp #[8 << 2]
    bcc .rts ; has not pushed long enough

    lda #-32 -1 ; Will decrement 1
    sta roomPush
.rts
    rts

.sliding
    lda #SFX_BOMB
    sta SfxFlags
    lda roomPush
    cmp #$FF
    beq BlPushEnd
    and #3
    bne .rts
    ldx #BL_U
    jmp BallDel

BlPushEnd:
    lda roomFlags
    and #RF_EV_CLEAR
    bne .rts
    ora #RF_EV_CLEAR
    sta roomFlags
    lda #BL_NONE
    sta blType
    rts