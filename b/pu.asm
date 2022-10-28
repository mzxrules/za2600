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


BlDiamondPushBlock: SUBROUTINE
    ldx roomENCount
    bne .rts
    ldx #$41
    stx blX
    lda #$3C
    sta blY
    lda #BL_PUSH_BLOCK
    sta blType
    lda #0
    sta wPF2Room + 13
    sta wPF2Room + 14


BlPushBlock: ; SUBROUTINE
    ldx roomENCount
    bne .rts
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