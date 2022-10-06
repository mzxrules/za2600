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
    lda #$80
    sta blY
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

BlPushBlock: SUBROUTINE
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
    ora #RF_CLEAR
    sta roomFlags
.rts
    rts