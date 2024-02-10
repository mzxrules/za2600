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
    rts


BlNone:
    rts

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

    ldx #$14+1
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

    ldx #$1C+1
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

    ldx #$40+1
    stx blX
    lda #$3C
    sta blY
    lda #BL_PUSH_BLOCK
    sta blType
    rts

BlPushBlock: ; SUBROUTINE
    ldx roomENCount
    bne .rts
.skipENCount
    ldx roomPush
    inx
    cpx #16+12 ; full move
    bpl .pushDone
    stx roomPush
    cpx #12
    bmi .pushCheck
    lda Frame
    and #1
    beq .rts
    ldx blDir
    inx
    jmp BallDel

.pushCheck
    ; set direction
    lda plDir
    sta blDir

    ldy #0
    bit CXP0FB
    bvs .rts
    sty roomPush
    rts

.pushDone
    lda roomFlags
    ora #RF_EV_CLEAR
    sta roomFlags
.rts
    rts

BlPushBlockWaterfall: SUBROUTINE
    ldx roomPush
    inx
    cpx #8+2 ; full move
    bpl .pushDone
    stx roomPush
    cpx #2
    bmi .pushCheck
    ldx #BL_U
    jmp BallDel

.pushCheck
    ; set direction
    lda plDir
    sta blDir

    ldy #0
    bit CXP0FB
    bvs .rts
    sty roomPush
    rts

.pushDone
.rts
    rts